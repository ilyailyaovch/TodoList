import Foundation
import CocoaLumberjackSwift

enum ApiErrors: Error {
    case badURL
    case impossinbleToDecode
}

protocol NetworkingService {
    func getList() async throws -> [TodoItem]
    func getElement(by id: String) async throws -> TodoItem
    func putElement(with todoItemClient: TodoItem) async throws -> TodoItem
    func patchList(with todoItemsClient: [TodoItem]) async throws -> [TodoItem]
    func postElem(with todoItemClient: TodoItem) async throws -> TodoItem
    func deleteElement(by id: String) async throws -> TodoItem
}

class DefaultNetworkingService: NetworkingService {

    private let token = "trisomies"
    private let userName = "Ovchinnikov_I"
    private var revision: Int = 0

    private func createURL(id: String = "") -> URL? {
        let baseURL = "https://beta.mrdekk.ru/todobackend"
        let endpoint = id.isEmpty ? "/list" : "/list/\(id)"
        let addressURL = baseURL + endpoint
        let url = URL(string: addressURL)
        return url
    }

    // MARK: - GET list
    /// Получить список с сервера
    func getList() async throws -> [TodoItem] {
        // Cоздание URL
        guard let url = createURL()
        else { throw ApiErrors.badURL }
        // Настройка запроса
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        // Получение данных по запросу
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        // Декодирование данных по запросу
        let todoItemsOrigin = try parseTodoItems(data: data)
        DDLogInfo("GET list from the server")
        return todoItemsOrigin
    }

    // MARK: - GET element
    /// Получить элемент списка
    func getElement(by id: String) async throws -> TodoItem {
        // Cоздание URL
        guard let url = createURL(id: id)
        else { throw ApiErrors.badURL }
        // Настройка запроса
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        // Получение данных по запросу
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        // Декодирование данных по запросу
        let todoItemOrigin = try parseTodoItem(data: data)
        DDLogInfo("GET element from the server")
        return todoItemOrigin
    }

    // MARK: - PUT element
    /// Изменить элемент списка
    func putElement(with todoItemClient: TodoItem) async throws -> TodoItem {
        // Cоздание URL
        guard let url = createURL(id: todoItemClient.id)
        else { throw ApiErrors.badURL }
        // Кодирование локального элемента
        let element = todoItemClient.json
        let body = try JSONSerialization.data(withJSONObject: ["element": element])
        // Настройка запроса
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.allHTTPHeaderFields = ["X-Last-Known-Revision": "\(self.revision)"]
        request.httpBody = body
        // Получение данных по запросу
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        // Декодирование данных по запросу
        let todoItemOrigin = try parseTodoItem(data: data)
        DDLogInfo("PUT element inside the server")
        return todoItemOrigin
    }

    // MARK: - PATCH list
    /// Обновить список на сервере
    func patchList(with todoItemsClient: [TodoItem]) async throws -> [TodoItem] {
        // Cоздание URL
        guard let url = createURL()
        else { throw ApiErrors.badURL }
        // Кодирование локального списка
        let list = todoItemsClient.map({ $0.json })
        let body = try JSONSerialization.data(withJSONObject: ["list": list])
        // Настройка запроса
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.allHTTPHeaderFields = ["X-Last-Known-Revision": "\(self.revision)"]
        request.httpBody = body
        // Отправка запроса
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        let todoItemsServer = try parseTodoItems(data: data)
        DDLogInfo("PATCH list in the server")
        return todoItemsServer
    }

    // MARK: - POST element
    /// Добавить элемент списка
    func postElem(with todoItemClient: TodoItem) async throws -> TodoItem {
        // Cоздание URL
        guard let url = createURL()
        else { throw ApiErrors.badURL }
        // Кодирование локального элемента
        let element = todoItemClient.json
        let body = try JSONSerialization.data(withJSONObject: ["element": element])
        // Настройка запроса
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.allHTTPHeaderFields = ["X-Last-Known-Revision": "\(self.revision)"]
        request.httpBody = body
        // Отправка запроса
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        let todoItemsServer = try parseTodoItem(data: data)
        DDLogInfo("POST element to the server")
        return todoItemsServer
    }

    // MARK: - DELETE element
    /// Удалить элемент списка
    func deleteElement(by id: String) async throws -> TodoItem {
        // Cоздание URL
        guard let url = createURL(id: id)
        else { throw ApiErrors.badURL }
        // Настройка запроса
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.allHTTPHeaderFields = ["X-Last-Known-Revision": "\(self.revision)"]
        // Получение данных по запросу
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        // Декодирование данных по запросу
        let todoItemOrigin = try parseTodoItem(data: data)
        DDLogInfo("DELETE element in the server")
        return todoItemOrigin
    }

    // MARK: - Parse items from data

    func parseTodoItems(data: Data) throws -> [TodoItem] {
        guard
            let jsonArray = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let revision = jsonArray["revision"] as? Int,
            let list = jsonArray["list"] as? [[String: Any]]
        else { throw ApiErrors.impossinbleToDecode }
        var todoItemsOrigin: [TodoItem] = []
        for item in list {
            guard let todoItem = TodoItem.parse(json: item)
            else { throw ApiErrors.impossinbleToDecode }
            todoItemsOrigin.append(todoItem)
        }
        self.revision = revision
        DDLogInfo("revision = \(self.revision)")
        return todoItemsOrigin
    }

    func parseTodoItem(data: Data) throws -> TodoItem {
        guard
            let jsonArray = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let revision = jsonArray["revision"] as? Int,
            let element = jsonArray["element"] as? [String: Any],
            let todoItem = TodoItem.parse(json: element)
        else { throw URLError(.cannotDecodeContentData) }
        self.revision = revision
        DDLogInfo("revision = \(self.revision)")
        return todoItem
    }
}
