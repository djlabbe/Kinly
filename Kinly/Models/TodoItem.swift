import Foundation
import SwiftData

@Model
final class TodoItem {
    var id: UUID?
    var title: String?
    var isCompleted: Bool?
    var createdAt: Date?
    
    @Relationship var todoList: TodoList?
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
    
    // Convenience computed properties for safer access
    var safeTitle: String {
        return title ?? ""
    }
    
    var safeIsCompleted: Bool {
        return isCompleted ?? false
    }
    
    var safeCreatedAt: Date {
        return createdAt ?? Date()
    }
    
    var safeId: UUID {
        return id ?? UUID()
    }
}
