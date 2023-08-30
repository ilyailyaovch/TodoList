import UIKit
import CocoaLumberjackSwift

/// Global variable which contains fileCache
var rootViewModel: RootViewModel = RootViewModel()

// MARK: - RootViewController

class RootViewController: UIViewController {

    let addButtonView = UIButton()
    let menuButtonView = UIButton(type: .system)
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let tableHeaderView = TableViewHeaderCell()

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        // setup UI
        setupHeader()
        setupLayout()
        setupTableView()
        setupButton()
        setupConstraints()

        // connect rootViewModel
        rootViewModel.viewController = self

        // fetch data on client
        rootViewModel.fetchData()

        // fetch data from server
        // rootViewModel.fetchDataNetwork()
    }

    // MARK: - Setup RootView

    func setupHeader() {
        navigationItem.title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: 34, bottom: 0, right: 0)

        menuButtonView.setTitle("Сортировка", for: .normal)
        menuButtonView.configuration = .plain()
        menuButtonView.menu = makeMenu()
        menuButtonView.showsMenuAsPrimaryAction = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButtonView)
    }

    func setupLayout() {
        view.backgroundColor = Colors.backPrimary.color
        view.addSubview(tableView)
        view.addSubview(addButtonView)
    }

    func setupTableView() {
        tableView.backgroundColor = Colors.backPrimary.color
        tableView.register(
            TableViewHeaderCell.self,
            forHeaderFooterViewReuseIdentifier: TableViewHeaderCell.identifier
        )
        tableView.register(
            TableViewCell.self,
            forCellReuseIdentifier: TableViewCell.identifier
        )
        tableView.register(
            TableViewAddCell.self,
            forCellReuseIdentifier: TableViewAddCell.identifier
        )
        tableView.delegate = self
        tableView.dataSource = self
    }

    func setupButton() {
        addButtonView.addTarget(self, action: #selector(addCellTapped), for: .touchUpInside)
        addButtonView.setImage(Icon.PlusButton.image, for: .normal)
        addButtonView.layer.shadowColor = UIColor.blue.cgColor
        addButtonView.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        addButtonView.layer.shadowRadius = 5.0
        addButtonView.layer.shadowOpacity = 0.3
    }

    // MARK: - Constrains of RootViewController

    func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        menuButtonView.translatesAutoresizingMaskIntoConstraints = false
        addButtonView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            addButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -54),
            addButtonView.widthAnchor.constraint(equalToConstant: 44),
            addButtonView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

// MARK: - TableView

