//
//  LL_Grid_Letter_CollectionViewCell.swift
//  LettroLine
//
//  Created by BLIN Michael on 12/02/2025.
//

import UIKit

public class LL_Grid_Letter_CollectionViewCell : UICollectionViewCell {
	
	public class var identifier: String {
		
		return "gridLetterCellIdentifier"
	}
	
	public var letter:String? {
		
		didSet {
			
			label.text = letter
		}
	}
	private lazy var label:LL_Label = {
		
		$0.font = Fonts.Content.Title.H1
		$0.textAlignment = .center
		return $0
		
	}(LL_Label())
	public override var isSelected: Bool {
		
		didSet {
			
			if isSelected {
				
				pulse(.white)
			}
		}
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		contentView.layer.cornerRadius = UI.CornerRadius/2
		contentView.clipsToBounds = true
		
		let visualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .regular))
		contentView.addSubview(visualEffectView)
		visualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		visualEffectView.contentView.addSubview(label)
		label.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
