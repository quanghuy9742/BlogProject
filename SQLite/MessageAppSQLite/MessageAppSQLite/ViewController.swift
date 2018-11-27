//
//  ViewController.swift
//  MessageAppSQLite
//
//  Created by ivc on 27/11/18.
//  Copyright © 2018 org. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController {

    fileprivate var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            // Create SQLite file
            let fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("HeroesDatabase.sqlite")
            
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("Error opening database")
            }
            
            
            
        } catch let error as NSError? {
            print("Error open DB = \(error!.userInfo)")
            return
        }
    }
    
    func createTable() {
        
    }
}

