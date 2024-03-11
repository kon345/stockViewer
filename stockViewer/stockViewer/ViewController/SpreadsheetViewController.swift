//
//  SpreadsheetViewController.swift
//  stockViewer
//
//  Created by 林裕和 on 2024/3/11.
//

import UIKit
import SpreadsheetView

class SpreadsheetViewController: UIViewController {
    var yearData: [Dictionary<Int, [Double]>.Element] = []
    var thisYear: [String] = []
    var lastYear: [Double] = []
    private let spreadsheetView = SpreadsheetView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard QueryHelper.shared.selectedCompany != 0, let company = QueryHelper.shared.fetchCompanywithNumber(companyNumber: QueryHelper.shared.selectedCompany), let fetchedData = QueryHelper.shared.unarchiveYearData(company: company) else{
            print("取得\(QueryHelper.shared.selectedCompany)公司資料失敗")
            return
        }
        yearData = fetchedData
        thisYear = company.thisYear
        lastYear = company.lastYear
        spreadsheetView.register(SpreadsheetCell.self, forCellWithReuseIdentifier: spreadsheetCellIdentifier)
        spreadsheetView.dataSource = self
        view.addSubview(spreadsheetView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        spreadsheetView.frame = CGRect(x: 0, y: 100, width: view.frame.size.width, height: view.frame.size.height-100)
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

extension SpreadsheetViewController: SpreadsheetViewDataSource, SpreadsheetViewDelegate{
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return spreadSheetAttributes.count
    }
    
    // 年度資料＋屬性＋今年/去年
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return yearData.count+3
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return 80
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 55
    }
    
    // 鎖住最上行
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    // 鎖住最左列
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: spreadsheetCellIdentifier, for: indexPath) as! SpreadsheetCell
        
        switch (indexPath.row, indexPath.column) {
        // 屬性欄
        case (0, _):
            cell.setup(with: spreadSheetAttributes[indexPath.column])
        // 今年營收
        case (let row, let column) where row == yearData.count + 1 && column == 0:
            cell.setup(with: thisYearText)

        case (let row, let column) where row == yearData.count + 1 && column > 0:
            cell.setup(with: thisYear[column - 1])
        // 去年營收
        case (let row, let column) where row == yearData.count + 2 && column == 0:
            cell.setup(with: lastYearText)

        case (let row, let column) where row == yearData.count + 2 && column > 0:
            cell.setup(with: String(lastYear[column - 1]))
        // 年度資料
        case (let row, let column) where row > 0 && column == 0:
            let year = yearData[row - 1].key
            cell.setup(with: String(year))

        case (let row, let column) where row > 0 && column > 0:
            let data = yearData[row - 1].value
            cell.setup(with: String(data[column - 1]))

        default:
            break
        }
        return cell
    }
}

class SpreadsheetCell: Cell{
    static let identifier = spreadsheetCellIdentifier
    
    // 顯示文字
    private let label = UILabel()
    
    // 外部設定文字
    public func setup(with text: String){
        label.text = text
        label.textAlignment = .center
        contentView.addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
    
    // 復用時洗白
    override func prepareForReuse() {
        super.prepareForReuse()
        setup(with: "")
    }
}
