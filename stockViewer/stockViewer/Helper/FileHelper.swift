//
//  FileHelper.swift
//  stockViewer
//
//  Created by 林裕和 on 2024/1/16.
//

import Foundation
import CoreData

struct CompanyData: Codable{
    var number: Int32
    var name: String
    var yearData: Dictionary<Int, [Double]>
    var thisYear: [String]
    var lastYear: [Double]
    var bigCategory: [String]
    var smallCategory: [String]
    var concept: [String]
    
    // 比較是否完全不同
    func isDifferent(from other: CompanyData) -> Bool {
        return (number == other.number ||
                name == other.name ||
                yearData == other.yearData ||
                thisYear == other.thisYear ||
                lastYear == other.lastYear ||
                bigCategory == other.bigCategory ||
                smallCategory == other.smallCategory ||
                concept == other.concept) == false
    }
}

// 空companyData(初始值）
let emptyCompany = CompanyData(number: 0, name: "", yearData: [:], thisYear: [], lastYear: [], bigCategory: [], smallCategory: [], concept: [])

class FileHelper{
    static let shared = FileHelper()
    private init(){}
    var allBigCategory: [String] = []
    var allSmallCategory: [String] = []
    
    func parseCSVData(csv: String) -> [CompanyData] {
        var companies: [CompanyData] = []
        var currentCompany = emptyCompany
        
        // 按行分割 CSV 資料
        var lines = csv.components(separatedBy: "\n")
        
        // 去除結尾逗號
        lines = lines.map { line in
            let suffixToRemove = ","
            var newLine = line
            newLine = newLine.trimmingCharacters(in: .whitespacesAndNewlines)
            
            while newLine.hasSuffix(suffixToRemove){
                newLine = String(newLine.dropLast())
            }
            return newLine
        }
        
        // 去除空白行
        let nonEmptyLines = lines.filter { !$0.isEmpty }
        
        // 暫時紀錄概念成分股行數
        var conceptStartLine = 0
        for (index, line) in nonEmptyLines.enumerated() {
            let columns = line.components(separatedBy: ",")
            // 取公司編號
            if let firstColumn = Int32(columns[0]), firstColumn >= companyNOmin{
                // 第1欄位為公司編號
                currentCompany.number = firstColumn
                // 第2欄位為公司名稱
                currentCompany.name = columns[1]
            }
            
            // 取年度資料
            if let firstColumn = Int(columns[0]), firstColumn >= yearMin && firstColumn <= yearMax{
                // 取年份當key並移除年份
                let key = firstColumn
                var yearData = columns
                yearData.removeFirst()
                
                let data: [Double] = yearData.map { column in
                    // 移除％末尾
                    let suffixToRemove = "%"
                    var columnData = column
                    if columnData.hasSuffix(suffixToRemove){
                        columnData = String(columnData.dropLast())
                    }
                    // 空格或無法轉換成double補0
                    guard let convertedData = Double(columnData) else{
                        return 0.0
                    }
                    return convertedData
                }
                currentCompany.yearData[key] = data
            }
            
            // 取今年營收
            if columns[0] == thisYearText {
                var thisYearData = columns
                thisYearData.removeFirst()
                currentCompany.thisYear = thisYearData
            }
            
            // 取去年營收
            if columns[0] == lastYearText {
                var lastYearData = columns
                lastYearData.removeFirst()
                let data: [Double] = lastYearData.map { column in
                    // 移除,
                    var columnData = column
                    if columnData.contains(","){
                        columnData = columnData.replacingOccurrences(of: ",", with: "")
                    }
                    if columnData.contains("\""){
                        columnData = columnData.replacingOccurrences(of: "\"", with: "")
                    }
                    // 空格或無法轉換成double補0
                    guard let convertedData = Double(columnData) else{
                        return 0.0
                    }
                    return convertedData
                }
                currentCompany.lastYear = data
            }
            
            // 取概念成分股
            if columns[0] == conceptText{
                conceptStartLine = index
                var conceptData = columns
                conceptData.removeFirst()
                currentCompany.concept = conceptData
            }
            
            // 剩餘的概念成分股（一行以上）
            if index > conceptStartLine && columns[0] != bigCategoryText && columns[0] != smallCategoryText{
                currentCompany.concept += columns
            }
            
            // 取大產業
            if columns[0] == bigCategoryText {
                var bigCategoryData = columns
                bigCategoryData.removeFirst()
                bigCategoryData.forEach { data in
                    if allBigCategory.contains(data) == false{
                        allBigCategory.append(data)
                    }
                }
                currentCompany.bigCategory = bigCategoryData
            }
            
            // 取小產業
            if columns[0] == smallCategoryText{
                var smallCategoryData = columns
                smallCategoryData.removeFirst()
                smallCategoryData.forEach { data in
                    if allSmallCategory.contains(data) == false{
                        allSmallCategory.append(data)
                    }
                }
                currentCompany.smallCategory = smallCategoryData
            }
            
            // 全部屬性皆非初始值時儲存資料
            if currentCompany.isDifferent(from: emptyCompany){
                // 重置
                conceptStartLine = 0
                companies.append(currentCompany)
                currentCompany = emptyCompany
            }
        }
        return companies
    }
    
