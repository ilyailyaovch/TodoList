import Foundation

// MARK: - FileCache json

extension FileCache {

    // Сохранение всех дел в файл
    func saveItems(to file: String) throws {

        // формируем путь до файла
        guard
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw FileCacheErrors.wrongDirectory }
        let pathWithFilename = path.appendingPathComponent("\(file).json")

        // создаем список json элементов
        let jsonItems = todoItems.map({ $0.json })

        // записываем json элементы в файл
        let jsonData = try JSONSerialization.data(withJSONObject: jsonItems)
        try jsonData.write(to: pathWithFilename)
    }

    // Загрузка всех дел из файла
    func loadItems(from file: String) throws {

        // формируем путь до файла
        guard
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw FileCacheErrors.wrongDirectory }
        let pathWithFilename = path.appendingPathComponent("\(file).json")

        // получаем data по заданному пути
        let textData = try String(contentsOf: pathWithFilename, encoding: .utf8)
        guard
            let jsonData = textData.data(using: .utf8)
        else { throw FileCacheErrors.incorrectJson }

        // парсим data в массив
        guard
            let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]]
        else { throw FileCacheErrors.incorrectJson }

        self.set(items: jsonArray.compactMap { TodoItem.parse(json: $0)})
    }
}
