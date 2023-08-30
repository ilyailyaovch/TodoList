import UIKit

final class TableViewAddCell: UITableViewCell, UITextFieldDelegate {

    var addCellTapped: (() -> Void)?

    static let identifier: String = "TableViewAddCell"

    let textView = UILabel()
    let imagePlus = UIImage(systemName: "plus.circle.fill")

    // MARK: - Override init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupText()
        setupViews()
        setupConstraints()
        addCellTapRecogniser()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setupViews

    func setupViews() {
        contentView.backgroundColor = Colors.backSecondary.color
        contentView.addSubview(textView)
    }

    func setupText() {
        textView.text = "Новое"
        textView.textColor = Colors.labelTertiary.color
    }

    // MARK: - setupConstraints

    func setupConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16 + 24 + 12),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - addCellTapRecogniser

    func addCellTapRecogniser() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickAddCell))
        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(tap)
    }
}

// MARK: - @objc

extension TableViewAddCell {

    @objc func clickAddCell(switcher: UISwitch) {
        addCellTapped?()
    }
}
