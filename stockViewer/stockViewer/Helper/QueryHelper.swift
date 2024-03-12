//
//  QueryHelper.swift
//  stockViewer
//
//  Created by 林裕和 on 2024/3/10.
//

import Foundation
import CoreData

class QueryHelper{
    static let shared = QueryHelper()
    private init(){}
    var selectedCompany : Int32 = 0
    
    // 從coreData藉由公司編號取公司資料
    func fetchCompanywithNumber(companyNumber: Int32)-> Company?{
        let predicate = NSPredicate(format: "number == %d", companyNumber)
        let request = NSFetchRequest<Company>(entityName: companyEntityText)
        request.predicate = predicate
        
        do {
            let companies = try context.fetch(request)
            return companies.first
        } catch {
            print("沒有對應\(companyNumber)的公司: \(error)")
            return nil
        }
    }
    
    // 從coreData藉由公司編號取大產業資料（獲取整個資料實體）
    func fetchCompanyBigCategorywithNumber(companyNumber: Int32) -> [CompanyBigCategory]?{
        let predicate = NSPredicate(format: "number == %d", companyNumber)
        let request = NSFetchRequest<CompanyBigCategory>(entityName: companyBigCategoryEntityText)
        request.predicate = predicate
        
        do {
            let bigCategoryList = try context.fetch(request)
            return bigCategoryList
        } catch {
            print("沒有對應\(companyNumber)的大產業資料: \(error)")
            return nil
        }
    }
    
    // 從coreData藉由公司編號取小產業資料（獲取整個資料實體）
    func fetchCompanySmallCategorywithNumber(companyNumber: Int32) -> [CompanySmallCategory]?{
        let predicate = NSPredicate(format: "number == %d", companyNumber)
        let request = NSFetchRequest<CompanySmallCategory>(entityName: companySmallCategoryEntityText)
        request.predicate = predicate
        
        do {
            let smallCategoryList = try context.fetch(request)
            return smallCategoryList
        } catch {
            print("沒有對應\(companyNumber)的小產業資料: \(error)")
            return nil
        }
    }
    
    // 從coreData藉由公司編號列表取得細產業類別
    func fetchSmallCategorywithCompanyNumberList(companyNumberList: [Int32]) -> [String]?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: companySmallCategoryEntityText)
        request.predicate = NSPredicate(format: "number IN %@", companyNumberList)
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [smallCategoryAttributeText]
        request.returnsDistinctResults = true
        
        do {
               let results = try context.fetch(request)
               var smallCategories: [String] = []
               for case let result as [String: String] in results {
                   if let smallCategory = result["smallCategory"] {
                       smallCategories.append(smallCategory)
                   }
               }
               return smallCategories
           } catch {
               print("取得細產業類別失敗: \(error)")
               return nil
           }
    }
    
    // 取得第二重小產業同時篩選的公司編號
    func fetchCompanyBySmallCategoryResults(companyNumberList: [Int32], smallCategory: String) -> [Int32]?{
        let request = NSFetchRequest<CompanySmallCategory>(entityName: companySmallCategoryEntityText)
        let numberPredicate = NSPredicate(format: "number IN %@", companyNumberList)
        let categoryPredicate = NSPredicate(format: "smallCategory == %@", smallCategory)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [numberPredicate, categoryPredicate])
        request.predicate = compoundPredicate
        
        do {
            let results = try context.fetch(request)
            let numbers = results.compactMap { $0.value(forKey: "number") as? Int32 }
            return numbers
        } catch {
            print("第二重篩選取得資料失敗: \(error)")
            return nil
        }
    }
    
    // 從coreData取得所有公司編號
    func fetchAllCompanyNumber() -> [Int32]?{
        let request = NSFetchRequest<Company>(entityName: companyEntityText)
        request.returnsDistinctResults = true
        request.propertiesToFetch = [numberAttributeText]
        
        do {
            let results = try context.fetch(request)
            let uniqueValues = results.compactMap { $0.number }
            return uniqueValues
        } catch {
            print("取得公司編號失敗: \(error)")
        }
        return nil
    }
    
    // 從coreData取得所有大產業類別
    func fetchAllBigCategory() -> [String]?{
        let request = NSFetchRequest<CompanyBigCategory>(entityName: companyBigCategoryEntityText)
        request.returnsDistinctResults = true
        request.propertiesToFetch = [bigCategoryAttributeText]
        
        do {
            let results = try context.fetch(request)
            let uniqueValues = Set(results.compactMap { $0.bigCategory })
            return Array(uniqueValues)
        } catch {
            print("取得大產業失敗: \(error)")
        }
        return nil
    }
    
    // 取得大產業所包含的編號
    func fetchCompanyNumberAccordingtoBigCategory(bigCategory: String) -> [Int32]?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: companyBigCategoryEntityText)
        request.predicate = NSPredicate(format: "bigCategory == %@", bigCategory)
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [numberAttributeText]
        do {
            let results = try context.fetch(request)
            if let dictionaries = results as? [[String: Int32]] {
                let numbers = dictionaries.compactMap { $0["number"]}
                return numbers
            }
        } catch {
            print("取得大產業包含公司失敗: \(error)")
        }
        return nil
    }
    
    // 解碼yearData
    func unarchiveYearData(company: Company) -> [Dictionary<Int, [Double]>.Element]?{
        if let unarchivedData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(company.yearData) as? [Int: [Double]] {
            let sortedData = unarchivedData.sorted { $0.key < $1.key }
            let resultArray = sortedData.map{ $0 }
                return resultArray
            } else {
                print("解碼\(company.number)公司yearData錯誤")
                return nil
            }
    }
}
