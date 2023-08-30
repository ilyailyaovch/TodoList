import UIKit

class CalendarView: UIView {

    var datePicker = UIDatePicker()

    var valueDidChange: ((Date) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCalendarView()
        addSubview(datePicker)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCalendarView() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = Locale.autoupdatingCurrent
        datePicker.minimumDate = .now
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
    }

    func setupConstraints() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo:topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            datePicker.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
}

extension CalendarView {

    @objc func datePickerChanged(_ sender: UISegmentedControl) {
        valueDidChange?(datePicker.date)
    }
}
