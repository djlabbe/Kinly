import SwiftUI
import SwiftData

struct ListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TodoList.createdAt, order: .reverse) private var lists: [TodoList]
    
    @State private var showingAddList = false
    
    var body: some View {
        NavigationStack {
            Group {
                if lists.isEmpty {
                    ContentUnavailableView(
                        "No Lists Yet",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Create your first todo list to get started")
                    )
                } else {
                    List {
                        ForEach(lists) { list in
                            NavigationLink(destination: TodoListView(todoList: list)) {
                                ListRowView(list: list)
                            }
                        }
                        .onDelete(perform: deleteLists)
                    }
                }
            }
            .navigationTitle("My Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddList = true }) {
                        Label("Add List", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddList) {
                AddListView()
            }
        }
    }
    
    private func deleteLists(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(lists[index])
        }
    }
}

struct ListRowView: View {
    @Bindable var list: TodoList
    
    @Query private var items: [TodoItem]
    
    init(list: TodoList) {
        self.list = list
        let listID = list.id
        _items = Query(
            filter: #Predicate<TodoItem> { item in
                item.todoList?.id == listID
            }
        )
    }
    
    var incompletedCount: Int {
        items.filter { !$0.safeIsCompleted }.count
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: list.safeColorHex))
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(list.safeName)
                    .font(.headline)
                
                if incompletedCount > 0 {
                    Text("\(incompletedCount) remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text("\(items.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.secondary.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

struct AddListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedColor = "007AFF"
    
    let colors = [
        "007AFF", // Blue
        "FF3B30", // Red
        "34C759", // Green
        "FF9500", // Orange
        "AF52DE", // Purple
        "FF2D55", // Pink
        "5856D6", // Indigo
        "00C7BE", // Teal
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("List Name") {
                    TextField("e.g., Groceries", text: $name)
                }
                
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addList()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addList() {
        let newList = TodoList(name: name, colorHex: selectedColor)
        modelContext.insert(newList)
        dismiss()
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}

#Preview {
    ListsView()
        .modelContainer(for: [TodoList.self, TodoItem.self], inMemory: true)
}
