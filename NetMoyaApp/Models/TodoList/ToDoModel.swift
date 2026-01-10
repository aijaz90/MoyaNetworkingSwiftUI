//
//  ToDoModel.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

import Foundation


public struct ToDoListResponse: Codable {
    public let toDoList: [ToDo]
    public let status: Bool
    public let message: String
  
    public enum CodingKeys: String, CodingKey {
        case toDoList
        case status
        case message
    }
}

public struct ToDo: Codable {
    public let userId: Int
    public let id: Int
    public let title: String
    public let completed: Bool
  
    public enum CodingKeys: String, CodingKey {
        case userId
        case id
        case title
        case completed
    }
}
