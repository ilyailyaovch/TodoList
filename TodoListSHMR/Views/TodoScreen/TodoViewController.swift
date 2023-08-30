import UIKit

// MARK: - TodoViewController

final class TodoViewController: UIViewController, UIScrollViewDelegate {

    var viewModel: TodoViewModel

    var cancelButton = UIButton(configuration: .plain(), primaryAction: nil)
    var saveButton = UIButton(configuration: .plain(), primaryAction: nil)

    var scrollView = UIScrollView()
    var stackView = UIStackView()

    var textView = UITextView()
    var detailsStack = UIStackView()
    var divider = UIView()
    var importancyView = ImportancyView()
    var deadlineView = DeadlineView()
    var calendarDivider = UIView()
    var calendarView = CalendarView()
    var deleteButton = UIButton()

    let placeholder = "Что надо сделать?"
    let constants = Constants()

    // MARK: - Inits

    init(with item: TodoItem) {
        self.viewModel = TodoViewModel(item: item)
        super.init(nibName: nil, bundle: nil)
        self.viewModel.viewController = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        // setup UI
        setupNavigationBar()
        setupBody()
        setupBodyConstrains()

        // setup keyboard
        setupKeyboardObserver()

        // check switches
        valuesDidChange()

        viewModel.loadData()
    }

    // MARK: - Setup NavigationBar

    func setupNavigationBar() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTap), for: .touchUpInside)

        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTap), for: .touchUpInside)

        title = "Дело"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.isEnabled = false
    }

    // MARK: - Setup TodoView

    func setupBody() {

        view.backgroundColor = Colors.backPrimary.color
        view.addSubview(scrollView)

        setupStackView()
        scrollView.addSubview(stackView)

        setupTextView()
        stackView.addArrangedSubview(textView)

        setupDetailsStack()
        stackView.addArrangedSubview(detailsStack)

        setupDeleteButton()
        stackView.addArrangedSubview(deleteButton)
    }

    func setupScrollView() {
        scrollView.delegate = self
        scrollView.contentSize.width = 1
    }

    func setupStackView() {
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 16.0
        stackView.alignment = .fill
    }

    func setupTextView() {
        textView.delegate = self
        textView.text = self.placeholder
        textView.textColor = UIColor.lightGray
        textView.layer.cornerRadius = constants.cornerRadius
        textView.backgroundColor = Colors.backSecondary.color
        textView.font = UIFont.systemFont(ofSize: constants.bodySize)
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.isScrollEnabled = false
        textView.keyboardDismissMode = .interactive
    }

    func setupDivider(with div: UIView) {
        let fill = UIView()
        div.addSubview(fill)
        fill.backgroundColor = Colors.supportSeparator.color
        fill.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            div.heightAnchor.constraint(equalToConstant: 0.5),
            fill.topAnchor.constraint(equalTo: div.topAnchor),
            fill.leftAnchor.constraint(equalTo: div.leftAnchor, constant: 16),
            fill.rightAnchor.constraint(equalTo: div.rightAnchor, constant: -16),
            fill.heightAnchor.constraint(equalTo: div.heightAnchor)
        ])
    }

    func setupDetailsStack() {
        detailsStack.axis = .vertical
        detailsStack.alignment = .fill
        detailsStack.distribution = .equalSpacing
        detailsStack.layer.cornerRadius = constants.cornerRadius
        detailsStack.backgroundColor = Colors.backSecondary.color

        setupDivider(with: divider)
        setupDivider(with: calendarDivider)

        detailsStack.addArrangedSubview(importancyView)
        detailsStack.addArrangedSubview(divider)
        detailsStack.addArrangedSubview(deadlineView)
        detailsStack.addArrangedSubview(calendarDivider)
        detailsStack.addArrangedSubview(calendarView)
        calendarDivider.isHidden = true
        calendarView.isHidden = true
    }

    func setupDeleteButton() {
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.isEnabled = false
        deleteButton.setTitleColor(Colors.labelDisable.color, for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: constants.bodySize)
        deleteButton.backgroundColor = Colors.backSecondary.color
        deleteButton.configuration?.contentInsets = .init(top: 17, leading: 16, bottom: 17, trailing: 16)
        deleteButton.layer.cornerRadius = constants.cornerRadius
        deleteButton.addTarget(self, action: #selector(deleteButtonTap), for: .touchUpInside)
    }

    // MARK: - Constrains of TodoViewController

    func setupBodyConstrains() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            importancyView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            deadlineView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            deleteButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Values Did Change

    func valuesDidChange() {

        importancyView.valueDidChange = { [weak self] value in
            self?.importancyDidChange(importancy: value)
        }

        deadlineView.valueDidChange = { [weak self] value in
            self?.deadlineDidChange(isEnabled: value)
        }

        deadlineView.deadlineDidClick = { [weak self] in
            self?.deadlineSubTextDidClick()
        }

        calendarView.valueDidChange = { [weak self] value in
            self?.deadlineDateDidChange()
        }
    }

    // MARK: - Setup Keyboard Observers

    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}

// MARK: - UITextViewDelegate

extension TodoViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        activateButtons()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.textColor = Colors.labelPrimary.color
            textView.text = nil
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textView.resignFirstResponder()
    }
}

// MARK: - Visual changes

extension TodoViewController {

    func showCalendar(with date: Date) {
        calendarView.datePicker.setDate(date, animated: false)
        calendarView.datePicker.layer.opacity = 1
        calendarDivider.layer.opacity = 1
        UIView.animate(withDuration: 0.25) {
            self.calendarView.datePicker.isHidden = false
            self.calendarView.isHidden = false
            self.calendarDivider.isHidden = false
        }
    }

    func dismissCalendar() {
        calendarView.datePicker.layer.opacity = 0
        calendarDivider.layer.opacity = 0
        UIView.animate(withDuration: 0.25) {
            self.calendarView.datePicker.isHidden = true
            self.calendarView.isHidden = true
            self.calendarDivider.isHidden = true
        }
    }

    func importancyDidChange(importancy: Importancy) {
        activateButtons()
    }

    func deadlineDidChange(isEnabled: Bool) {
        let defaultDeadline = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        deadlineView.deadline = isEnabled ? deadlineView.deadline ?? defaultDeadline : nil
        isEnabled ? showCalendar(with: deadlineView.deadline ?? defaultDeadline) : dismissCalendar()
        activateButtons()
    }

    func deadlineSubTextDidClick() {
        if deadlineView.deadline != nil {
            let defaultDeadline = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            showCalendar(with: deadlineView.deadline ?? defaultDeadline)
        }
    }

    func deadlineDateDidChange() {
        deadlineView.deadline = calendarView.datePicker.date
        dismissCalendar()
    }

    func activateButtons() {
        if !textView.text.isEmpty && textView.text != self.placeholder {
            saveButton.isEnabled = true
            deleteButton.isEnabled = true
            deleteButton.setTitleColor(Colors.red.color, for: .normal)
        }
    }
}

// MARK: - @objc

extension TodoViewController {

    @objc func cancelButtonTap() {
        dismiss(animated: true)
    }

    @objc func saveButtonTap() {
        viewModel.saveItem(item: TodoItem(
            id: viewModel.state.id,
            text: textView.text,
            importancy: importancyView.importancy ?? .normal,
            deadline: deadlineView.deadline ?? nil)
        )
    }

    @objc func deleteButtonTap() {
        if saveButton.isEnabled {
            viewModel.deleteItem(id: viewModel.state.id)
        } else {
            dismiss(animated: true)
        }
    }

    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        scrollView.contentInset.bottom = keyboardHeight
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
}
