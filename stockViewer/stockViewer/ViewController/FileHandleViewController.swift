//
//  FileHandleViewController.swift
//  stockViewer
//
//  Created by 林裕和 on 2024/1/16.

import UIKit


class FileHandleViewController: UIViewController {

    @IBOutlet weak var importFileBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let home = URL(filePath: NSHomeDirectory())
        print(home)
    }
    
    @IBAction func importFileBtnPressed(_ sender: Any) {
        openFilePicker()
    }
    
    @IBAction func deleteAllBtnPressed(_ sender: Any) {
        FileHelper.shared.deleteAllExistingData()
    }
    
    func openFilePicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: acceptTypes, asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
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

extension FileHandleViewController: UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        do {
            for url in urls {
                // 存取權限
                let accessingAuth = url.startAccessingSecurityScopedResource()
                defer {
                    if accessingAuth {
                        url.stopAccessingSecurityScopedResource() }
                }
                // 操作檔案
//                let fileName = url.lastPathComponent
//                let resourceValue = try url.resourceValues(forKeys: [.fileSizeKey])
//                print(fileName)
                let content = try String(contentsOf: url, encoding: .utf8)
                let companyDataList = FileHelper.shared.parseCSVData(csv: content)
                
                FileHelper.shared.saveCompany(companies: companyDataList)
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
}
