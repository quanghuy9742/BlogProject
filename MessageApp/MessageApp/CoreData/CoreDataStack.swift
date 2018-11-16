//
//  CoreDataStack.swift
//  MessageApp
//
//  Created by Huynh Huy on 11/13/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    // MARK: - Property
    var container: NSPersistentContainer!
    lazy var context: NSManagedObjectContext = {
        return self.container.viewContext
    }()
    
    // MARK: - Function
    
    init(modelName: String) {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Error = \(error.localizedDescription)")
            }
        }
        self.container = container
    }
    
    func saveContext() {
        if !self.context.hasChanges {return}
        
        do {
            try self.context.save()
        } catch let error as NSError {
            print("Error = \(error.userInfo)")
        }
    }
}
