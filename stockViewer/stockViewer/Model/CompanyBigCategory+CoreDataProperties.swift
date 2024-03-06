//
//  CompanyBigCategory+CoreDataProperties.swift
//  stockViewer
//
//  Created by 林裕和 on 2024/3/6.
//
//

import Foundation
import CoreData


extension CompanyBigCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CompanyBigCategory> {
        return NSFetchRequest<CompanyBigCategory>(entityName: "CompanyBigCategory")
    }

    @NSManaged public var bigCategory: String?
    @NSManaged public var number: Int32
    @NSManaged public var company: Company?

}

extension CompanyBigCategory : Identifiable {

}
