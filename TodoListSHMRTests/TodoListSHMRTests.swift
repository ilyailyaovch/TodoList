//
//  TodoListSHMRTests.swift
//  TodoListSHMRTests
//
//  Created by Ilya Ovchinnikov on 09.06.2023.
//

import XCTest
@testable import TodoListSHMR

final class TodoListSHMRTests: XCTestCase {

    func testTodoItemInitWithAllAttributes() {

        let item: TodoItem = TodoItem(
            id: "111111111122222",
            text: "text",
            importancy: .important,
            deadline: Date(timeIntervalSince1970: 2024.0),
            isCompleted: false,
            dateCreated: Date(timeIntervalSince1970: 2023.0),
            dateModified: Date(timeIntervalSince1970: 2023.0)
        )

        let id = "111111111122222"
        let text = "text"
        let importancy = Importancy.important
        let deadline = Date(timeIntervalSince1970: 2024.0)
        let isCompleted = false
        let dateCreated = Date(timeIntervalSince1970: 2023.0)
        let dateModified = Date(timeIntervalSince1970: 2023.0)

        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.importancy, importancy)
        XCTAssertEqual(item.deadline, deadline)
        XCTAssertEqual(item.isCompleted, isCompleted)
        XCTAssertEqual(item.dateCreated, dateCreated)
        XCTAssertEqual(item.dateModified, dateModified)
    }

    func testTodoItemInitWithoutAllAttributes() {

        let item: TodoItem = TodoItem(
            text: "Lol",
            dateCreated: Date(timeIntervalSince1970: 2023.0)
        )

        let text = "Lol"
        let importancy = Importancy.normal
        let isCompleted = false
        let dateCreated = Date(timeIntervalSince1970: 2023.0)

        XCTAssertNotNil(item.id)
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.importancy, importancy)
        XCTAssertEqual(item.isCompleted, isCompleted)
        XCTAssertEqual(item.dateCreated, dateCreated)
        XCTAssertNil(item.deadline)
        XCTAssertNil(item.dateModified)
    }
}
