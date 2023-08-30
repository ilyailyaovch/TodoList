import UIKit

final class TableViewCell: UITableViewCell {

    var valueDidChange: (() -> Void)?

    static let identifier: String = "TableViewCell"

    let stackTextViews = UIStackView()
    var textView = UILabel()
    var stackDeadline = UIStackView()
    let calendarImage = UIImageView(image: UIImage(systemName: "calendar"))
    var deadlineView = UILabel()

    var stackStatusViews = UIStackView()
    var circleStatView = UIButton()
    var importancyStatView = UIImageView()
    let shevronView = UIImageView(image: Icon.Shevron.image)

    let constants = Constants()

    let strikethroughStyle = NSAttributedString(
        string: "Text",
        attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
    )

    // MARK: - Override init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - configureCell

    func configureCell(with item: TodoItem) {

        textView.text = item.text
        textView.textColor = Colors.labelPrimary.color
        textView.strikeThrough(item.isCompleted)

        if item.isCompleted == true {
            circleStatView.setImage(Icon.CircleCompleted.image, for: .normal)
            textView.textColor = Colors.labelTertiary.color
            importancyStatView.isHidden = true
        } else if item.importancy == .important {
            circleStatView.setImage(Icon.CircleImportant.image, for: .normal)
            importancyStatView.isHidden = false
        } else {
            circleStatView.setImage(Icon.CircleEmpty.image, for: .normal)
            importancyStatView.isHidden = true
        }

        if let deadline = item.deadline {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM"
            deadlineView.text = dateFormatter.string(from: deadline)
            stackDeadline.isHidden = false
        } else {
            stackDeadline.isHidden = true
        }
    }

    // MARK: - setupViews

    func setupViews() {
        contentView.backgroundColor = Colors.backSecondary.color

        setupStackStatusViews()
        setupTextView()
        setupDeadlineView()
        setupStackTextView()

        contentView.addSubview(stackStatusViews)
        contentView.addSubview(stackTextViews)
        contentView.addSubview(shevronView)
    }

    func setupStackStatusViews() {
        importancyStatView.image = Icon.Important.image

        circleStatView.addTarget(self, action: #selector(circleStatViewTapped), for: .touchUpInside)

        stackStatusViews.axis = .horizontal
        stackStatusViews.alignment = .center
        stackStatusViews.spacing = 12

        stackStatusViews.addArrangedSubview(circleStatView)
        stackStatusViews.addArrangedSubview(importancyStatView)
    }

    func setupTextView() {
        textView.numberOfLines = 3
        textView.font = UIFont.systemFont(ofSize: constants.bodySize)
        textView.textColor = Colors.labelPrimary.color
    }

    func setupDeadlineView() {
        calendarImage.tintColor = Colors.labelTertiary.color
        deadlineView.textColor = Colors.labelTertiary.color
        deadlineView.font = UIFont.systemFont(ofSize: constants.footnoteSize)

        stackDeadline.axis = .horizontal
        stackDeadline.alignment = .center
        stackDeadline.spacing = 2

        stackDeadline.addArrangedSubview(calendarImage)
        stackDeadline.addArrangedSubview(deadlineView)
    }

    func setupStackTextView() {
        stackTextViews.axis = .vertical
        stackTextViews.alignment = .leading
        stackTextViews.distribution = .fill

        stackTextViews.addArrangedSubview(textView)
        stackTextViews.addArrangedSubview(stackDeadline)
    }

    // MARK: - setupConstraints

    func setupConstraints() {
        stackStatusViews.translatesAutoresizingMaskIntoConstraints = false
        circleStatView.translatesAutoresizingMaskIntoConstraints = false
        importancyStatView.translatesAutoresizingMaskIntoConstraints = false
        stackTextViews.translatesAutoresizingMaskIntoConstraints = false
        calendarImage.translatesAutoresizingMaskIntoConstraints = false
        shevronView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackStatusViews.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackStatusViews.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            circleStatView.widthAnchor.constraint(equalToConstant: 24),
            circleStatView.heightAnchor.constraint(equalToConstant: 24),

            importancyStatView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            importancyStatView.leadingAnchor.constraint(equalTo: circleStatView.trailingAnchor, constant: 12),

            stackTextViews.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackTextViews.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stackTextViews.leadingAnchor.constraint(equalTo: stackStatusViews.trailingAnchor, constant: 16),
            stackTextViews.trailingAnchor.constraint(equalTo: shevronView.leadingAnchor, constant: -16),

            calendarImage.heightAnchor.constraint(equalToConstant: 16),
            calendarImage.widthAnchor.constraint(equalToConstant: 16),

            shevronView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            shevronView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            shevronView.widthAnchor.constraint(equalToConstant: 7)
        ])
    }
}

// MARK: - @objc

extension TableViewCell {

    @objc func circleStatViewTapped(_ sender: UIButton) {
        self.valueDidChange?()
    }
}

// MARK: - extension UILabel

extension UILabel {
    func strikeThrough(_ isStrikeThrough: Bool = true) {
        guard let text = self.text else {
            return
        }

        if isStrikeThrough {
            let attributeString =  NSMutableAttributedString(string: text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0,length: attributeString.length))
            self.attributedText = attributeString
        } else {
            let attributeString =  NSMutableAttributedString(string: text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                         value: [""],
                                         range: NSRange(location: 0,length: attributeString.length))
            self.attributedText = attributeString
        }
    }
}
