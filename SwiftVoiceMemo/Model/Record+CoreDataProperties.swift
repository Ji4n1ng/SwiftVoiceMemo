//
//  Record+CoreDataProperties.swift
//  SwiftVoiceMemo
//
//  Created by 王嘉宁 on 2017/9/30.
//  Copyright © 2017年 jianing. All rights reserved.
//
//

import Foundation
import CoreData


extension Record {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var date: NSDate
    @NSManaged public var duration: Double

}
