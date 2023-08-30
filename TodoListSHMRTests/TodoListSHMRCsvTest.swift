//
//  TodoListSHMRCsvTest.swift
//  TodoListSHMRTests
//
//  Created by Ilya Ovchinnikov on 17.06.2023.
//

import XCTest
@testable import TodoListSHMR

final class TodoListSHMRCSVTest: XCTestCase {

    func testToDoItemParseCSVWithAllAttributes() throws {
        let csv: String = "111222;Text here;important;2023.0;false;2023.0;2023.0"

        let id = "111222"
        let text = "Text here"
        let isCompleted = false
        let importancy: Importancy = .important
        let deadline = Date(timeIntervalSince1970: 2023.0)
        let dateCreated = Date(timeIntervalSince1970: 2023.0)
        let dateModified = Date(timeIntervalSince1970: 2023.0)

        let item: TodoItem = TodoItem.parse(csv: csv)!

        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.importancy, importancy)
        XCTAssertEqual(item.deadline, deadline)
        XCTAssertEqual(item.isCompleted, isCompleted)
        XCTAssertEqual(item.dateCreated, dateCreated)
        XCTAssertEqual(item.dateModified, dateModified)
    }

    func testToDoItemParseCSVWithoutOptioanalAttributes() throws {
        let csv: String = "111222;Text here;low;;false;2023.0;"

        let id = "111222"
        let text = "Text here"
        let isCompleted = false
        let importancy: Importancy = .low
        let dateCreated = Date(timeIntervalSince1970: 2023.0)

        let item: TodoItem = TodoItem.parse(csv: csv)!

        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.importancy, importancy)
        XCTAssertNil(item.deadline)
        XCTAssertEqual(item.isCompleted, isCompleted)
        XCTAssertEqual(item.dateCreated, dateCreated)
        XCTAssertNil(item.dateModified)
    }

    func testToDoItemParseCSVWithRequiredAttributes() throws {
        let csv: String = "111222;Text here;;;;2023.0;"

        let id = "111222"
        let text = "Text here"
        let isCompleted = false
        let importancy: Importancy = .normal
        let dateCreated = Date(timeIntervalSince1970: 2023.0)

        let item: TodoItem = TodoItem.parse(csv: csv)!

        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.importancy, importancy)
        XCTAssertNil(item.deadline)
        XCTAssertEqual(item.isCompleted, isCompleted)
        XCTAssertEqual(item.dateCreated, dateCreated)
        XCTAssertNil(item.dateModified)
    }

    func testToDoItemParseCSVWithBrokenId() throws {
        let j: String = ";Text here;;;false;2023.0;"

        let item = TodoItem.parse(csv: j)

        XCTAssertNil(item)
    }

    func testToDoItemParseCSVWithBrokenText() throws {
        let csv: String = "111;;;;false;2023.0;"

        let item = TodoItem.parse(csv: csv)

        XCTAssertNil(item)
    }

    func testToDoItemParseCSVWithBrokenDateCreated() throws {
        let csv: String = "111;Text here;;;false;;"

        let item = TodoItem.parse(csv: csv)

        XCTAssertNil(item)
    }

    func testToDoItemFormCSVWithAllAttributes() throws {
        let csv: String = "111222;Text here;important;2023.0;false;2023.0;2023.0"

        let item: TodoItem = TodoItem.parse(csv: csv)!
        let csvNew = item.csv

        XCTAssertEqual(csv, csvNew)
    }

    func testToDoItemFormCSVWithoutOptioanalAttributes() throws {
        let csv: String = "111222;Text here;important;;false;2023.0;"

        let item: TodoItem = TodoItem.parse(csv: csv)!
        let csvNew = item.csv

        XCTAssertEqual(csv, csvNew)
    }

    func testToDoItemFormCSVWithoutImportancy() throws {
        let csv: String = "111222;Text here;;;false;2023.0;"

        let item: TodoItem = TodoItem.parse(csv: csv)!
        let csvNew = item.csv

        XCTAssertEqual(csv, csvNew)
    }

    func testToDoItemFormCSVWithRequiredAttributes() throws {
        let csv: String = "111222;Text here;;;;2023.0;"

        let item: TodoItem = TodoItem.parse(csv: csv)!
        let csvNew = item.csv

        XCTAssertNotEqual(csv, csvNew) // isCompleted
    }

    func testToDoItemSaveLoadCSV1() throws {

        let item1: TodoItem = TodoItem(
            text: "Lol",
            importancy: .important,
            dateCreated: Date(timeIntervalSince1970: 2023.0)
        )

        let item2: TodoItem = TodoItem(
            id: "111111111122222",
            text: "text",
            importancy: .important,
            deadline: Date(timeIntervalSince1970: 2023.0),
            isCompleted: false,
            dateCreated: Date(timeIntervalSince1970: 2023.0),
            dateModified: nil
        )

        let fileCash: FileCache = FileCache()
        let fileCash2: FileCache = FileCache()

        fileCash.add(item: item1)
        fileCash.add(item: item2)
        try fileCash.remove(id: item1.id)

        let fileName = "TestFileCSV"

        try fileCash.saveItemsCSV(to: fileName)
        try fileCash2.loadItemsCSV(from: fileName)

        XCTAssertEqual(fileCash.todoItems[0].id, item2.id)
        XCTAssertEqual(fileCash2.todoItems[0].id, item2.id)
    }
}
