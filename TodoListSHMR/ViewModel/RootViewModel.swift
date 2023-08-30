import UIKit
import CocoaLumberjackSwift

enum Status {
    case ShowAll
    case ShowUncompleted
}

enum SortMode {
    case alphaAscending
    case alphaDescending
    case createdAscending
    case createdDescending
}

// MARK: - RootViewModel

final class RootViewModel: UIViewController {

    var fileName: String
    var fileCache: FileCache
    var todoListState = [TodoItem]()
    var isDirty = true

    weak var viewController: RootViewController?

    let network: NetworkingService = DefaultNetworkingService()

    public private(set) var status: Status = Status.ShowUncompleted
    public private(set) var sortMode: SortMode = SortMode.createdDescending

    init(fileName: String = "TodoCache",
         fileCache: FileCache = FileCache()) {
        self.fileCache = fileCache
        self.fileName = fileName
        super.init(nibName: nil, bundle: nil)
        DDLog.add(DDOSLogger.sharedInstance)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - CRUD Network

extension RootViewModel {

    /// Загрузка с сервера
    /// Перетирает локальные данные
    func fetchDataNetwork() {
        Task {
            do {
                let itemsFromNetwork = try await network.getList()
                fetchDataClient(with: itemsFromNetwork)
                self.isDirty = false
            } catch {
                self.isDirty = true
            }
        }
    }

    /// Удаление на сервере
    func deleteToDoNetwork(id: String) {
        // Проверка на неактуальность
        if self.isDirty { fetchDataNetwork() }
        Task {
            do {
                _ = try await network.deleteElement(by: id)
                self.isDirty = false
            } catch {
                self.isDirty = true
            }
        }
    }

    /// Добавление на сервере
    func addToDoNetwork(item: TodoItem) {
        // Проверка на неактуальность
        if self.isDirty { fetchDataNetwork() }
        Task {
            do {
                _ = try await network.postElem(with: item)
                self.isDirty = false
            } catch {
                self.isDirty = true
            }
        }
    }

    /// Изменение на сервере
    func changeToDoNetwork(item: TodoItem) {
        // Проверка на неактуальность
        if self.isDirty { fetchDataNetwork() }
        Task {
            do {
                _ = try await network.putElement(with: item)
                self.isDirty = false
            } catch {
                self.isDirty = true
            }
        }
    }

    @MainActor
    func fetchDataClient(with items: [TodoItem]) {
        self.fileCache.set(items: items)
        self.saveTodoItems()
        self.updateTodoListState()
    }
}

extension RootViewModel: RootViewModelProtocol {

    // MARK: - CRUD functions

    /// Открытие модального окна редактирования TodoItem
    func openToDo(with item: TodoItem? = nil) {
        let newItem = item ?? TodoItem(text: "")
        let newNavViewController = UINavigationController(rootViewController: TodoViewController(with: newItem))
        newNavViewController.modalTransitionStyle = .coverVertical
        newNavViewController.modalPresentationStyle = .formSheet
        viewController?.present(newNavViewController, animated: true)
    }

    /// Сохранение данных в локальное хранилище
    func saveTodoItems() {
        do {
            // сохранение в локальный json
            // try fileCache.saveItems(to: self.fileName)
            // сохранение в локальную БД
            try fileCache.saveSQLite()
        } catch {
            DDLogError("Error: saveTodoItems()")
        }
    }

    /// Загрузка данных из локального хранилища
    func fetchData() {
        do {
            // загрузка из локального json
            // try fileCache.loadItems(from: self.fileName)
            // загрузка из локальной БД
            try fileCache.loadSQLite()
            // обновление списка показа
            self.updateTodoListState()
        } catch {
            DDLogError("Error: fetchData()")
        }
    }

    /// Добавление или изменение элемента с возможностью обновить таблицу
    func saveToDo(item: TodoItem, reload: Bool = false) {
        do {
            // добавить или изменить в коллекции
            let addedTaskType = self.fileCache.add(item: item)
            // сохранить в локальный json
            // try self.fileCache.saveItems(to: rootViewModel.fileName)
            // обновить список показа
            if reload { self.updateTodoListState() }
            // изменения в хранилищах
            switch addedTaskType {
            case .new:
                // добавить в БД
                try self.fileCache.insert(item: item)
                // добавить на сервер
                // addToDoNetwork(item: item)
            case .changed:
                // изменить в БД
                try self.fileCache.update(item: item)
                // изменить на сервере
                // changeToDoNetwork(item: item)
            }
        } catch {
            DDLogError("Error: saveToDo()")
        }
    }

    /// Удаление элемента с обновлением таблицы
    func deleteToDo(id: String) {
        do {
            // удалить в коллекции
            try self.fileCache.remove(id: id)
            // изменения в локальном json
            // try self.fileCache.saveItems(to: rootViewModel.fileName)
            // удалить из локальной БД
            try self.fileCache.delete(id: id)
            // обновить список показа
            self.updateTodoListState()
            // удалить на сервере
            // self.deleteToDoNetwork(id: id)
        } catch {
            DDLogError("Error: deleteToDo()")
        }
    }

    /// Удаление элемента без обновления таблицы
    func deleteRow(at indexPath: IndexPath) {
        let id = self.todoListState[indexPath.row].id
        do {
            // удалить в коллекции
            try self.fileCache.remove(id: id)
            // изменения в локальном json
            // try self.fileCache.saveItems(to: rootViewModel.fileName)
            // удалить из локальной БД
            try self.fileCache.delete(id: id)
            // обновить показ списка
            self.todoListState.remove(at: indexPath.row)
            self.viewController?.deleteRow(at: indexPath)
            // удалить на сервере
            // self.deleteToDoNetwork(id: id)
        } catch {
            DDLogError("Error: deleteToDo()")
        }
    }

    func toggleCompletion(with item: TodoItem, at indexPath: IndexPath) {
        // создание нового элемента с инвертированным статусом
        let newItem = TodoItem(
            id: item.id,
            text: item.text,
            importancy: item.importancy,
            deadline: item.deadline,
            isCompleted: !item.isCompleted,
            dateCreated: item.dateCreated,
            dateModified: item.dateModified
        )
        // сохранение изменения в хранилищах
        self.saveToDo(item: newItem)
        // обновить показ списка
        switch self.status {
        case Status.ShowAll:
            self.todoListState = self.fileCache.todoItems
            self.viewController?.reloadRow(at: indexPath)
        case Status.ShowUncompleted:
            self.todoListState.remove(at: indexPath.row)
            self.viewController?.deleteRow(at: indexPath)
            self.viewController?.reloadData()
        }
        // обновить счетчик в заголовке
        let counter = rootViewModel.fileCache.todoItems.filter {$0.isCompleted}.count
        self.viewController?.tableHeaderView.textView.text = "Выполнено - \(counter)"
    }

    // MARK: - todoListState presentation

    func updateTodoListState() {
        switch self.status {
        case Status.ShowUncompleted:
            self.todoListState = self.fileCache.todoItems.filter({!$0.isCompleted})
        case Status.ShowAll:
            self.todoListState = self.fileCache.todoItems
        }
        self.viewController?.reloadData()
    }

    func changePresentationStatus(to newStatus: Status) {
        self.status = newStatus
    }

    func changeSortMode(to newMode: SortMode) {
        self.sortMode = newMode
    }
}
