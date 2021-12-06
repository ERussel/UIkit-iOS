import Foundation

/**
 *  Struct is designed to represent numpad button style
 **/
public struct NumpadButtonStyle {
    public let fillColor: UIColor?

    public let highlightedFillColor: UIColor?

    public let titleColor: UIColor?

    public let titleFont: UIFont?

    public let highlightedTitleColor: UIColor?

    public let shadowOpacity: Float?

    public let shadowColor: UIColor?

    public let shadowRadius: CGFloat?

    public let shadowOffset: CGSize?

    public init(
        fillColor: UIColor? = nil,
        highlightedFillColor: UIColor? = nil,
        titleColor: UIColor? = nil,
        titleFont: UIFont? = nil,
        highlightedTitleColor: UIColor? = nil,
        shadowOpacity: Float? = nil,
        shadowColor: UIColor? = nil,
        shadowRadius: CGFloat? = nil,
        shadowOffset: CGSize? = nil
    ) {
        self.fillColor = fillColor
        self.highlightedFillColor = highlightedFillColor
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.highlightedTitleColor = highlightedTitleColor
        self.shadowOpacity = shadowOpacity
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
    }
}
