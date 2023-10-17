//
//  DatabaseManager.swift
//  ToDoApp
//
//  Created by Vineeth Gopinathan on 11/10/23.
//

import UIKit
import SQLite

protocol DatabaseManagerProtocol{
    func connectDatabase()
    func createUserTable()
    func createTaskTable()
    func countOfRecords(tableName: String) -> Int
    func insertTable<T>(object: T, tableName: String, completion: @escaping DatabaseCompletionHandler) where T : Codable
    func readTable<T>(object: T.Type, tableName: String, completion: @escaping DatabaseCompletionHandler) where T : Codable
    func filterTable<T>(object: T.Type, tableName: String, fieldName:String, fieldValue:String, completion: @escaping DatabaseCompletionHandler) where T : Codable
    func deleteTable<T>(object: T, tableName: String, rowId: Int64, completion: @escaping DatabaseCompletionHandler)
    func updateTable<T>(object: T, tableName: String, rowId: Int64, completion: @escaping DatabaseCompletionHandler) where T : Codable
}

class DatabaseManager: DatabaseManagerProtocol {
  
    var database = try! Connection()
        
    //MARK: - Create and Connect Database
    
    func connectDatabase(){
        let dbPath = Constants.Database.PATH
        let dbName = Constants.Database.NAME
        
        do {
            database = try Connection("\(dbPath)/\(dbName)")
            print("Database Created at : \(Connection.Location.inMemory)")
            print("Database path :\(dbPath)")
        }catch {
            print("Error creating database..")
            print(error)
        }
        
    }
    
    //MARK: - Create the table - User
    func createUserTable(){
        do{
            let userTable = Table(Constants.Database.Table.User)
            let userId = Expression<Int64>("user_id")
            let name = Expression<String?>("name")
            let age = Expression<String>("age")
            
            try database.run(userTable.create(ifNotExists: true) { t in
                t.column(userId, primaryKey: .autoincrement)
                   t.column(name)
                   t.column(age)
                print("User table created.")
            })
            
        } catch {
            print("Error creating table User..")
            print(error)
        }
    }
    
    //MARK: - Create the table - Task
    func createTaskTable(){
        do{
            let taskTable = Table(Constants.Database.Table.Task)
            let taskId = Expression<Int64>("task_id")
            let name = Expression<String?>("name")
            let description = Expression<String>("description")
            let createdAt = Expression<String>("created_at")
            let updatedAt = Expression<String>("updated_at")
            let createdUserId = Expression<String>("created_user_id")
            let updatedUserId = Expression<String>("updated_user_id")
            
            
            try database.run(taskTable.create(ifNotExists: true) { t in
                t.column(taskId, primaryKey: .autoincrement)
                   t.column(name)
                   t.column(description)
                t.column(createdAt)
                t.column(updatedAt)
                t.column(createdUserId)
                t.column(updatedUserId)
                print("Task table created.")
            })
            
        } catch {
            print("Error creating table Task..")
            print(error)
        }
    }
    
    //MARK: - Insert into Table
    
    func insertTable<T>(object: T, tableName: String, completion: @escaping DatabaseCompletionHandler) where T : Codable {
        do{
            let table = Table(tableName)
            try database.run(table.insert(object))
            print("\(tableName) table - Row inserted")
            completion(true,"Success",nil,nil)
        } catch {
            print("Error inserting table \(tableName)..")
            print(error)
            completion(false,"Failed",nil,nil)
        }
        
        print("Database Object INSERT  \(database)")
    }
    
    //MARK: - Update from table
    
    func updateTable<T>(object: T, tableName: String, rowId: Int64, completion: @escaping DatabaseCompletionHandler) where T : Codable {
        do{
            let table = Table(tableName)
            let taskId = Expression<Int64>("task_id")
            try database.run(table.filter(taskId == rowId).update(object))
            print("Selected row from \(tableName) updated.")
            completion(true,"Success",nil,nil)
            
        } catch {
            print("Error updating table \(tableName)..")
            print(error)
            completion(false,"Failed",nil,nil)
        }
    }
    
    //MARK: - Delete from table
    
    func deleteTable<T>(object: T, tableName: String, rowId: Int64, completion: @escaping DatabaseCompletionHandler) {
        do{
            let table = Table(tableName)
            let taskId = Expression<Int64>("task_id")
            let result = table.filter(taskId == rowId)
            try database.run(result.delete())
            print("Selected row from \(tableName) deleted.")
            completion(true,"Success",nil,nil)
        } catch {
            print("Error deleting table \(tableName)..")
            print(error)
            completion(false,"Failed",nil,nil)
        }
    }
    
    //MARK: - Read from Table
    
    func readTable<T>(object: T.Type, tableName: String, completion: @escaping DatabaseCompletionHandler) where T : Codable {
        do{
    
            print("Database Object READ :  \(database)")
            
            let table = Table(tableName)
            let decoded: [T] = try database.prepare(table).map { row in
                return try row.decode()
            }
            print(decoded)
            completion(true,"Success",decoded as AnyObject,nil)
        } catch {
            print("Error reading table \(tableName)..")
            print(error)
        }
    }

    //MARK: - Read all data by filter from Table
    func filterTable<T>(object: T.Type, tableName: String, fieldName:String, fieldValue:String, completion: @escaping DatabaseCompletionHandler) where T : Codable {
        do{
            print("Database Object Filter :  \(database)")
            let table = Table(tableName)
            let fieldName = Expression<String?>(fieldName)
            let decoded: [T] = try database.prepare(table.filter(fieldName == fieldValue)).map { row in
                return try row.decode()
            }
            print(decoded)
            completion(true,"Success",decoded as AnyObject,nil)
        } catch {
            print("Error filtering table \(tableName)..")
            print(error)
        }
    }
    
    
    
    //MARK: - Count of Table Records
    func countOfRecords(tableName: String) -> Int {
        do{
            let table = Table(tableName)
            let count = try database.scalar(table.count)
            return count
        } catch {
            print("Error reading table count..")
            print(error)
        }
        return 0
    }
    
}
