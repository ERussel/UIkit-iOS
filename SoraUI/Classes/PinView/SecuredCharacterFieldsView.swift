/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import UIKit

open class SecuredCharacterFieldsView: BaseCharacterFieldsView {
    public struct Style {
        public let normalFillColor: UIColor
        public let highlightedFillColor: UIColor
        public let normalStrokeColor: UIColor
        public let highlightedStrokeColor: UIColor
        public let strokeWidth: CGFloat
        public let fieldRadius: CGFloat
    }

    open var style: Style = Style(
        normalFillColor: .clear,
        highlightedFillColor: .white,
        normalStrokeColor: .white,
        highlightedStrokeColor: .clear,
        strokeWidth: 1.0,
        fieldRadius: 10.0
    ) {
        didSet {
            setNeedsDisplay()
        }
    }

    open var fillColor: UIColor {
        get {
            style.highlightedFillColor
        }

        set {
            style = Style(
                normalFillColor: style.normalFillColor,
                highlightedFillColor: newValue,
                normalStrokeColor: style.normalStrokeColor,
                highlightedStrokeColor: style.highlightedStrokeColor,
                strokeWidth: style.strokeWidth,
                fieldRadius: style.fieldRadius
            )
        }
    }

    open var strokeColor: UIColor {
        get {
            style.normalStrokeColor
        }

        set {
            style = Style(
                normalFillColor: style.normalFillColor,
                highlightedFillColor: style.highlightedFillColor,
                normalStrokeColor: newValue,
                highlightedStrokeColor: style.highlightedStrokeColor,
                strokeWidth: style.strokeWidth,
                fieldRadius: style.fieldRadius
            )
        }
    }

    open var strokeWidth: CGFloat {
        get {
            style.strokeWidth
        }

        set {
            style = Style(
                normalFillColor: style.normalFillColor,
                highlightedFillColor: style.highlightedFillColor,
                normalStrokeColor: style.normalStrokeColor,
                highlightedStrokeColor: style.highlightedStrokeColor,
                strokeWidth: newValue,
                fieldRadius: style.fieldRadius
            )
        }
    }

    open var fieldRadius: CGFloat {
        get {
            style.fieldRadius
        }

        set {
            style = Style(
                normalFillColor: style.normalFillColor,
                highlightedFillColor: style.highlightedFillColor,
                normalStrokeColor: style.normalStrokeColor,
                highlightedStrokeColor: style.highlightedStrokeColor,
                strokeWidth: style.strokeWidth,
                fieldRadius: newValue
            )
        }
    }

    // MARK: Draw

    open override func draw(_ rect: CGRect) {
        super.draw(rect)

        if let context = UIGraphicsGetCurrentContext() {
            let contentSize = self.intrinsicContentSize
            let originX = self.bounds.origin.x + self.bounds.size.width / 2.0 - contentSize.width / 2.0
            let originY = self.bounds.origin.y + self.bounds.size.height / 2.0 - fieldSize.height / 2.0

            context.setLineWidth(strokeWidth)

            let yPos = originY + fieldSize.height / 2.0
            for index in 0..<numberOfCharacters {
                let xPos = originX + CGFloat(index) * (fieldSize.width + fieldSpacing) + fieldSize.width / 2.0

                if index < characters.count {
                    context.setStrokeColor(style.highlightedStrokeColor.cgColor)
                    context.setFillColor(style.highlightedFillColor.cgColor)
                } else {
                    context.setStrokeColor(style.normalStrokeColor.cgColor)
                    context.setFillColor(style.normalFillColor.cgColor)
                }

                context.addArc(center: CGPoint(x: xPos, y: yPos),
                               radius: fieldRadius,
                               startAngle: 0.0,
                               endAngle: CGFloat(2.0 * Double.pi),
                               clockwise: true)

                context.drawPath(using: .fillStroke)
            }
        }
    }
}
