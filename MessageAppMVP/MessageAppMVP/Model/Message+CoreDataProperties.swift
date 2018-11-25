//
//  Message+CoreDataProperties.swift
//  MessageAppMVP
//
//  Created by Huynh Huy on 11/24/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var isReceive: Bool

}
