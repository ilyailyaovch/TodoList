import UIKit

class DeadlineView: UIView {

    var valueDidChange: ((Bool) -> Void)?

    var deadlineDidClick: (() -> Void)?

    var deadline: Date? {
        didSet {
            if let deadline = deadline {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM YYYY"
                subTitleLabel.text = dateFormatter.string(from: deadline)

                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.subTitleLabel.isHidden = false
                    self?.subTitleLabel.layer.opacity = 1
                })
                switchButton.setOn(true, animated: false)
            } else {
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.subTitleLabel.text = ""
                    self?.subTitleLabel.isHidden = true
                    self?.subTitleLabel.layer.opacity = 0
                })
                return
            }
        }
    }

    var titleLabel = UILabel()
    var subTitleLabel = UILabel()
    var stackView = UIStackView()
    var switchButton = UISwitch()

    let constants = Constants()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        addSubview(stackView)
        addSubview(switchButton)
        subTitleLabelTapRecogniser()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        titleLabel.text = "Сделать до"
        titleLabel.font = UIFont.systemFont(ofSize: constants.bodySize)
        titleLabel.textColor = Colors.labelPrimary.color

        subTitleLabel.font = UIFont.systemFont(ofSize: constants.footnoteSize)
        subTitleLabel.textColor = Colors.blue.color
        subTitleLabel.isHidden = true

        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subTitleLabel)

        switchButton.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        switchButton.backgroundColor = Colors.supportOverlay.color
        switchButton.layer.cornerRadius = constants.cornerRadius
    }

    func setupConstraints() {

        stackView.translatesAutoresizingMaskIntoConstraints = false
        switchButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 9),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            switchButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            switchButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func subTitleLabelTapRecogniser() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickSubTitle))
        stackView.isUserInteractionEnabled = true
        stackView.addGestureRecognizer(tap)
    }
}

extension DeadlineView {

    @objc func valueChanged(switcher: UISwitch) {
        valueDidChange?(switcher.isOn)
    }

    @objc func clickSubTitle(switcher: UISwitch) {
        deadlineDidClick?()
    }
}
