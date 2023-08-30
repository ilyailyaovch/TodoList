import Foundation

// Временный массив с элементами

let mockData = [

    TodoItem(
        text: "Apple",
        importancy: .low,
        deadline: Date(timeIntervalSince1970: 2024.0),
        isCompleted: false,
        dateCreated: Date()
    ),

    TodoItem(
        text: "Amazon",
        importancy: .normal,
        isCompleted: false,
        dateCreated: Date()
    ),

    TodoItem(
        text: "Nike",
        importancy: .important,
        deadline: Date(timeIntervalSince1970: 2024.0),
        isCompleted: false,
        dateCreated: Date()
    ),

    TodoItem(
        text: "Facebook",
        importancy: .important,
        deadline: Date(timeIntervalSince1970: 2024.0),
        isCompleted: true,
        dateCreated: Date()
    ),

    TodoItem(
        text: "Google",
        importancy: .important,
        deadline: Date(timeIntervalSince1970: 2024.0),
        isCompleted: true,
        dateCreated: Date()
    )

]
