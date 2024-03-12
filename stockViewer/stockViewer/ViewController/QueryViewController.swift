//
//  QueryViewController.swift
//  stockViewer
//
//  Created by 林裕和 on 2024/3/10.
//

import UIKit
import iOSDropDown

class QueryViewController: UIViewController {
    var bigCategoryResults : [Int32] = []
    var smallCategoryResults: [Int32] = []
    var defaultOptions: [String] = [pleaseChooseText]

    @IBOutlet weak var bigCategoryDropdown: DropDown!
    @IBOutlet weak var smallCategoryDropdown: DropDown!
    @IBOutlet weak var companyNumberDropdown: DropDown!
    override func viewDidLoad() {
        super.viewDidLoad()
        // 取得大產業種類
        guard var bigCategoryList = QueryHelper.shared.fetchAllBigCategory(), bigCategoryList.count > 0 else{
            print("取得大產業種類失敗")
            return
        }
        // 設定初始選項
        bigCategoryList.insert(pleaseChooseText, at: 0)
        bigCategoryDropdown.optionArray = bigCategoryList
        smallCategoryDropdown.optionArray = defaultOptions
        companyNumberDropdown.optionArray = defaultOptions
        // 選擇大產業
        bigCategoryDropdown.didSelect { selectedText, index, id in
            // 選到請選擇
            guard index != 0 else {
                return
            }
            // 取得細產業選項
            if let companyNumberList = QueryHelper.shared.fetchCompanyNumberAccordingtoBigCategory(bigCategory: bigCategoryList[index]), var smallCategoryList = QueryHelper.shared.fetchSmallCategorywithCompanyNumberList(companyNumberList: companyNumberList){
                self.bigCategoryResults = companyNumberList
                smallCategoryList.insert(pleaseChooseText, at: 0)
                self.smallCategoryDropdown.optionArray = smallCategoryList
            }
        }
        // 選擇細產業
        smallCategoryDropdown.didSelect { selectedText, index, id in
            // 選到請選擇or沒選大產業
            guard index != 0, self.bigCategoryResults.count > 0 else {
                return
            }
            self.bigCategoryDropdown.isEnabled = false
            
            if let companyNumberList = QueryHelper.shared.fetchCompanyBySmallCategoryResults(companyNumberList: self.bigCategoryResults, smallCategory: selectedText){
                self.smallCategoryResults = companyNumberList
                var companyNumberListToString = companyNumberList.map { String($0) }
                companyNumberListToString.insert(pleaseChooseText, at: 0)
                self.companyNumberDropdown.optionArray = companyNumberListToString
            }
        }
        // 選擇公司編號
        companyNumberDropdown.didSelect { selectedText, index, id in
            guard index != 0, self.smallCategoryResults.count > 0 else {
                return
            }
            self.smallCategoryDropdown.isEnabled = false
            QueryHelper.shared.selectedCompany = self.smallCategoryResults[index-1]
        }
    }
    

    @IBAction func resetAllBtnPressed(_ sender: Any) {
        // 重置Dropdown&篩選結果
        bigCategoryResults = []
        smallCategoryResults = []
        bigCategoryDropdown.isEnabled = true
        smallCategoryDropdown.isEnabled = true
        smallCategoryDropdown.optionArray = defaultOptions
        companyNumberDropdown.optionArray = defaultOptions
        bigCategoryDropdown.selectedIndex = 0
        smallCategoryDropdown.selectedIndex = 0
        companyNumberDropdown.selectedIndex = 0
        bigCategoryDropdown.text = ""
        smallCategoryDropdown.text = ""
        companyNumberDropdown.text = ""
        QueryHelper.shared.selectedCompany = 0
    }
    
    @IBAction func confirmBtnPressed(_ sender: Any) {
        // 都有選擇＆有目標公司才跳表格顯示
        guard QueryHelper.shared.selectedCompany != 0, bigCategoryResults.count > 0, smallCategoryResults.count > 0 else{
            return
        }
        performSegue(withIdentifier: spreadSheetSegueText, sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
