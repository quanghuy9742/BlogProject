//
//  ConversationService.swift
//  MessageAppMVP
//
//  Created by Huynh Huy on 11/24/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ConversationService {
    
    // MARK: - Property

    
    // MARK: - Function
    
    func getAllConversation() -> [Conversation] {
        // Fetch request
        do {
            let fetchRequest: NSFetchRequest<Conversation> = NSFetchRequest<Conversation>(entityName: "Conversation")
            return try CoreDataStack.shared.context.fetch(fetchRequest)
    
        } catch let error {
            print("Error = \(error)")
            return [Conversation]()
        }
    }
    
    func deleteConversations(arrConversation: [Conversation]) -> Bool {
        // Fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Conversation")
        fetchRequest.predicate = NSPredicate(format: "self IN %@", arrConversation)
        
        // Batch delete request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try CoreDataStack.shared.context.execute(batchDeleteRequest)
            CoreDataStack.shared.saveContext()
            return true
            
        } catch let error {
            print("Error = \(error)")
            return false
        }
    }
    
    func updateIsRead(value: Bool) -> Bool {
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: CONVERSATION_ENTITY)
        batchUpdateRequest.propertiesToUpdate = [#keyPath(Conversation.isRead) : value]
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        
        do {
            let result = try CoreDataStack.shared.context.execute(batchUpdateRequest) as! NSBatchUpdateResult
            
            // Require persistent store reload only specifies object ID
            let arrObjectID = result.result as! [NSManagedObjectID]
            let changes = [NSUpdatedObjectsKey : arrObjectID]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [CoreDataStack.shared.context])
            CoreDataStack.shared.saveContext()
            return true
            
        } catch let error as NSError {
            print("Error = \(error.userInfo)")
            return false
        }
    }
    
    func search(text: String) -> [Conversation] {
        let fetchRequest = NSFetchRequest<Conversation>(entityName: CONVERSATION_ENTITY)
        fetchRequest.predicate = NSPredicate(format: "ANY messages.content CONTAINS %@", text)
        do {
            return try CoreDataStack.shared.context.fetch(fetchRequest)
        } catch let err as NSError? {
            print("Error = \(err!.userInfo)")
            return [Conversation]()
        }
    }
}
