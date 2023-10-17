//
//  Task.swift
//  ToDoApp
//
//  Created by Vineeth Gopinathan on 12/10/23.
//

import UIKit

class Task : Codable {
    
    var taskId: Int64?
    var name: String?
    var description: String?
    var createdAt: String?
    var updatedAt: String?
    var createdBy: String?
    var updatedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case name = "name"
        case description = "description"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_user_id"
        case updatedBy = "updated_user_id"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.taskId = try container.decodeIfPresent(Int64.self, forKey: .taskId)!
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        self.updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
    }
}
