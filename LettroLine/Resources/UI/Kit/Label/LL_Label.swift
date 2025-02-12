//
//  LL_Label.swift
//  LettroLine
//
//  Created by BLIN Michael on 12/02/2025.
//

import Foundation
import UIKit

public class LL_Label : UILabel {
	
	public var contentInsets:UIEdgeInsets = .zero {
		
		didSet {
			
			layoutIfNeeded()
		}
	}
	public override var intrinsicContentSize: CGSize {
		
		get {
			
			var size: CGSize = super.intrinsicContentSize
			size.width += contentInsets.left + contentInsets.right
			size.height += contentInsets.top + contentInsets.bottom
			return size
		}
	}
	
	convenience init(_ string:String?) {
		
		self.init(frame: .zero)
		
		text = string
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		layer.masksToBounds = true
		numberOfLines = 0
		font = Fonts.Content.Text.Regular
		textColor = Colors.Content.Text
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
		
		let insetRect = bounds.inset(by: contentInsets)
		let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
		let invertedInsets = UIEdgeInsets(top: -contentInsets.top, left: -contentInsets.left, bottom: -contentInsets.bottom, right: -contentInsets.right)
		return textRect.inset(by: invertedInsets)
	}
	
	public override func drawText(in rect: CGRect) {
		
		super.drawText(in: rect.inset(by: contentInsets))
	}
}
