import UIKit

enum Icon: String {
    case Low = "Low"
    case Important = "Important"

    case PlusButton = "PlusButton"
    case Shevron = "Shevron"

    case CircleCompleted = "CircleCompleted"
    case CircleEmpty = "CircleEmpty"
    case CircleImportant = "CircleImportant"
    case Ellipsis = "Ellipsis"
    case EllipsisFade = "EllipsisFade"

    var image: UIImage? {return UIImage(named: rawValue)}
}
