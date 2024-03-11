//
//  Resources.swift
//  stockViewer
//
//  Created by 林裕和 on 2024/3/10.
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
let companyNumberText = "公司編號:"
let companyEntityText = "Company"
let companyBigCategoryEntityText = "CompanyBigCategory"
let companySmallCategoryEntityText = "CompanySmallCategory"
let numberAttributeText = "number"
let bigCategoryAttributeText = "bigCategory"
let smallCategoryAttributeText = "smallCategory"
let querySegueText = "goToQueryPage"
let spreadSheetSegueText = "goToSpreadsheet"
let pleaseChooseText = "(請選擇）"
let spreadSheetAttributes = ["年", "EPS", "配息", "配股", "配/EPS(%)", "Q4最低", "H1最高", "H1/Q4", "年最高", "年最低", "Q1EPS", "Q2EPS", "Q3EPS", "Q4EPS", "Qtotal", "股本(億)", "淨值"]
let spreadsheetCellIdentifier = "SpreadsheetCell"

let context = CoreDataHelper.shared.managedObjectContext()
let defaults = UserDefaults.standard
