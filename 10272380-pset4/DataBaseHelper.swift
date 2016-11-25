//
//  DataBaseHelper.swift
//  10272380-pset4
//
//  Created by Quinten van der Post on 22/11/2016.
//  Copyright © 2016 Quinten van der Post. All rights reserved.
//

import Foundation
import SQLite

class DataBaseHelper {
    
    private let todo = Table("todo")
    
    private let id = Expression<Int64>("id")
    private let rowId = Expression<Int64>("id")
    private let title = Expression<String>("title")
    private let description = Expression<String>("description")
    private let done = Expression<Bool>("done")
    
    private var db: Connection?
    
    init?() {
        do {
            try setupDatabase()
        } catch {
            print(error)
            return nil
        }
    }
    
    private func setupDatabase() throws {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            db = try Connection("\(path)/db.sqlite3")
            try createTable()
        } catch {
            throw error
        }
    }
    
    private func createTable() throws {
        
        do {
            try db!.run(todo.create(ifNotExists: true) {
                table in
                
                table.column(id, primaryKey: .autoincrement)
                table.column(title)
                table.column(description)
                table.column(done)
            })
        } catch {
            throw error
        }
    }
    
    func create(title: String, description: String, done: Bool) throws {
        
        let insert = todo.insert(self.title <- title, self.description <- description, self.done <- done)
        
        do {
            let rowId = try db!.run(insert)
            print("Inserted at \(rowId)")
        } catch {
            throw error
        }
    }
    
    
    func read(keyword: String) throws -> Array<Row>? {
        do {
            let all = Array(try db!.prepare(todo))
            print(all[0][title])
            return all
        } catch {
            throw error
        }
    }
    
    func readIndex(index: IndexPath) throws -> [String : Any]? {
        
        do {
            let all = Array(try db!.prepare(todo))
            let result = [
                "title" : all[index.row][title],
                "desc" : all[index.row][description],
                "done" : all[index.row][done]
            ] as [String : Any]
            return result
        } catch {
            throw error
        }
    }
    
    func countRows() throws -> Int? {
        let count = try db?.scalar(todo.count)
        
        return count
    }
    
    func deleteIndex(index: Int) throws {
        
        do {
            let all = Array(try db!.prepare(todo))
            let deletionId = all[index][id]
            
            let deletion = todo.filter(id == deletionId)
            
            if try db!.run(deletion.delete()) > 0 {
                print("Deletion succesful")
            }
        } catch {
            throw error
        }
    }
    
    func updateCheck(index: Int) throws {
        do {
            let all = Array(try db!.prepare(todo))
            let checkId = all[index][id]
            
            let check = todo.filter(id == checkId)
            
            for row in try db!.prepare(check) {
                if row[done] == true {
                    if try db!.run(check.update(self.done <- false)) > 0 {
                    }
                }
                else {
                    if try db!.run(check.update(self.done <- true)) > 0 {
                    }
                }
                
            }
        }
    }
    
}







