//
//  FileHelper.swift
//  stockViewer
//
//  Created by 林裕和 on 2024/1/16.
//

import Foundation
import UniformTypeIdentifiers

let acceptTypes = [UTType(filenameExtension: "csv"), UTType(filenameExtension: "txt")].compactMap{$0}
let companyNOmin = 1101
let yearMin = 103
let yearMax = 112
let thisYearText = "今年營收"
let lastYearText = "去年營收"
let conceptText = "概念成分股:"
let bigCategoryText = "大產業:"
let smallCategoryText = "細產業:"

struct CompanyData: Codable{
    var NO: Int
    var name: String
    var yearData: Dictionary<Int, [Double]>
    var thisYear: [String]
    var lastYear: [Double]
    var bigCategory: [String]
    var smallCategory: [String]
    var concept: [String]
    
    // 比較是否完全不同
    func isDifferent(from other: CompanyData) -> Bool {
            return (NO == other.NO ||
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
let emptyCompany = CompanyData(NO: 0, name: "", yearData: [:], thisYear: [], lastYear: [], bigCategory: [], smallCategory: [], concept: [])

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
        if let firstColumn = Int(columns[0]), firstColumn >= companyNOmin{
            // 第1欄位為公司編號
            currentCompany.NO = firstColumn
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
                print(columnData)
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
            currentCompany.bigCategory = bigCategoryData
        }
        
        // 取小產業
        if columns[0] == smallCategoryText{
            var smallCategoryData = columns
            smallCategoryData.removeFirst()
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
