import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    let todoList: TodoList
    
    @Query private var allItems: [TodoItem]
    
    @State private var showingAddItem = false
    
    init(todoList: TodoList) {
        self.todoList = todoList
        // Query items that belong to this list
        let listID = todoList.id
        _allItems = Query(
            filter: #Predicate<TodoItem> { item in
                item.todoList?.id == listID
            },
            sort: \TodoItem.createdAt,
            order: .reverse
        )
    }
    
    var body: some View {
        List {
            ForEach(allItems) { item in
                TodoRowView(item: item)
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle(todoList.safeName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddItem = true }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddTodoView(todoList: todoList)
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(allItems[index])
        }
    }
}

struct TodoRowView: View {
    @Bindable var item: TodoItem
    
    var body: some View {
        HStack {
            Button(action: toggleCompletion) {
                Image(systemName: item.safeIsCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.safeIsCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            Text(item.safeTitle)
                .strikethrough(item.safeIsCompleted)
                .foregroundStyle(item.safeIsCompleted ? .secondary : .primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func toggleCompletion() {
        item.isCompleted?.toggle()
    }
}

struct AddTodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let todoList: TodoList
    
    @State private var title = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Todo title", text: $title)
            }
            .navigationTitle("New Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addItem() {
        let newItem = TodoItem(title: title)
        newItem.todoList = todoList
        modelContext.insert(newItem)
        dismiss()
    }
}
