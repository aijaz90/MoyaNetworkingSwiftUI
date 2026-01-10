//
//  TodoService.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//


// ProductService.swift (Updated)
import Foundation
import Combine
import Moya

public protocol TodoServiceProtocol {
    func getTodoList() -> AnyPublisher<[ToDo], NetworkError>
}

public final class TodoService: TodoServiceProtocol {
  
    private let networkService: NetworkServiceProtocol
    
    public init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    public func getTodoList() -> AnyPublisher<[ToDo], NetworkError> {
        let endpoint = TodoEndpoints.getToDoList
        
        return networkService.request(endpoint)
          
    }
}
