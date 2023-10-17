//
//  User.swift
//  ToDoApp
//
//  Created by Vineeth Gopinathan on 12/10/23.
//

import UIKit

class User : Codable {
    
    var userid: Int64?
    var name: String?
    var age: String?
    
    enum CodingKeys: String, CodingKey {
        case userid = "user_id"
        case name = "name"
        case age = "age"
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userid = try container.decodeIfPresent(Int64.self, forKey: .userid)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.age = try container.decodeIfPresent(String.self, forKey: .age)
    }
}