    // 存大產業資料表
    func saveCompanyBigCategory(companyData: CompanyData) -> [CompanyBigCategory]{
        var newBigCategoryList: [CompanyBigCategory] = []
        var prevBigCategoryList: [CompanyBigCategory] = []
        // 取大產業表舊資料
        if let bigCategoryList = QueryHelper.shared.fetchCompanyBigCategorywithNumber(companyNumber: companyData.number){
            prevBigCategoryList = bigCategoryList
        }
        
        // 比對大產業刪除
        prevBigCategoryList.forEach { companyBigCategory in
            if companyData.bigCategory.contains(companyBigCategory.bigCategory) == false{
                // 刪除並儲存
                context.delete(companyBigCategory)
                CoreDataHelper.shared.saveContext()
            }
        }
        
        // 比對大產業新增
        companyData.bigCategory.forEach { bigCategory in
            // 舊的沒有-->新資料
            if prevBigCategoryList.allSatisfy({ companyBigCategory in
                companyBigCategory.bigCategory != bigCategory
            }){
                let companyBigCategoryObject = CompanyBigCategory(context: context)
                companyBigCategoryObject.number = companyData.number
                companyBigCategoryObject.bigCategory = bigCategory
                newBigCategoryList.append(companyBigCategoryObject)
            }
        }
        return newBigCategoryList
    }
    
    // 存小產業資料表
    func saveCompanySmallCategory(companyData: CompanyData) -> [CompanySmallCategory]{
        var newSmallCategoryList: [CompanySmallCategory] = []
        var prevSmallCategoryList: [CompanySmallCategory] = []
        // 取小產業表舊資料
        if let smallCategoryList = QueryHelper.shared.fetchCompanySmallCategorywithNumber(companyNumber: companyData.number){
            prevSmallCategoryList = smallCategoryList
        }
        
        // 比對小產業刪除
        prevSmallCategoryList.forEach { companySmallCategory in
            if companyData.smallCategory.contains(companySmallCategory.smallCategory) == false{
                // 刪除並儲存
                context.delete(companySmallCategory)
                CoreDataHelper.shared.saveContext()
            }
        }
        
        // 比對小產業新增
        companyData.smallCategory.forEach { smallCategory in
            // 舊的沒有-->新資料
            if prevSmallCategoryList.allSatisfy({ companySmallCategory in
                companySmallCategory.smallCategory != smallCategory
            }){
                let companySmallCategoryObject = CompanySmallCategory(context: context)
                companySmallCategoryObject.number = companyData.number
                companySmallCategoryObject.smallCategory = smallCategory
                newSmallCategoryList.append(companySmallCategoryObject)
            }
        }
        return newSmallCategoryList
    }
    
    // 刪除所有內存資料
    func deleteAllExistingData(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: companyEntityText)
           let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

           do {
               try context.execute(batchDeleteRequest)
           } catch {
               print("全部資料刪除失敗")
           }
    }
    
    // 從CoreData中刪除新檔案沒有的資料
    func deleteRemovedData(oldCompanyNumberList: [Int32], newCompanyNumberList: [Int32]){
        let old = Set(oldCompanyNumberList)
        let new = Set(newCompanyNumberList)
        
        let difference = old.subtracting(new)
        let resultArray = Array(difference)
        
        resultArray.forEach { removedDataNumber in
            guard let removedData = QueryHelper.shared.fetchCompanywithNumber(companyNumber: removedDataNumber) else{
                print("CoreData取的要刪除資料失敗, 編號：\(removedDataNumber)")
                return
            }
            context.delete(removedData)
        }
    }
    
    // 儲存公司
    func saveCompany(companies: [CompanyData]){
        var newCompanyNumberList: [Int32] = []
        guard let oldCompanyNumberList = QueryHelper.shared.fetchAllCompanyNumber() else{
            print("取舊資料公司編號錯誤")
            return
        }
        companies.forEach { companyData in
            var company: Company!
            // 取現有資料來修改
            if let companyObject = QueryHelper.shared.fetchCompanywithNumber(companyNumber: companyData.number){
                company = companyObject
            // 存新一筆資料建立空的coreData Company物件
            } else {
                let companyObject = Company(context: context)
                company = companyObject
            }
            
            let newBigCategoryData = saveCompanyBigCategory(companyData: companyData)
            let newSmallCategoryData = saveCompanySmallCategory(companyData: companyData)
            
            // 寫入資料
            company.number = companyData.number
            newCompanyNumberList.append(companyData.number)
            company.name = companyData.name
            company.bigCategory = companyData.bigCategory
            company.smallCategory = companyData.smallCategory
            company.lastYear = companyData.lastYear
            company.thisYear = companyData.thisYear
            company.concept = companyData.concept
            if let yearData = try? NSKeyedArchiver.archivedData(withRootObject: companyData.yearData, requiringSecureCoding: false){
                company.yearData = yearData
            } else {
                assertionFailure("轉換yearData錯誤")
            }
            
            // 設定關聯
            newBigCategoryData.forEach { bigCategoryData in
                company.companyBig.adding(bigCategoryData)
                bigCategoryData.company = company
            }
            
            newSmallCategoryData.forEach { smallCategoryData in
                company.companySmall.adding(smallCategoryData)
                smallCategoryData.company = company
            }
            // 儲存
            CoreDataHelper.shared.saveContext()
        }
        
        deleteRemovedData(oldCompanyNumberList: oldCompanyNumberList, newCompanyNumberList: newCompanyNumberList)
        CoreDataHelper.shared.saveContext()
    }
}


