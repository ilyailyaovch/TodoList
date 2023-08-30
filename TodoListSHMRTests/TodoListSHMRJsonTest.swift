//
//  TodoListSHMRJsonTest.swift
//  TodoListSHMRTests
//
//  Created by Ilya Ovchinnikov on 17.06.2023.
//

import XCTest
@testable import TodoListSHMR

final class TodoListSHMRJsonTest: XCTestCase {

    func testToDoItemParseJSONWithAllAttributes() throws {
        let json: [String: Any] = [
            "id": "12345",
            "text": "qwe",
            "importancy": "important",
            "deadline": 2023.0,
            "isCompleted": false,
            "dateCreated": 2023.0,
            "dateModified": 2023.0
        ]

        let id = "12345"
        let text = "qwe"
        let isCompleted = false
        let importancy: Importancy = .important
        let deadline = Date(timeIntervalSince1970: 2023.0)
        let dateCreated = Date(timeIntervalSince1970: 2023.0)
        let dateModified = Date(timeIntervalSince1970: 2023.0)

        let item: TodoItem = TodoItem.parse(json: json)!

        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.importancy, importancy)
        XCTAssertEqual(item.deadline, deadline)
        XCTAssertEqual(item.isCompleted, isCompleted)
        XCTAssertEqual(item.dateCreated, dateCreated)
        XCTAssertEqual(item.dateModified, dateModified)
    }

    func testToDoItemParseJSONWithoutOptioanalAttributes() throws {
        let json: [String: Any] = [
            "id": "12345",
            "text": "qwe",
            "importancy": "normal",
            "isCompleted": false,
            "dateCreated": 2023.0
        ]

        let id = "12345"
        let text = "qwe"
        let isCompleted = false
        let importancy: Importancy = .normal
        let dateCreated = Date(timeIntervalSince1970: 2023.0)

        let item = TodoItem.parse(json: json)

        XCTAssertEqual(item?.id, id)
        XCTAssertEqual(item?.text, text)
        XCTAssertEqual(item?.importancy, importancy)
        XCTAssertNil(item?.deadline)
        XCTAssertEqual(item?.isCompleted, isCompleted)
        XCTAssertEqual(item?.dateCreated, dateCreated)
        XCTAssertNil(item?.dateModified)
    }

    func testToDoItemParseJSONWithRequiredAttributes() throws {
        let json: [String: Any] = [
            "id": "12345",
            "text": "qwe",
            "dateCreated": 2023.0
        ]

        let id = "12345"
        let text = "qwe"
        let isCompleted = false
        let importancy: Importancy = .normal
        let dateCreated = Date(timeIntervalSince1970: 2023.0)

        let item = TodoItem.parse(json: json)!

        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.importancy, importancy)
        XCTAssertNil(item.deadline)
        XCTAssertEqual(item.isCompleted, isCompleted)
        XCTAssertEqual(item.dateCreated, dateCreated)
        XCTAssertNil(item.dateModified)
    }

    func testToDoItemParseJSONWithBrokenId() throws {
        let json: [String: Any] = [
            "text": "qwe",
            "importancy": "normal",
            "isCompleted": false,
            "dateCreated": 2023.0
        ]

        let item = TodoItem.parse(json: json)

        XCTAssertNil(item)
    }

    func testToDoItemParseJSONWithBrokentext() throws {
        let json: [String: Any] = [
            "id": "12345",
            "importancy": "normal",
            "isCompleted": false,
            "dateCreated": 2023.0
        ]

        let item = TodoItem.parse(json: json)

        XCTAssertNil(item)
    }

    func testToDoItemParseJSONWithBrokenDateCreated() throws {
        let json: [String: Any] = [
            "id": "12345",
            "text": "qwe",
            "importancy": "normal",
            "isCompleted": false,
            "dateCreated": ""
        ]

        let item = TodoItem.parse(json: json)

        XCTAssertNil(item)
    }

    func testToDoItemFormJSONWithAllAttributes() throws {
        let json: [String: Any] = [
            "id": "12345",
            "text": "qwe",
            "importancy": "important",
            "deadline": 2023.0,
            "isCompleted": false,
            "dateCreated": 2023.0,
            "dateModified": 2023.0
        ]

        let item: TodoItem = TodoItem.parse(json: json)!
        let jsonNew = item.json

        XCTAssertEqual(json.count, (jsonNew as AnyObject).count)
    }

    func testToDoItemFormJSONWithoutOptioanalAttributes() throws {
        let json: [String: Any] = [
            "id": "12345",
            "text": "qwe",
            "importancy": "low",
            "isCompleted": false,
            "dateCreated": 2023.0
        ]

        let item: TodoItem = TodoItem.parse(json: json)!
        let jsonNew = item.json

        XCTAssertEqual(json.count, (jsonNew as AnyObject).count)
    }

    func testToDoItemFormJSONWithoutImportancy() throws {
        let json: [String: Any] = [
            "id": "12345",
            "text": "qwe",
            "importancy": "normal",
            "isCompleted": false,
            "dateCreated": 2023.0
        ]

        let item: TodoItem = TodoItem.parse(json: json)!
        let jsonNew = item.json

        XCTAssertEqual(json.count, 5)
        XCTAssertEqual((jsonNew as AnyObject).count, 4) // no importancy
    }

    func testToDoItemFormJSONWithRequiredAttributes() throws {
        let json: [String: Any] = [
            "id": "12345",
            "text": "qwe",
            "dateCreated": 2023.0
        ]

        let item = TodoItem.parse(json: json)!
        let jsonNew = item.json

        XCTAssertEqual(json.count, 3)
        XCTAssertEqual((jsonNew as AnyObject).count, 4) // isCompleted
    }

    func testAddNewToDoItem() {
        let json: [String: Any] = [
            "id": "12345",
            "text": "qwe",
            "importancy": "normal",
            "isCompleted": false,
            "dateCreated": 2023.0
        ]

        let item: TodoItem = TodoItem.parse(json: json)!
        let fileCache: FileCache = FileCache()

        do {
            try fileCache.add(item: item)
        } catch {

        }

        XCTAssertEqual(fileCache.todoItems[0].id, item.id)
    }

    func testToDoItemSaveJSON() throws {

        let item1: TodoItem = TodoItem(
            id: "111111111122222",
            text: "text",
            importancy: .important,
            deadline: Date(timeIntervalSince1970: 2024.0),
            isCompleted: false,
            dateCreated: Date(timeIntervalSince1970: 2023.0),
            dateModified: Date(timeIntervalSince1970: 2023.0)
        )

        let item2: TodoItem = TodoItem(
            id: "33333333222222",
            text: "Second text",
            importancy: .low,
            deadline: Date(timeIntervalSince1970: 2024.0),
            isCompleted: false,
            dateCreated: Date(timeIntervalSince1970: 2023.0),
            dateModified: Date(timeIntervalSince1970: 2023.0)
        )

        let fileCash = FileCache()
        let fileCash2 = FileCache()
        try fileCash.add(item: item1)
        try fileCash.add(item: item2)
        let fileName = "TestFile"

        do {
            try fileCash.saveItems(to: fileName)
            print("Данные сохранены")
        } catch {
            print("Ошибка при сохранени \(error)")
            return
        }

        do {
            try fileCash2.loadItems(from: fileName)
            print("Данные загружены")
        } catch {
            print("Ошибка при загрузке \(error)")
            return
        }

//        XCTAssertNoThrow(try fileCash.saveItems(to: fileName))

        XCTAssertEqual(fileCash.todoItems[0].id, item1.id)
        XCTAssertEqual(fileCash2.todoItems[0].id, item1.id)
    }
}
