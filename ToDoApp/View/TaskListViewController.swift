//
//  ViewController.swift
//  ToDoApp
//
//  Created by Vineeth Gopinathan on 11/10/23.
//

import UIKit
import Combine



class TaskListViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var tableViewTask: UITableView!
    
    @IBOutlet weak var buttonAddTask: UIButton!
    
    @IBOutlet weak var popupButtonUser: UIButton!
    
    //MARK: - Variables
    let databaseManager = DatabaseManager()
    var userNameList = [String]()
    var menuElements = [UIMenuElement]()
    var noDataLabel = UILabel()
    var selectedUser = String()
    lazy var taskListViewModel: TaskListViewModel = {
        let viewModel = TaskListViewModel(databaseManager: databaseManager)
                return viewModel
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    var tasksList = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        confugureView()
        setupDatabase()
        addUsers()
        loadUsers()
        bindViewModel()
        setupPopupButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        selectedUser = popupButtonUser.currentTitle ?? ""
        if selectedUser == "All users" {
            getTasks()
        } else {
            self.taskListViewModel.filterTasks(filterBy: "created_user_id", filterValue: selectedUser) { status, message, data, error in
                print("Filter by user completed")
            }
        }
        
    }
    //MARK: - Functions
    //Configure Views
    func confugureView(){
        tableViewTask.register(UINib(nibName: Constants.TableView.TaskListTableViewCell, bundle: nil), forCellReuseIdentifier: Constants.TableView.TaskListTableViewCell)
    }
    
    //Set the picker
    func setupPopupButton(){
        //Load users from User table
        let optionClosure = {(action: UIAction) in
            print("Item Selected : \(action.title)")
            if action.title == "All users" {
                self.getTasks()
            } else {
                self.taskListViewModel.filterTasks(filterBy: "created_user_id", filterValue: action.title) { status, message, data, error in
                    print("Filter by user completed")
                }
            }
          
        }
        menuElements.append(UIAction(title: "All users", handler: optionClosure))
        for username in userNameList {
            menuElements.append( UIAction(title: username, handler: optionClosure))
        }
        popupButtonUser.menu = UIMenu(children: menuElements)
        popupButtonUser.showsMenuAsPrimaryAction = true
        popupButtonUser.changesSelectionAsPrimaryAction = true
        
    }
    
    //Initialize Database
    func setupDatabase(){
        taskListViewModel.connectDatabase()
        taskListViewModel.createUserTable()
        taskListViewModel.createTaskTable()
    }
    
    //Add  5 Dummy Users
    func addUsers(){
        for i in 1...5  {
            let user = User()
            //user.userid = Int64(i)
            user.name = "User\(i)"
            user.age = String(Int64.random(in: 20...30))
            print("Users \(i)")
            print(user)
            
            taskListViewModel.addUsers(user: user, tableName: Constants.Database.Table.User)
        }
    }
    
    //Bind View Model with View Controller
    private func bindViewModel() {
        //Binding of user Results
        taskListViewModel.$users.sink { [weak self] userList in
            print(userList)
            self?.userNameList.removeAll()
            for user in userList {
                self?.userNameList.append(user.name ?? "")
            }

        }.store(in: &cancellables)
        
        //Binding of task Results
        taskListViewModel.$tasks.sink { [weak self] taskListData in
            print(taskListData)
            self?.tasksList.removeAll()
            for task in taskListData {
                self?.tasksList.append(task)
            }
        
            self?.tableViewTask.reloadData()
        }.store(in: &cancellables)
    }
    
    //Load users to picker
    func loadUsers(){
        taskListViewModel.getUsers()
    }
    
    //Get Tasks list
    func getTasks(){
        taskListViewModel.getTasks()
    }
    
    //MARK: - IBActions
    
    @IBAction func buttonAddTaskAction(_ sender: Any) {
        let addTaskVC = UIStoryboard.init(name: Constants.Storyboards.MAIN, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewController.AddTaskViewController) as! AddTaskViewController
        addTaskVC.updateFlag = false
        self.navigationController?.pushViewController(addTaskVC, animated: true)
    }
    

}


//MARK: - TableView Delegate
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

//MARK: - TableView Datasource
extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tasksList.count == 0 {
            noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                    noDataLabel.text          = "No active tasks."
                    noDataLabel.textColor     = UIColor.black
                    noDataLabel.textAlignment = .center
                    tableView.backgroundView  = noDataLabel
                    tableView.separatorStyle  = .none
            noDataLabel.isHidden = false
        } else {
            noDataLabel.isHidden = true
            tableView.backgroundView  = nil
        }
        return tasksList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableView.TaskListTableViewCell, for: indexPath) as! TaskListTableViewCell
        let task = tasksList[indexPath.row]
        cell.loadTask(task: task)
        cell.delegate = self
        return cell
        
    }
    
}

//MARK: -  TaskListCellDelegate

extension TaskListViewController: TaskListCellDelegate {
    func deleteTask(task: Task) {
        
        //Showing an alert before delete
        let alertController = UIAlertController(title: "Delete Task", message: "Are you sure you want to delete this task?", preferredStyle: .alert)
               
               // Create OK button
               let OKAction = UIAlertAction(title: "Delete", style: .default) { (action:UIAlertAction!) in
                   
                   self.taskListViewModel.deleteTask(task: task) { status, message, data, error in
                       if status {
                           print("Task Deleted")
                           self.getTasks()
                           self.tableViewTask.reloadData()
                       } else {
                           print("Task Deleted failed")
                       }
                   }
            
               }
               alertController.addAction(OKAction)
               
               // Create Cancel button
               let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                   print("Cancel button tapped");
               }
               alertController.addAction(cancelAction)
               
               // Present Dialog message
               self.present(alertController, animated: true, completion:nil)
        
        
    
    }
    
    func updateTask(task: Task) {
        let addTaskVC = UIStoryboard.init(name: Constants.Storyboards.MAIN, bundle: nil).instantiateViewController(withIdentifier: Constants.ViewController.AddTaskViewController) as! AddTaskViewController
        addTaskVC.updateFlag = true
        addTaskVC.task = task
        self.navigationController?.pushViewController(addTaskVC, animated: true)
    }
}
