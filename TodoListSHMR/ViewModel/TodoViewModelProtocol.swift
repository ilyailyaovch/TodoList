import UIKit

protocol TodoViewModelProtocol {

    /// Save item to FileCache and  save File
    func saveItem(item: TodoItem)

    /// Delete item from FileCache and save File
    func deleteItem(id: String)

    /// Load item and present it in TodoViewController
    func loadData()
}
