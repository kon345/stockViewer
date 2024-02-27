//
//  Company+CoreDataProperties.swift
//  stockViewer
//
//  Created by 林裕和 on 2024/2/27.
//
//

import Foundation
import CoreData


extension Company {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Company> {
        return NSFetchRequest<Company>(entityName: "Company")
    }

    @NSManaged public var bigCategory: [String]
    @NSManaged public var concept: [String]
    @NSManaged public var lastYear: [Double]
    @NSManaged public var name: String
    @NSManaged public var number: Int32
    @NSManaged public var smallCategory: [String]
    @NSManaged public var thisYear: [String]
    @NSManaged public var yearData: Data

}

extension Company : Identifiable {

}
