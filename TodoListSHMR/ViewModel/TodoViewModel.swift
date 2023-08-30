import Foundation

final class TodoViewModel {

    weak var viewController: TodoViewController?

    var item: TodoItem?
    var state: TodoItemState

    init(item: TodoItem) {
        self.state = TodoItemState(item: item)
    }
}

extension TodoViewModel: TodoViewModelProtocol {

    func saveItem(item: TodoItem) {
        rootViewModel.saveToDo(item: item, reload: true)
        viewController?.dismiss(animated: true)
    }

    func deleteItem(id: String) {
        rootViewModel.deleteToDo(id: id)
        viewController?.dismiss(animated: true)
    }

    func loadData() {
        if !state.text.isEmpty {
            viewController?.textView.text = state.text
            viewController?.textView.textColor = Colors.labelPrimary.color
        }
        viewController?.importancyView.importancy = state.importancy
        viewController?.deadlineView.deadline = state.deadline
        viewController?.activateButtons()
    }
}
