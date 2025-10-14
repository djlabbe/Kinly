import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TodoItem.createdAt, order: .reverse) private var items: [TodoItem]
    
    @State private var showingAddItem = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    TodoRowView(item: item)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("To Do")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddTodoView()
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}

struct TodoRowView: View {
    @Bindable var item: TodoItem
    
    var body: some View {
        HStack {
            Button(action: { 
                item.isCompleted = !item.safeIsCompleted
            }) {
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
}

struct AddTodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
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
        modelContext.insert(newItem)
        dismiss()
    }
}

#Preview {
    TodoListView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
