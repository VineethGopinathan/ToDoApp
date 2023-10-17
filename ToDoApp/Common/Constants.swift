//
//  Constants.swift
//  ToDoApp
//
//  Created by Vineeth Gopinathan on 11/10/23.
//

import Foundation

typealias DatabaseCompletionHandler = (_ status: Bool, _ message: String?, _ data: AnyObject?, _ error: NSError?) -> Void

struct Constants {
    
    //Storyboard Identifiers
    struct Storyboards {
        static let MAIN = "Main"
    }
    
    //Database path
    struct Database{
        static let NAME = "TodoAppDB.sqlite3"
        static var PATH = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        //TABLE DEATILS
        
        struct Table {
            static let User = "User" //Name of Table User
            static let Task = "Task" //Name of Table User
            
        }
        
    }
    
    //TABLE VIEW IDS
    
    struct TableView {
        static var TaskListTableViewCell = "TaskListTableViewCell"
    }
    
    //VIEW CONTROLLER IDS
    
    struct ViewController {
        static var TaskListViewController = "TaskListViewController"
        static var AddTaskViewController = "AddTaskViewController"
    }
}
