//
//  CompanyBigCategory+CoreDataProperties.swift
//  stockViewer
//
//  Created by 林裕和 on 2024/2/27.
//
//

import Foundation
import CoreData


extension CompanyBigCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CompanyBigCategory> {
        return NSFetchRequest<CompanyBigCategory>(entityName: "CompanyBigCategory")
    }

    @NSManaged public var number: Int32
    @NSManaged public var bigCategory: String

}

extension CompanyBigCategory : Identifiable {

}
