import UIKit

protocol RootViewControllerProtocol: AnyObject {

    /// ViewDidLoad
    func viewDidLoad()

    /// Title,  Navigation
    func setupHeader()

    /// SubViews: tableView, buttonView
    func setupLayout()

    /// TableView
    func setupTableView()

    /// ButtonView - add new item
    func setupButton()

    /// Constrains for RootView
    func setupConstraints()
}
