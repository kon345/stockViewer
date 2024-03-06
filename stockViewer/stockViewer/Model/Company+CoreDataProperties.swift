//
//  Company+CoreDataProperties.swift
//  stockViewer
//
//  Created by 林裕和 on 2024/3/6.
//
//

import Foundation
import CoreData


extension Company {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Company> {
        return NSFetchRequest<Company>(entityName: "Company")
    }

    @NSManaged public var bigCategory: [String]?
    @NSManaged public var concept: [String]?
    @NSManaged public var lastYear: [Double]?
    @NSManaged public var name: String?
    @NSManaged public var number: Int32
    @NSManaged public var smallCategory: [String]?
    @NSManaged public var thisYear: [String]?
    @NSManaged public var yearData: Data?
    @NSManaged public var companyBig: NSSet?
    @NSManaged public var companySmall: NSSet?

}

// MARK: Generated accessors for companyBig
extension Company {

    @objc(addCompanyBigObject:)
    @NSManaged public func addToCompanyBig(_ value: CompanyBigCategory)

    @objc(removeCompanyBigObject:)
    @NSManaged public func removeFromCompanyBig(_ value: CompanyBigCategory)

    @objc(addCompanyBig:)
    @NSManaged public func addToCompanyBig(_ values: NSSet)

    @objc(removeCompanyBig:)
    @NSManaged public func removeFromCompanyBig(_ values: NSSet)

}

// MARK: Generated accessors for companySmall
extension Company {

    @objc(addCompanySmallObject:)
    @NSManaged public func addToCompanySmall(_ value: CompanySmallCategory)

    @objc(removeCompanySmallObject:)
    @NSManaged public func removeFromCompanySmall(_ value: CompanySmallCategory)

    @objc(addCompanySmall:)
    @NSManaged public func addToCompanySmall(_ values: NSSet)

    @objc(removeCompanySmall:)
    @NSManaged public func removeFromCompanySmall(_ values: NSSet)

}

extension Company : Identifiable {

}
