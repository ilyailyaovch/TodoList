import Foundation
import UIKit

enum Importancy: String {
    case important = "important"
    case normal = "basic"
    case low = "low"
}

private enum Keys {
    static let kId = "id"
    static let kText = "text"
    static let kImportancy = "importance"
    static let kDeadline = "deadline"
    static let kIsCompleted = "done"
    static let kColor = "color"
    static let kDateCreated = "created_at"
    static let kDdateModified = "changed_at"
    static let kLastUpdatedBy = "last_updated_by"
}

// MARK: - TodoItem

struct TodoItem {

    let id: String
    let text: String
    let importancy: Importancy
    let deadline: Date?
    let isCompleted: Bool
    let dateCreated: Date
    let dateModified: Date?

    init(id: String = UUID().uuidString,
         text: String,
         importancy: Importancy = Importancy.normal,
         deadline: Date? = nil,
         isCompleted: Bool = false,
         dateCreated: Date = Date(),
         dateModified: Date? = nil) {
        self.id = id
        self.text = text
        self.importancy = importancy
        self.deadline = deadline
        self.isCompleted = isCompleted
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
}

// MARK: - TodoItem Json

extension TodoItem {

    /// Разбор json
    static func parse(json: Any) -> TodoItem? {
        guard let jsonObject = json as? [String: Any] else { return nil }
        guard
            let id = jsonObject[Keys.kId] as? String,
            let text = jsonObject[Keys.kText] as? String,
            let dateCreated = (jsonObject[Keys.kDateCreated] as? Double)
                .flatMap({ Date(timeIntervalSince1970: TimeInterval($0)) })
        else { return nil }

        let importancy = (jsonObject[Keys.kImportancy] as? String)
            .flatMap(Importancy.init(rawValue:)) ?? .normal

        let isCompleted = (jsonObject[Keys.kIsCompleted] as? Bool) ?? false

        var deadline: Date?
        if let deadlineDouble = jsonObject[Keys.kDeadline] as? Double {
            deadline = Date(timeIntervalSince1970: deadlineDouble)
        }

        var dateModified: Date?
        if let dateModifiedDouble = jsonObject[Keys.kDdateModified] as? Double {
            dateModified = Date(timeIntervalSince1970: dateModifiedDouble)
        }

        return TodoItem(
            id: id,
            text: text,
            importancy: importancy,
            deadline: deadline,
            isCompleted: isCompleted,
            dateCreated: dateCreated,
            dateModified: dateModified
        )
    }

    /// Формирования json
    var json: Any {
        var jsonDict: [String: Any] = [:]
        jsonDict[Keys.kId] = self.id
        jsonDict[Keys.kText] = self.text
        jsonDict[Keys.kImportancy] = importancy.rawValue
        jsonDict[Keys.kIsCompleted] = self.isCompleted
        jsonDict[Keys.kDateCreated] = Int(dateCreated.timeIntervalSince1970)
        jsonDict[Keys.kLastUpdatedBy] = UIDevice.current.identifierForVendor!.uuidString

        if let deadline = self.deadline {
            jsonDict[Keys.kDeadline] = Int(deadline.timeIntervalSince1970)
        }
        if let dateModified = self.dateModified {
            jsonDict[Keys.kDdateModified] = Int(dateModified.timeIntervalSince1970)
        } else {
            jsonDict[Keys.kDdateModified] = Int(dateCreated.timeIntervalSince1970)
        }
        return jsonDict
    }
}

// MARK: - TodoItem Csv

extension TodoItem {

    /// Разбор csv
    static func parse(csv: String) -> TodoItem? {

        let csvArr : [String] = csv.components(separatedBy: ";")

        let id = csvArr[0]
        if id.isEmpty { return nil }

        let text = csvArr[1]
        if text.isEmpty { return nil }

        let importancyString = csvArr[2]
        var importancy: Importancy = Importancy.normal
        if let rightcase = Importancy(rawValue: importancyString) {
            importancy = rightcase
        }

        var deadline: Date?
        let deadlineString = csvArr[3]
        if let deadlineDouble = Double(deadlineString) {
            deadline = Date(timeIntervalSince1970: deadlineDouble)
        }

        let isCompleted = Bool(String(csvArr[4])) ?? false

        guard
            let dateCreatedDouble = Double(csvArr[5])
        else {return nil}
        let dateCreated = Date(timeIntervalSince1970: dateCreatedDouble)

        var dateModified: Date?
        let dateModifiedString = String(csvArr[6])
        if let dateModifiedDouble = Double(dateModifiedString) {
            dateModified = Date(timeIntervalSince1970: dateModifiedDouble)
        }

        return TodoItem(
            id: id,
            text: text,
            importancy: importancy,
            deadline: deadline,
            isCompleted: isCompleted,
            dateCreated: dateCreated,
            dateModified: dateModified
        )
    }

    /// Формирования csv
    var csv: String {
        var csvString: String = ""
        csvString.append(self.id + ";")
        csvString.append(self.text + ";")
        csvString.append(self.importancy == .normal ? "" : self.importancy.rawValue)
        csvString.append(";")
        if let deadline = deadline {
            csvString.append("\(deadline.timeIntervalSince1970)")
        }
        csvString.append(";")
        csvString.append(String(self.isCompleted))
        csvString.append(";")
        csvString.append("\(String(describing: self.dateCreated.timeIntervalSince1970))")
        csvString.append(";")
        if let dateModified = dateModified {
            csvString.append("\(dateModified.timeIntervalSince1970)")
        }
        return csvString
    }
}
