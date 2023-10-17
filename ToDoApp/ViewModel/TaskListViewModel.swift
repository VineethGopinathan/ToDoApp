//
//  TaskListViewModel.swift
//  ToDoApp
//
//  Created by Vineeth Gopinathan on 12/10/23.
//

import UIKit
import Combine


class TaskListViewModel: ObservableObject {
    
    //MARK: - Variables
    let databaseManager: DatabaseManagerProtocol
    @Published var tasks: [Task] = []
    @Published var users: [User] = []
    
    //Constructor injection - Dependency Injection
    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }
    
    //Connect to database
    func connectDatabase(){
        self.databaseManager.connectDatabase()
    }
    
    //Create User Table
    func createUserTable(){
        let userCount = self.databaseManager.countOfRecords(tableName: Constants.Database.Table.User)
        if userCount == 0 {
            self.databaseManager.createUserTable()
        }
        
    }
    
    //Create Task Table
    func createTaskTable(){
        self.databaseManager.createTaskTable()
    }
    
    //Add users
    func addUsers(user: User, tableName: String){
        let userCount = self.databaseManager.countOfRecords(tableName: Constants.Database.Table.User)
        if userCount < 5 {
            self.databaseManager.insertTable(object: user, tableName: tableName) { status, message, data, error in
                if status {
                    print("Users added")
                } else {
                    print("Users adding failed")
                }
            }
        }
    }
   
   
    //Delete task
    func deleteTask(task: Task, completion: @escaping DatabaseCompletionHandler){
        
        databaseManager.deleteTable(object: task, tableName: Constants.Database.Table.Task, rowId: task.taskId!) { status, message, data, error in
            completion(status,message,data,error)
        }
    }
    
    //Get Users
    func getUsers(){
        databaseManager.readTable(object: User.self, tableName: Constants.Database.Table.User) { status, message, data, error in
            print(data!)
            let userList = data as! [User]
            self.users = userList
            print(message!)
        }
    }
    
    //Get Tasks
    func getTasks(){
        databaseManager.readTable(object: Task.self, tableName: Constants.Database.Table.Task) { status, message, data, error in
            print(data!)
            let taskList = data as! [Task]
            self.tasks = taskList
            print(message!)
        }
    }
    
    //Filter tasks by selected user
    func filterTasks(filterBy:String, filterValue: String, completion: @escaping DatabaseCompletionHandler){
        databaseManager.filterTable(object: Task.self, tableName: Constants.Database.Table.Task, fieldName: filterBy, fieldValue: filterValue) { status, message, data, error in
            print(data!)
            let taskList = data as! [Task]
            self.tasks = taskList
            print(message!)
            completion(status,message,data,error)
        }
    }
    
}
