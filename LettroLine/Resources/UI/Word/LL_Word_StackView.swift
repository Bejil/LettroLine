//
//  LL_Word_StackView.swift
//  LettroLine
//
//  Created by BLIN Michael on 14/02/2025.
//

import UIKit

public class LL_Word_StackView : UIStackView {

	public var isPrimary:Bool = false
	public var word: String? {
		
		didSet {
			
			arrangedSubviews.forEach { $0.removeFromSuperview() }
			
			if let word {
				
				word.forEach({ _ in
					
					let letterLabel: LL_Letter_View = .init()
					letterLabel.isSelected = isPrimary
					addArrangedSubview(letterLabel)
				})
				
				let labels = arrangedSubviews.compactMap({ $0 as? LL_Letter_View })
				
				for i in 0..<labels.count {
					
					UIApplication.wait(0.3*Double(i)) {
							
						let label = labels[i]
						let index = word.index(word.startIndex, offsetBy: i)
						label.letter = String(word[index])
					}
				}
			}
		}
	}
	public var adjustLetterSize:Bool = false
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .horizontal
		alignment = .center
		spacing = UI.Margins/4
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		let ratio = CGFloat(adjustLetterSize ? word?.count ?? LL_Words.shared.maxLetters : LL_Words.shared.maxLetters)
		
		var size = (frame.size.width - ((ratio - 1.0) * spacing))/ratio
		size = max(2.25 * UI.Margins, size)
		
		if superview != nil && size > 0 {
			
			arrangedSubviews.forEach {
				
				$0.snp.remakeConstraints { make in
					make.size.equalTo(size)
				}
			}
		}
	}
	
	public func select(_ character:Character?) {
		
		if let character {
			
			UIApplication.feedBack(.On)
			
			if let letterView = arrangedSubviews.compactMap({ $0 as? LL_Letter_View }).first(where: { !($0.isSelected ?? false)  && $0.letter?.uppercased() == String(character).uppercased() }) {
				
				letterView.isSelected = true
			}
		}
	}
	
	public func deselectAll() {
		
		UIApplication.feedBack(.Off)
		
		arrangedSubviews.compactMap({ $0 as? LL_Letter_View }).forEach({
			
			$0.isSelected = false
		})
	}
}
