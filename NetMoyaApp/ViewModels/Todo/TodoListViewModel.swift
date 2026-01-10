//
//  TodoListViewModel.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// TodoService.swift
import Foundation
import Combine
import Moya


// Usage in ViewModel
@MainActor
class TodoListViewModel: ObservableObject {
    @Published var todos: [ToDo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    
    private let todoService: TodoServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(todoService: TodoServiceProtocol) {
        self.todoService = todoService
        loadTodos()
    }
    
    func loadTodos() {
        isLoading = true
        errorMessage = nil
        
        todoService.getTodoList()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] todos in
                self?.todos = todos
            }
            .store(in: &cancellables)
    }
}
