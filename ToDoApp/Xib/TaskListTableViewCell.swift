//
//  TaskListTableViewCell.swift
//  ToDoApp
//
//  Created by Vineeth Gopinathan on 11/10/23.
//

import UIKit

protocol TaskListCellDelegate {
    func deleteTask(task: Task)
    func updateTask(task: Task)
}

class TaskListTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var labelTaskId: UILabel!
    
    @IBOutlet weak var labelTaskName: UILabel!
    
    @IBOutlet weak var labelCreatedby: UILabel!
    
    @IBOutlet weak var labelUpdatedby: UILabel!
    
    @IBOutlet weak var labelCreatedAt: UILabel!
    
    @IBOutlet weak var labelUpdatedat: UILabel!
    
  //MARK: - Variables
    
    var delegate: TaskListCellDelegate?
    var task: Task?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func loadTask(task:Task) {
        self.task = task
        labelTaskId.text = "Task Id : \(task.taskId!)"
        labelTaskName.text = task.name
        labelCreatedby.text = task.createdBy
        labelUpdatedby.text = task.updatedBy
        labelCreatedAt.text = task.createdAt
        labelUpdatedat.text = task.updatedAt
        
    }
    
    //MARK: - IBAction
    
    @IBAction func buttonDeleteAction(_ sender: Any) {
        self.delegate?.deleteTask(task: self.task!)
    }
    
    @IBAction func buttonEditAction(_ sender: Any) {
        self.delegate?.updateTask(task: self.task!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
