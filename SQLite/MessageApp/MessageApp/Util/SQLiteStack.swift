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
    
    // MARK: - Property
    
    static let shared = SQLiteStack()

    fileprivate let fileName = "database.db3"
    fileprivate var fileURL: URL?
    
    fileprivate var db: OpaquePointer?
    
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
    
    // MARK: - Common
    
    func createTable(query: String) -> Bool {
        // Open DB
        if !self.openDB() {return false}
        
        // Unwrap db
        guard let db = db else {return false}
        
        // Create excute
        if sqlite3_exec(db, query, nil, nil, nil) != SQLITE_OK {
            print("Failed to create table with error = \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        
        // Close
        sqlite3_close(db)
        
        return true
    }
    
    func isExist(table: String) -> Bool {
        // Open DB
        if !self.openDB() {return false}
        
        // Unwrap db
        guard let db = db else {return false}
        
        // Statement
        var stmt: OpaquePointer?
        
        // Prepare
        if sqlite3_prepare_v2(db, "SELECT name FROM sqlite_master WHERE type='table' AND name='\(table)'", -1, &stmt, nil) != SQLITE_OK {
            print("Failed to prepare with error = \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        
        // Check exist
        while sqlite3_step(stmt) != SQLITE_ROW {
            print("Failed to get name of table with error = \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        
        // Finalize
        sqlite3_finalize(stmt)
        sqlite3_close(db)
        
        return true
    }
    
    // MARK: - Conversation
    
    func readConversations() -> [Conversation]? {
        // Open DB
        if !self.openDB() {return nil}
        
        // Unwrap db
        guard let db = db else {return nil}
        
        // Statement
        var stmt: OpaquePointer?
        
        // Read excute
        var arrConversation = [Conversation]()
        
        // Prepare
        if sqlite3_prepare(db, SQLiteQuery.get_all_conversation, -1, &stmt, nil) != SQLITE_OK {
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
        
        // Release
        sqlite3_finalize(stmt)
        sqlite3_close(db)
        
        return arrConversation
    }
    
    func insertConversation(conversation: Conversation) -> Int? {
        // Open DB
        if !self.openDB() {return nil}
        
        // Unwrap db
        guard let db = db else {return nil}
        
        // Statement
        var stmt: OpaquePointer?
        
        // Prepare the query
        if sqlite3_prepare(db, SQLiteQuery.insert_row_conversation, -1, &stmt, nil) != SQLITE_OK {
            print("Failed to prepare query with error = \(String(cString: sqlite3_errmsg(db)))")
            return nil
        }
        
        // Binding imagePath
        if sqlite3_bind_text(stmt, 1, conversation.imagePath, -1, nil) != SQLITE_OK {
            print("Failed to bind imagePath: \(String(cString: sqlite3_errmsg(stmt)))")
            return nil
        }
        
        // Binding isRead
        if sqlite3_bind_int(stmt, 2, conversation.isRead) != SQLITE_OK {
            print("Failed to bind isRead: \(String(cString: sqlite3_errmsg(stmt)))")
            return nil
        }
        
        // Binding name
        if sqlite3_bind_text(stmt, 3, conversation.name, -1, nil) != SQLITE_OK {
            print("Failed to bind isRead: \(String(cString: sqlite3_errmsg(stmt)))")
            return nil
        }
        
        // Binding phone
        if sqlite3_bind_text(stmt, 4, conversation.phone, -1, nil) != SQLITE_OK {
            print("Failed to bind isRead: \(String(cString: sqlite3_errmsg(stmt)))")
            return nil
        }
        
        // Insert row
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("Failed to insert row with error = \(String(cString: sqlite3_errmsg(db)))")
            return nil
        }
        
        let lastInsertedID = Int(sqlite3_last_insert_rowid(db))
        
        // Release
        sqlite3_finalize(stmt)
        sqlite3_close(db)
        
        return lastInsertedID
    }
    
    // MARK: - Message
    
    func insertMessage(message: Message) -> Int? {
        // Open DB
        if !self.openDB() {return nil}
        
        // Unwrap db
        guard let db = db else {return nil}
        
        // Statement
        var stmt: OpaquePointer?
        
        // Prepare the query
        if sqlite3_prepare(db, SQLiteQuery.insert_row_message, -1, &stmt, nil) != SQLITE_OK {
            print("Failed to prepare query with error = \(String(cString: sqlite3_errmsg(db)))")
            return nil
        }
        
        // Binding conversationId
        if sqlite3_bind_int(stmt, 1, Int32(message.conversationId)) != SQLITE_OK {
            print("Failed to bind conversation ID: \(String(cString: sqlite3_errmsg(stmt)))")
            return nil
        }
        
        // Binding content
        if sqlite3_bind_text(stmt, 2, message.content!, -1, nil) != SQLITE_OK {
            print("Failed to bind content: \(String(cString: sqlite3_errmsg(stmt)))")
            return nil
        }
        
        // Binding date
        if sqlite3_bind_int(stmt, 3, Helper.convertDateToTimestamp(message.date)) != SQLITE_OK {
            print("Failed to bind date: \(String(cString: sqlite3_errmsg(stmt)))")
            return nil
        }
        
        // Binding isReceive
        if sqlite3_bind_int(stmt, 4, Int32(message.isReceive == true ? 1 : 0)) != SQLITE_OK {
            print("Failed to bind isReceive: \(String(cString: sqlite3_errmsg(stmt)))")
            return nil
        }
        
        // Insert row
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("Failed to insert row with error = \(String(cString: sqlite3_errmsg(db)))")
            return nil
        }
        
        let lastInsertedID = Int(sqlite3_last_insert_rowid(db))
        
        // Finalize
        sqlite3_finalize(stmt)
        sqlite3_close(db)
        
        return lastInsertedID
    }
}