extension RootViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return rootViewModel.todoListState.count + 1
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard
            tableView.cellForRow(at: indexPath) is TableViewCell
        else { return }
        let item = rootViewModel.todoListState[indexPath.row]
        rootViewModel.openToDo(with: item)
    }

    // MARK: table cells
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == rootViewModel.todoListState.count {
            // Строка последнего элемента "Новое"
            let newCell = tableView.dequeueReusableCell(withIdentifier: TableViewAddCell.identifier, for: indexPath)
            guard
                let newCell = newCell as? TableViewAddCell
            else { return UITableViewCell() }
            newCell.addCellTapped = { [weak self] in self?.addCellTapped() }
            newCell.selectionStyle = .none
            return newCell
        } else {
            // Строки для todoItems
            let customCell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath)
            guard
                let customCell = customCell as? TableViewCell
            else { return UITableViewCell() }
            let todoList = filterTodoList(list: rootViewModel.todoListState)
            let item = todoList[indexPath.row]
            customCell.configureCell(with: item)
            customCell.valueDidChange = { rootViewModel.toggleCompletion(with: item, at: indexPath) }
            customCell.selectionStyle = .none
            return customCell
        }
    }

    // MARK: table header
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let counter = rootViewModel.fileCache.todoItems.filter { $0.isCompleted }.count
        tableHeaderView.textView.text = "Выполнено - \(counter)"
        tableHeaderView.valueDidChange = { rootViewModel.updateTodoListState() }
        return tableHeaderView
    }

    // MARK: table preview
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        let actionProvider: UIContextMenuActionProvider = { _ in
            return UIMenu(title: "Дело", children: [
                UIAction(title: "Посмотреть") { _ in
                    let item = rootViewModel.todoListState[indexPath.row]
                    rootViewModel.openToDo(with: item)
                },
                UIAction(title: "Удалить") { _ in
                    let item = rootViewModel.todoListState[indexPath.row]
                    rootViewModel.deleteToDo(id: item.id)
                }
            ])
        }
        let config = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            let item = rootViewModel.todoListState[indexPath.row]
            let controller = TodoViewController(with: item)
            let navigationController = UINavigationController(rootViewController: controller)
            return navigationController
        }, actionProvider: actionProvider)
        return config
    }

    // MARK: table preview perform
    func tableView(_ tableView: UITableView,
                   willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionCommitAnimating) {
        guard
            let previewedController = animator.previewViewController
        else { return }
        animator.addCompletion { self.present(previewedController, animated: true) }
    }

    // MARK: table swipes lead
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Toggle action
        let toggle = UIContextualAction(style: .normal, title: "") { ( _, _, completionHandler) in
            let item  = rootViewModel.todoListState[indexPath.row]
            rootViewModel.toggleCompletion(with: item, at: indexPath)
            completionHandler(true)
        }
        if rootViewModel.todoListState[indexPath.row].isCompleted {
            toggle.image = UIImage(systemName: "circle")
            toggle.backgroundColor = Colors.gray.color
        } else {
            toggle.image = UIImage(systemName: "checkmark.circle.fill")
            toggle.backgroundColor = Colors.green.color
        }
        return UISwipeActionsConfiguration(actions: [toggle])
    }

    // MARK: table swipes trail
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Info action
        let info = UIContextualAction(style: .normal, title: "") { (_, _, completionHandler) in
            let item  = rootViewModel.todoListState[indexPath.row]
            rootViewModel.openToDo(with: item)
            completionHandler(true)
        }
        info.backgroundColor = Colors.grayLight.color
        info.image = UIImage(systemName: "info.circle.fill")
        // Trash action
        let trash = UIContextualAction(style: .destructive, title: "") { (_, _, completionHandler) in
            rootViewModel.deleteRow(at: indexPath)
            completionHandler(true)
        }
        trash.backgroundColor = Colors.red.color
        trash.image = UIImage(systemName: "trash.fill")

        let configuration = UISwipeActionsConfiguration(actions: [trash, info])
        return configuration
    }

    // MARK: filter todo
    func filterTodoList(list: [TodoItem]) -> ([TodoItem]) {
        // check presentation status
        switch rootViewModel.status {
        case Status.ShowAll:
            rootViewModel.todoListState = rootViewModel.fileCache.todoItems
        case Status.ShowUncompleted:
            rootViewModel.todoListState = rootViewModel.fileCache.todoItems.filter({ !$0.isCompleted })
        }
        // check sorting mode
        switch rootViewModel.sortMode {
        case SortMode.alphaAscending:
            rootViewModel.todoListState.sort { $0.text < $1.text }
        case SortMode.alphaDescending:
            rootViewModel.todoListState.sort { $0.text > $1.text }
        case SortMode.createdAscending:
            rootViewModel.todoListState.sort { $0.dateCreated < $1.dateCreated }
        case SortMode.createdDescending:
            rootViewModel.todoListState.sort { $0.dateCreated > $1.dateCreated }
        }
        return rootViewModel.todoListState
    }
}

// MARK: - Redoads

extension RootViewController {

    func reloadData() {
        tableView.reloadData()
    }

    func reloadRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .fade)
    }

    func deleteRow(at indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .right)
    }
}

// MARK: - Sort menu

extension RootViewController {
    func makeMenu() -> (UIMenu) {
        let alphaAscending = UIAction(
            title: "По алфавиту",
            image: UIImage(systemName: "arrow.up.right")
        ) { _ in
            rootViewModel.changeSortMode(to: SortMode.alphaAscending)
            self.reloadData()
        }
        let alphaDescending = UIAction(
            title: "По алфавиту",
            image: UIImage(systemName: "arrow.down.right")
        ) { _ in
            rootViewModel.changeSortMode(to: SortMode.alphaDescending)
            self.reloadData()
        }
        let createdAscending = UIAction(
            title: "По дате создания",
            image: UIImage(systemName: "arrow.up.right")
        ) { _ in
            rootViewModel.changeSortMode(to: SortMode.createdAscending)
            self.reloadData()
        }
        let createdDescending = UIAction(
            title: "По дате создания",
            image: UIImage(systemName: "arrow.down.right")
        ) { _ in
            rootViewModel.changeSortMode(to: SortMode.createdDescending)
            self.reloadData()
        }
        return UIMenu(
            title: "Сортировать",
            children: [alphaAscending, alphaDescending, createdAscending, createdDescending]
        )
    }
}

// MARK: - @objc

extension RootViewController {

    @objc func addCellTapped() {
        rootViewModel.openToDo(with: nil)
    }
}
