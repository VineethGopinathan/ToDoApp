//
//  AddTaskViewController.swift
//  ToDoApp
//
//  Created by Vineeth Gopinathan on 12/10/23.
//

import UIKit
import Combine

class AddTaskViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var popupButtonUser: UIButton!
    @IBOutlet weak var textViewTitle: UITextView!
    @IBOutlet weak var textViewDescription: UITextView!
    
    @IBOutlet weak var labelNewTask: UILabel!
    @IBOutlet weak var buttonAddTask: UIButton!
    //MARK: - Variables
    let databaseManager = DatabaseManager()

    lazy var addTaskViewModel: AddTaskViewModel = {
              let viewModel = AddTaskViewModel(databaseManager: databaseManager)
              return viewModel
    }()

    private var cancellables: Set<AnyCancellable> = []
    var userNameList = [String]()
    var menuElements = [UIMenuElement]()
    var updateFlag: Bool = false
    var task = Task()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        setupDatabase()
        loadUsers()
        bindViewModel()
        setupPopupButton()
    }
    
    //Setup database
    func setupDatabase(){
        addTaskViewModel.connectDatabase()
        addTaskViewModel.createTaskTable()
    }
    
    //Setup UI
    func setupUI(){
        textViewTitle.delegate = self
        textViewDescription.delegate = self
        
        if updateFlag {
            labelNewTask.text = "Edit Task"
            buttonAddTask.setTitle("Update Task", for: .normal)
            textViewTitle.text = self.task.name
            textViewTitle.textColor = UIColor.black
            textViewDescription.text = self.task.description
            textViewDescription.textColor = UIColor.black
            
            
        } else {
            labelNewTask.text = "New Task"
            buttonAddTask.setTitle("Add Task", for: .normal)
            textViewTitle.text = "Title"
            textViewTitle.textColor = UIColor.lightGray
            textViewDescription.text = "Description"
            textViewDescription.textColor = UIColor.lightGray
        }
    }
    
    //Set the picker
    func setupPopupButton(){
        //Load users from User table
        print(userNameList)
        let optionClosure = {(action: UIAction) in
            print(action.title)
            print("Item Selected")
            
        }
    
        menuElements.append(UIAction(title: "Select User", handler: optionClosure))
        for username in userNameList {
            menuElements.append( UIAction(title: username, handler: optionClosure))
        }
        popupButtonUser.menu = UIMenu(children: menuElements)
        popupButtonUser.showsMenuAsPrimaryAction = true
        popupButtonUser.changesSelectionAsPrimaryAction = true
        
        if updateFlag {
            popupButtonUser.setTitle(task.updatedBy, for: .normal)
        }
    }
    //Load users to picker
    func loadUsers(){
        addTaskViewModel.getUsers()
    }
    
    //Data binding from Viewmodel
    private func bindViewModel() {
               
        //Binding of user Results
        addTaskViewModel.$users.sink { [weak self] userList in
            print(userList)
            self?.userNameList.removeAll()
            for user in userList {
                self?.userNameList.append(user.name ?? "")
            }

        }.store(in: &cancellables)
        
        
    }
    
    //Clear all fields
    func clearAllFields(){
        textViewTitle.text = ""
        textViewDescription.text = ""
        textViewTitle.text = "Title"
        textViewTitle.textColor = UIColor.lightGray
        textViewDescription.text = "Description"
        textViewDescription.textColor = UIColor.lightGray
        
    }
    //MARK: - IBAction

    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func buttonAddTaskAction(_ sender: Any) {
        
        if popupButtonUser.currentTitle == "Select User" {
            
            let alertController = UIAlertController(title: "Select User", message: "Please select a user", preferredStyle: .alert)
            
            // Create OK button
            let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in
                
            }
            alertController.addAction(OKAction)
            
            // Present Dialog message
            self.present(alertController, animated: true, completion:nil)
            
        } else {
            
          //Proceed with Add or update Task
        if updateFlag {
            task.name = textViewTitle.text
            task.description = textViewDescription.text
            task.updatedAt = Utils.getCurrentTimeStamp()
            task.updatedBy = popupButtonUser.currentTitle
            
            //Update task
            addTaskViewModel.updateTask(task: task, tableName: Constants.Database.Table.Task) { status, message, data, error in
                
                if status {
                    print("Task updated")
                    let alertController = UIAlertController(title: "Task Modified", message: "Your task has been modified", preferredStyle: .alert)
                    
                    // Create OK button
                    let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in
                        
                        // Task updated
                        print("Task updated")
                    }
                    alertController.addAction(OKAction)
                    
                    // Present Dialog message
                    self.present(alertController, animated: true, completion:nil)
                    
                    
                } else {
                    print("Task update failed")
                }
            }
            
        } else {
            
            let task = Task()
            task.name = textViewTitle.text
            task.description = textViewDescription.text
            task.createdAt = Utils.getCurrentTimeStamp()
            task.updatedAt = Utils.getCurrentTimeStamp()
            task.createdBy = popupButtonUser.currentTitle
            task.updatedBy = popupButtonUser.currentTitle
            
            //Add task
            addTaskViewModel.addTask(task: task, tableName: Constants.Database.Table.Task) { status, message, data, error in
                
                if status {
                    print("Task inserted")
                    let alertController = UIAlertController(title: "Task Added", message: "Your task has been added", preferredStyle: .alert)
                    
                    // Create OK button
                    let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in
                        
                        // Task updated
                        print("Task added")
                        self.clearAllFields()
                    }
                    alertController.addAction(OKAction)
                    
                    // Present Dialog message
                    self.present(alertController, animated: true, completion:nil)
                    
                } else{
                    print("Task adding failed")
                }
            }
            
            
        }
        
      }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - TextView Delegate
extension AddTaskViewController : UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textViewTitle.text.isEmpty {
            textViewTitle.text = "Title"
            textViewTitle.textColor = UIColor.lightGray
        }
        if textViewDescription.text.isEmpty {
            textViewDescription.text = "Description"
            textViewDescription.textColor = UIColor.lightGray
        }
    }
    
    
}
