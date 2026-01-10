//
//  ContentView.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: TodoListViewModel
    init() {
        let viewModel = DIContainer.shared.resolve(TodoListViewModel.self)!
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                let _ = print("To do loaded viewModel count \(viewModel.todos.count)")
                ProgressView()
            }
           
            List {
                ForEach(viewModel.todos, id: \.id) { todo in
                    Text(todo.title)
                }
            }
            .listStyle(.plain)
            .refreshable {
                viewModel.loadTodos()
            }
        }
        .padding()
        .task {
            viewModel.loadTodos()
        }
    }
}

#Preview {
    ContentView()
}
