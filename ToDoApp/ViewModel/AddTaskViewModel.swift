//
//  AddTaskViewModel.swift
//  ToDoApp
//
//  Created by Vineeth Gopinathan on 13/10/23.
//

import UIKit
import Combine



class AddTaskViewModel: ObservableObject{

    //MARK: - Variables
    
    let databaseManager: DatabaseManagerProtocol
    @Published var users: [User] = []
    
    //Constructor injection - Dependency Injection
    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }
    
    //Connect the database
    func connectDatabase(){
        databaseManager.connectDatabase()
    }
    
    //Create the Task Table
    func createTaskTable(){
        self.databaseManager.createTaskTable()
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
    
    //Add Task
    func addTask(task: Task,tableName: String, completion: @escaping DatabaseCompletionHandler){
        databaseManager.insertTable(object: task, tableName: Constants.Database.Table.Task) { status, message, data, error in
            completion(status,message,data,error)
        }
    }
    
    //Update Task
    func updateTask(task: Task, tableName: String, completion: @escaping DatabaseCompletionHandler){
        databaseManager.updateTable(object: task, tableName: tableName, rowId: task.taskId!) { status, message, data, error in
            completion(status,message,data,error)
        }
    }
}
