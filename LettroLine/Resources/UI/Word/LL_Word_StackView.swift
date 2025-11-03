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

//				// Ajouter un spacer invisible au début pour centrer
//				let leadingSpacer = UIView()
//				leadingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
//				leadingSpacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//				addArrangedSubview(leadingSpacer)
//				setCustomSpacing(0, after: leadingSpacer)
				
				for i in 0..<word.count {
					
					let letterLabel: LL_Letter_View = .init()
					letterLabel.isSelected = isPrimary
//					letterLabel.setContentHuggingPriority(.required, for: .horizontal)
//					letterLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
					addArrangedSubview(letterLabel)
					
					UIApplication.wait(0.3*Double(i)) {
						
						let index = word.index(word.startIndex, offsetBy: i)
						letterLabel.letter = String(word[index])
					}
					
					if i == word.count - 1 {
						
						setCustomSpacing(0, after: letterLabel)
					}
				}

//				// Ajouter un spacer invisible à la fin pour centrer
//				let trailingSpacer = UIView()
//				trailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
//				trailingSpacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//				addArrangedSubview(trailingSpacer)
			}
		}
	}
	public var adjustLetterSize:Bool = false
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .horizontal
		alignment = .center
		distribution = .fill
		spacing = UI.Margins/4
		setContentHuggingPriority(.required, for: .horizontal)
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		let maxLetters = CGFloat(LL_Words.shared.maxLetters)
		let numberOfSpacings = maxLetters - 1.0
		
		var letterWidth = ((superview?.frame.size.width ?? 0) - (2*UI.Margins) - (numberOfSpacings * spacing)) / maxLetters
//		letterWidth = max(2.25 * UI.Margins, letterWidth)
		
		if frame.size.width > 0 && letterWidth > 0 {
			
			let labels = arrangedSubviews.compactMap({ $0 as? LL_Letter_View })
			
			labels.forEach {
				
				$0.snp.remakeConstraints { make in
					
					make.size.equalTo(letterWidth)
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
