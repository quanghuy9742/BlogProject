//
//  Constant.swift
//  MessageApp
//
//  Created by ivc on 28/11/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import Foundation

class SQLiteQuery {
    
    // Conversation
    static let create_table_conversation = "CREATE TABLE IF NOT EXISTS Conversation (id INTEGER PRIMARY KEY AUTOINCREMENT, imagePath TEXT DEFAULT NULL, isRead INTEGER NOT NULL, name TEXT NOT NULL, phone TEXT NOT NULL)"
    
    static let get_all_conversation = "SELECT * FROM Conversation"
    static let get_conversation_by_phone = "SELECT * FROM Conversation WHERE Conversation.phone = "
    
    static let insert_row_conversation = "INSERT INTO Conversation (imagePath, isRead, name, phone) VALUES (?, ?, ?, ?)"
    
    // Message
    static let create_table_message = "CREATE TABLE IF NOT EXISTS Message (id INTEGER PRIMARY KEY AUTOINCREMENT, conversationId INTEGER NOT NULL, content text NOT NULL, date INTEGER NOT NULL, isReceive INTEGER NOT NULL)"
    
    static let insert_row_message = "INSERT INTO Message (conversationId, content, date, isReceive) VALUES (?, ?, ?, ?)"
}

class Constant {
    
}

