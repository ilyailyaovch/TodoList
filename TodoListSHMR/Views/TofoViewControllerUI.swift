//
//  TofoViewControllerUI.swift
//  TodoListSHMR
//
//  Created by Ilya Ovchinnikov on 22.06.2023.
//

import UIKit

// Setup elements of NavigationBar

func setupNavigationBar() {
    cancelButton.setTitle("Отменить", for: .normal)
    cancelButton.addTarget(self, action: #selector(tapCancel), for: .touchUpInside)

    saveButton.setTitle("Сохранить", for: .normal)
    saveButton.addTarget(self, action: #selector(tapSave), for: .touchUpInside)
    saveButton.isEnabled = false

    title = "Дело"
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
}

//  Setup elements of TodoItemsViewController

func setupBody() {

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

func setupStackView() {
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 16.0
    stackView.alignment = .fill
}

func setupTextView() {
    textView.layer.cornerRadius = constants.cornerRadius
    textView.backgroundColor = Colors.backSecondary.color
    textView.font = UIFont.systemFont(ofSize: constants.bodySize)
    textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    textView.isScrollEnabled = false
    textView.keyboardDismissMode = .interactive

}

func setupDivider(divider: UIView) {
    let fill = UIView()
    divider.addSubview(fill)
    fill.backgroundColor = Colors.supportSeparator.color
    fill.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        divider.heightAnchor.constraint(equalToConstant: 0.5),
        fill.topAnchor.constraint(equalTo: divider.topAnchor),
        fill.leftAnchor.constraint(equalTo: divider.leftAnchor, constant: 16),
        fill.rightAnchor.constraint(equalTo: divider.rightAnchor, constant: -16),
        fill.heightAnchor.constraint(equalTo: divider.heightAnchor)
    ])
}

func setupDetailsStack() {
    detailsStack.axis = .vertical
    detailsStack.alignment = .fill
    detailsStack.distribution = .equalSpacing
    detailsStack.layer.cornerRadius = constants.cornerRadius
    detailsStack.backgroundColor = Colors.backSecondary.color

    setupDivider(divider: divider)
    setupDivider(divider: calendarDivider)

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
    deleteButton.setTitleColor(Colors.red.color, for: .normal)
    deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: constants.bodySize)
    deleteButton.backgroundColor = Colors.backSecondary.color
    deleteButton.configuration?.contentInsets = .init(top: 17, leading: 16, bottom: 17, trailing: 16)
    deleteButton.layer.cornerRadius = constants.cornerRadius
    deleteButton.addTarget(self, action: #selector(deleteTodo), for: .touchUpInside)
}

// Setup constrains of TodoItemsViewController

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

        importancyView.heightAnchor.constraint(greaterThanOrEqualToConstant: 54),
        deadlineView.heightAnchor.constraint(greaterThanOrEqualToConstant: 54),

        deleteButton.heightAnchor.constraint(equalToConstant: 56)
    ])
}
