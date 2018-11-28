//
//  SQLiteStack.swift
//  MessageApp
//
//  Created by ivc on 28/11/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import Foundation
import SQLite3

class SQLiteStack {
    
    static let shared = SQLiteStack()

    fileprivate let fileName = "database.db3"
    fileprivate var fileURL: URL?
    
    fileprivate var db: OpaquePointer?
    fileprivate var stmt: OpaquePointer?
    
    init() {
        do {
            self.fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)
            
        } catch let err as NSError {
            print("Error = \(err.userInfo)")
        }
    }
    
    func openDB() -> Bool {
        // Unwrap URL
        guard let url = fileURL else {return false}
        
        // Open excute
        if sqlite3_open(url.absoluteString, &db) != SQLITE_OK {
            print("Failed to open DB with error = \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        return true
    }
    
    func createTable(query: String) -> Bool {
        // Unwrap db
        guard let db = db else {return false}
        
        // Create excute
        if sqlite3_exec(db, query, nil, nil, nil) != SQLITE_OK {
            print("Failed to create table with error = \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        return true
    }
    
    func readConversations(query: String) -> [Conversation]? {
        // Open DB
        if !self.openDB() {return nil}
        
        // Unwrap db
        guard let db = db else {return nil}
        
        // Read excute
        var arrConversation = [Conversation]()
        
        // Prepare
        if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK {
            print("Failed to read conversation = \(String(cString: sqlite3_errmsg(db)))")
            return nil
        }
        
        // Record
        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = sqlite3_column_int(stmt, 0)
            let imagePath = String(cString: sqlite3_column_text(stmt, 1))
            let isRead = sqlite3_column_int(stmt, 2)
            let name = String(cString: sqlite3_column_text(stmt, 3))
            let phone = String(cString: sqlite3_column_text(stmt, 4))
            
            let conversation = Conversation(id: id, name: name, phone: phone, isRead: isRead, imagePath: imagePath)
            arrConversation.append(conversation)
        }
        
        return arrConversation
    }
    
    func insertConversation(conversation: Conversation) -> Bool {
        // Unwrap db
        guard let db = db else {return false}
        
        // Prepare the query
        if sqlite3_prepare(db, SQLiteQuery.insert_row_conversation, -1, &stmt, nil) != SQLITE_OK {
            print("Failed to prepare query with error = \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        
        // Binding imagePath
        if sqlite3_bind_text(stmt, 1, conversation.imagePath, -1, nil) != SQLITE_OK {
            print("Failed to bind imagePath: \(String(cString: sqlite3_errmsg(stmt)))")
            return false
        }
        
        // Binding isRead
        if sqlite3_bind_int(stmt, 2, conversation.isRead) != SQLITE_OK {
            print("Failed to bind isRead: \(String(cString: sqlite3_errmsg(stmt)))")
            return false
        }
        
        // Binding name
        if sqlite3_bind_text(stmt, 3, conversation.name, -1, nil) != SQLITE_OK {
            print("Failed to bind isRead: \(String(cString: sqlite3_errmsg(stmt)))")
            return false
        }
        
        // Binding phone
        if sqlite3_bind_text(stmt, 4, conversation.phone, -1, nil) != SQLITE_OK {
            print("Failed to bind isRead: \(String(cString: sqlite3_errmsg(stmt)))")
            return false
        }
        
        // Insert row
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("Failed to insert row with error = \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        return true
    }
    
    func insertMessage(message: Message) -> Bool {
        // Unwrap db
        guard let db = db else {return false}
        
        // Prepare the query
        if sqlite3_prepare(db, SQLiteQuery.insert_row_message, -1, &stmt, nil) != SQLITE_OK {
            print("Failed to prepare query with error = \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        
        // Binding content
        if sqlite3_bind_text(stmt, 1, message.content, -1, nil) != SQLITE_OK {
            print("Failed to bind content: \(String(cString: sqlite3_errmsg(stmt)))")
            return false
        }
        
        // Binding date
        if sqlite3_bind_int(stmt, 2, Helper.convertDateToTimestamp(message.date)) != SQLITE_OK {
            print("Failed to bind date: \(String(cString: sqlite3_errmsg(stmt)))")
            return false
        }
        
        // Binding isReceive
        if sqlite3_bind_int(stmt, 3, message.isReceive == true ? 1 : 0) != SQLITE_OK {
            print("Failed to bind isReceive: \(String(cString: sqlite3_errmsg(stmt)))")
            return false
        }
        
        // Insert row
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("Failed to insert row with error = \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        return true
    }
}

