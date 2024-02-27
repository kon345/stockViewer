//
//  FileHelper.swift
//  stockViewer
//
//  Created by 林裕和 on 2024/1/16.
//

import Foundation
import UniformTypeIdentifiers
import CoreData

let acceptTypes = [UTType(filenameExtension: "csv"), UTType(filenameExtension: "txt")].compactMap{$0}
let companyNOmin = 1101
let yearMin = 103
let yearMax = 112
let thisYearText = "今年營收"
let lastYearText = "去年營收"
let conceptText = "概念成分股:"
let bigCategoryText = "大產業:"
let smallCategoryText = "細產業:"
let companyEntityText = "Company"
let companyBigCategoryEntityText = "CompanyBigCategory"
let companySmallCategoryEntityText = "CompanySmallCategory"

let context = CoreDataHelper.shared.managedObjectContext()

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
    
    // 從coreData藉由公司編號取公司資料
    func fetchCompanywithNumber(companyNumber: Int32)-> Company?{
        let predicate = NSPredicate(format: "number == %d", companyNumber)
        let request = NSFetchRequest<Company>(entityName: companyEntityText)
        request.predicate = predicate
        
        do {
            let companies = try context.fetch(request)
            return companies.first
        } catch {
            print("沒有對應\(companyNumber)的公司")
            return nil
        }
    }
    
    // 從coreData藉由公司編號取大產業類別
    func fetchCompanyBigCategorywithNumber(companyNumber: Int32) -> [CompanyBigCategory]?{
        let predicate = NSPredicate(format: "number == %d", companyNumber)
        let request = NSFetchRequest<CompanyBigCategory>(entityName: companyBigCategoryEntityText)
        request.predicate = predicate
        
        do {
            let bigCategoryList = try context.fetch(request)
            return bigCategoryList
        } catch {
            print("沒有對應\(companyNumber)的大產業資料")
            return nil
        }
    }
    
    // 從coreData藉由公司編號取小產業類別
    func fetchCompanySmallCategorywithNumber(companyNumber: Int32) -> [CompanySmallCategory]?{
        let predicate = NSPredicate(format: "number == %d", companyNumber)
        let request = NSFetchRequest<CompanySmallCategory>(entityName: companySmallCategoryEntityText)
        request.predicate = predicate
        
        do {
            let smallCategoryList = try context.fetch(request)
            return smallCategoryList
        } catch {
            print("沒有對應\(companyNumber)的小產業資料")
            return nil
        }
    }
    
    // 存大產業資料表
    func saveCompanyBigCategory(companyData: CompanyData){
        var prevBigCategoryList: [CompanyBigCategory] = []
        // 取大產業表舊資料
        if let bigCategoryList = fetchCompanyBigCategorywithNumber(companyNumber: companyData.number){
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
            // 就的沒有-->新資料
            if prevBigCategoryList.allSatisfy({ companyBigCategory in
                companyBigCategory.bigCategory != bigCategory
            }){
                if let companyBigCategoryEntity = NSEntityDescription.entity(forEntityName: companyBigCategoryEntityText, in: context),
                   let companyBigCategoryObject = NSManagedObject(entity: companyBigCategoryEntity, insertInto: context) as? CompanyBigCategory{
                    companyBigCategoryObject.number = companyData.number
                    companyBigCategoryObject.bigCategory = bigCategory
                    // 儲存
                    CoreDataHelper.shared.saveContext()
                }
            }
        }
    }
    
    // 存小產業資料表
    func saveCompanySmallCategory(companyData: CompanyData){
        var prevSmallCategoryList: [CompanySmallCategory] = []
        // 取小產業表舊資料
        if let smallCategoryList = fetchCompanySmallCategorywithNumber(companyNumber: companyData.number){
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
            // 就的沒有-->新資料
            if prevSmallCategoryList.allSatisfy({ companySmallCategory in
                companySmallCategory.smallCategory != smallCategory
            }){
                if let companySmallCategoryEntity = NSEntityDescription.entity(forEntityName: companySmallCategoryEntityText, in: context),
                   let companySmallCategoryObject = NSManagedObject(entity: companySmallCategoryEntity, insertInto: context) as? CompanySmallCategory{
                    companySmallCategoryObject.number = companyData.number
                    companySmallCategoryObject.smallCategory = smallCategory
                    // 儲存
                    CoreDataHelper.shared.saveContext()
                }
            }
        }
    }
    
    // 儲存公司
    func saveCompany(companies: [CompanyData]){
        companies.forEach { companyData in
            var company: Company!
            // 取現有資料來修改
            if let companyObject = fetchCompanywithNumber(companyNumber: companyData.number){
                company = companyObject
            // 存新一筆資料建立空的coreData Company物件
            } else if let companyEntity = NSEntityDescription.entity(forEntityName: companyEntityText, in: context),
                      let companyObject = NSManagedObject(entity: companyEntity, insertInto: context) as? Company{
                company = companyObject
            } else{
                return
            }
            
            saveCompanyBigCategory(companyData: companyData)
            saveCompanySmallCategory(companyData: companyData)
            
            // 寫入資料
            company.number = companyData.number
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
            
            // 儲存
            CoreDataHelper.shared.saveContext()
        }
    }
}


