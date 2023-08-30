import CocoaLumberjackSwift
import Foundation
import SQLite

enum FileCacheErrors: Error {
    case incorrectJson
    case saveItemsError
    case wrongDirectory
    case itemDoesntExist
    case connectionError
}

enum AddedTast {
    case new
    case changed
}

// MARK: - FileCache

class FileCache {

    /// Коллекция TodoItems
    private (set) var todoItems: [TodoItem] = []

    /// База данных
    private (set) var db = Database()

    /// Добавление новой задачи
    func add(item: TodoItem) -> (AddedTast) {
        if let index = todoItems.firstIndex(where: {$0.id == item.id}) {
            todoItems[index] = item
            return AddedTast.changed
        } else {
            todoItems.insert(item, at: 0)
            return AddedTast.new
        }
    }

    /// Изменение списка
    func set(items: [TodoItem]) {
        todoItems = items
    }

    /// Удаление задачи (на основе id)
    func remove(id: String) throws {
        if let index = todoItems.firstIndex(where: {$0.id == id}) {
            todoItems.remove(at: index)
        } else {
            throw FileCacheErrors.itemDoesntExist
        }
    }

    // MARK: - FileCache SQLite

    /// Сохрание всех элементов в БД
    func saveSQLite() throws {
        guard let db = db.connection
        else { throw FileCacheErrors.connectionError }
        do {
            _ = try db.run(Database.table.insertMany(
                self.todoItems.map { item in
                    [
                        Database.id <- item.id,
                        Database.text <- item.text,
                        Database.importancy <- item.importancy.rawValue,
                        Database.deadline <- item.deadline,
                        Database.isCompleted <- item.isCompleted,
                        Database.dateCreated <- item.dateCreated,
                        Database.dateModified <- item.dateModified
                    ]
                }
            ))
        } catch {
            DDLogError("Error: saveSQLite()")
        }
    }

    /// Загрузка элементов из БД
    func loadSQLite() throws {
        guard let db = db.connection
        else { throw FileCacheErrors.connectionError }
        do {
            let items = try db.prepare(Database.table)
            self.todoItems = items.map { item in
                TodoItem(
                    id: item[Database.id],
                    text: item[Database.text],
                    importancy: Importancy(rawValue: item[Database.importancy]) ?? .normal,
                    deadline: item[Database.deadline],
                    isCompleted: item[Database.isCompleted],
                    dateCreated: item[Database.dateCreated],
                    dateModified: item[Database.dateModified]
                )
            }
        } catch {
            DDLogError("Error: loadSQLite()")
        }
    }

    /// Добавление элемента в БД
    func insert(item: TodoItem) throws {
        guard let db = db.connection
        else { throw FileCacheErrors.connectionError }
        _ = try db.run(Database.table.insert(or: .replace,
            Database.id <- item.id,
            Database.text <- item.text,
            Database.importancy <- item.importancy.rawValue,
            Database.deadline <- item.deadline,
            Database.isCompleted <- item.isCompleted,
            Database.dateCreated <- item.dateCreated,
            Database.dateModified <- item.dateModified
        ))
    }

    /// Изменение элемента в БД
    func update(item: TodoItem) throws {
        guard let db = db.connection
        else { throw FileCacheErrors.connectionError }
        let itemInTable = Database.table.filter(Database.id == item.id)
        try db.run(itemInTable.update(
            Database.id <- item.id,
            Database.text <- item.text,
            Database.importancy <- item.importancy.rawValue,
            Database.deadline <- item.deadline,
            Database.isCompleted <- item.isCompleted,
            Database.dateCreated <- item.dateCreated,
            Database.dateModified <- item.dateModified
        ))
    }

    /// Удаление элемента в БД
    func delete(id: String) throws {
        guard let db = db.connection
        else { throw FileCacheErrors.connectionError }
        let itemInTable = Database.table.filter(Database.id == id)
        try db.run(itemInTable.delete())
    }
}
