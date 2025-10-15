import Foundation
import SwiftData

@Model
final class TodoList {
    var id: UUID?
    var name: String?
    var createdAt: Date?
    var colorHex: String? // Store list color for visual distinction
    
    @Relationship(deleteRule: .cascade, inverse: \TodoItem.todoList)
    var items: [TodoItem]?
    
    init(id: UUID = UUID(), name: String, colorHex: String = "007AFF", createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.items = []
    }
    
    // Convenience computed properties
    var safeName: String {
        return name ?? "Untitled List"
    }
    
    var safeId: UUID {
        return id ?? UUID()
    }
    
    var safeCreatedAt: Date {
        return createdAt ?? Date()
    }
    
    var safeColorHex: String {
        return colorHex ?? "007AFF"
    }
    
    var safeItems: [TodoItem] {
        return items ?? []
    }
    
    var incompletedCount: Int {
        return safeItems.filter { !$0.safeIsCompleted }.count
    }
}
