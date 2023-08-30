import UIKit

class ColorPickerView: UIView {

    var selectedColor: UIColor?

    var stackView = UIStackView()
    var titleLabel = UILabel()
    var colorLabel = UITextView()
    var switchButton = UISwitch()
    var scrollView = UIScrollView()
    var colorPicker = UIView()

    let constants = Constants()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addSubview(stackView)
        addSubview(switchButton)
        addSubview(colorPicker)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        titleLabel.text = "Цвет"
        titleLabel.font = UIFont.systemFont(ofSize: constants.bodySize)
        titleLabel.textColor = Colors.labelPrimary.color

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(colorLabel)

        switchButton.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        switchButton.backgroundColor = Colors.supportOverlay.color
        switchButton.layer.cornerRadius = constants.cornerRadius

        scrollView.isHidden = true
        colorPicker.isHidden = true
    }

    func setupConstraints() {

        stackView.translatesAutoresizingMaskIntoConstraints = false
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        switchButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 9),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),

            switchButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            switchButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

extension ColorPickerView {

    @objc func valueChanged(switcher: UISwitch) {
        print("Color")
    }
}
