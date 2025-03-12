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
				
				addArrangedSubview(.init())
				
				word.forEach({ _ in
					
					let letterLabel: LL_Letter_Label = .init()
					letterLabel.isSelected = isPrimary
					addArrangedSubview(letterLabel)
					letterLabel.snp.makeConstraints { make in
						make.width.equalTo(snp.height)
					}
				})
				
				let labels = arrangedSubviews.compactMap({ $0 as? LL_Letter_Label })
				
				for i in 0..<labels.count {
					
					UIApplication.wait(0.3*Double(i)) {
							
						let label = labels[i]
						let index = word.index(word.startIndex, offsetBy: i)
						label.text = String(word[index])
					}
				}
				
				addArrangedSubview(.init())
			}
		}
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .horizontal
		alignment = .center
		distribution = .equalSpacing
		
		snp.makeConstraints { make in
			make.height.equalTo(UI.Margins * 3)
		}
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public func select(_ character:Character?) {
		
		if let character {
			
			UIApplication.feedBack(.On)
			
			arrangedSubviews.compactMap({ $0 as? LL_Letter_Label }).first(where: { !($0.isSelected ?? false) && $0.text == String(character).uppercased() })?.isSelected = true
		}
	}
	
	public func deselectAll() {
		
		UIApplication.feedBack(.Off)
		
		arrangedSubviews.compactMap({ $0 as? LL_Letter_Label }).forEach({
			
			$0.isSelected = false
		})
	}
}
