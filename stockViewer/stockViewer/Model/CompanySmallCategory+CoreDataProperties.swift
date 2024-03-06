//
//  CompanySmallCategory+CoreDataProperties.swift
//  stockViewer
//
//  Created by 林裕和 on 2024/3/6.
//
//

import Foundation
import CoreData


extension CompanySmallCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CompanySmallCategory> {
        return NSFetchRequest<CompanySmallCategory>(entityName: "CompanySmallCategory")
    }

    @NSManaged public var number: Int32
    @NSManaged public var smallCategory: String?
    @NSManaged public var company: Company?

}

extension CompanySmallCategory : Identifiable {

}
