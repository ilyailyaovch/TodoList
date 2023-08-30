import UIKit

enum Colors: String {

    //  Support colors
    case supportSeparator
    case supportOverlay
    case supportNavBarBlur

    //  Label colors
    case labelPrimary
    case labelSecondary
    case labelTertiary
    case labelDisable

    //  Colors
    case red
    case green
    case blue
    case gray
    case grayLight
    case white

    //  Background colors
    case backIOSPrimary
    case backPrimary
    case backSecondary
    case backElevated

    var color: UIColor { return UIColor(named: rawValue) ?? .orange}
}
