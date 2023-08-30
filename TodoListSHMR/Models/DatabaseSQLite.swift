import CocoaLumberjackSwift
import Foundation
import SQLite

final class Database {

    // DB connection
    var connection: Connection?

    // DB names
    private let dbName = "todoItemsDB.sqlite3"
    static let tableName = "todoItems"
    static let table = Table("todoItems")

    // DB expressions
    static let id = Expression<String>("id")
    static let text = Expression<String>("text")
    static let importancy = Expression<String>("importancy")
    static let deadline = Expression<Date?>("deadline")
    static let isCompleted = Expression<Bool>("is_finished")
    static let dateCreated = Expression<Date>("created_at")
    static let dateModified = Expression<Date?>("changed_at")
    static let LastUpdatedBy = Expression<String>("last_updated_by")

    init() {
        // Path
        let path = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(dbName).path
        // Connect or Create
        if FileManager.default.fileExists(atPath: path) {
            // connect
            do {
                self.connection = try Connection(path)
            } catch {
                DDLogError("Error: Connection to db")
            }
        } else {
            // create
            FileManager.default.createFile(
                atPath: path,
                contents: nil,
                attributes: nil
            )
            // connect
            do {
                self.connection = try Connection(path)
            } catch {
                DDLogError("Error: Connection to db")
            }
            // init table
            do {
                try connection?.run(Database.table.create { t in
                    t.column(Database.id)
                    t.column(Database.text)
                    t.column(Database.importancy)
                    t.column(Database.deadline)
                    t.column(Database.isCompleted)
                    t.column(Database.dateCreated)
                    t.column(Database.dateModified)
                })
            } catch {
                DDLogError("Error: Connection to db")
            }
        }
    }
}
