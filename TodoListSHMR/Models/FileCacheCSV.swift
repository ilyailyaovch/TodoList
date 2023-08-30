import Foundation

// MARK: - FileCache Csv

extension FileCache {

    // Загрузка всех дел из файла
    func loadItemsCSV(from file: String) throws {

        // формируем путь до файла
        guard
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw FileCacheErrors.wrongDirectory }
        let pathWithFilename = path.appendingPathComponent("\(file).csv")

        // получаем text по заданному пути
        let textData = try String(contentsOf: pathWithFilename, encoding: .utf8)
        var textArr = textData.split(separator: "\n")
        textArr.remove(at: 0)

        self.set(items: textArr.compactMap { TodoItem.parse(csv: String($0))})
    }

    // Сохранение всех дел в файл (applicationSupportDirectory)
    func saveItemsCSV(to file: String) throws {

        // формируем путь до файла
        guard
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw FileCacheErrors.wrongDirectory }
        let pathWithFilename = path.appendingPathComponent("\(file).csv")

        // записываем построчно элементы
        var csvLine = "id;text;importancy;deadline;isCompleted;dateCreated;dateModified\n"
        do {
            for item in todoItems {
                csvLine.append(item.csv + "\n")
            }
            try csvLine.write(to: pathWithFilename, atomically: true, encoding: .utf8)

        } catch {
            print(FileCacheErrors.saveItemsError)
        }
    }
}
