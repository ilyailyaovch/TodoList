import UIKit

class ImportancyView: UIView {

    var valueDidChange: ((Importancy) -> Void)?

    var importancy: Importancy? {
        didSet {
            guard
                let importancy = importancy
            else { return }

            switch importancy {
            case .low:
                segControl.selectedSegmentIndex = 0
            case .normal:
                segControl.selectedSegmentIndex = 1
            case .important:
                segControl.selectedSegmentIndex = 2
            }
        }
    }

    let titleLabel = UILabel()
    let segControl = UISegmentedControl()

    let constants = Constants()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        addSubview(titleLabel)
        addSubview(segControl)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        titleLabel.text = "Важность"
        titleLabel.font = UIFont.systemFont(ofSize: constants.bodySize)
        titleLabel.textColor = Colors.labelPrimary.color

        segControl.insertSegment(with: Icon.Low.image, at: 0, animated: false)
        segControl.insertSegment(withTitle: "нет", at: 1, animated: false)
        segControl.insertSegment(with: Icon.Important.image, at: 2, animated: false)
        segControl.selectedSegmentIndex = 1
        segControl.backgroundColor = Colors.supportOverlay.color
        segControl.selectedSegmentTintColor = Colors.backElevated.color

        segControl.addTarget(self, action: #selector(segControlValueChanged), for: .valueChanged)
        segControl.addTarget(self, action: #selector(segControlValueChanged), for: .touchUpInside)

    }

    func setupConstraints() {

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        segControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),

            segControl.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            segControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            segControl.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            segControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            segControl.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
}

extension ImportancyView {

    @objc func segControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            valueDidChange?(Importancy.low)
            importancy = Importancy.low
        case 1:
            valueDidChange?(Importancy.normal)
            importancy = Importancy.normal
        case 2:
            valueDidChange?(Importancy.important)
            importancy = Importancy.important
        default:
            valueDidChange?(Importancy.normal)
        }
    }
}
