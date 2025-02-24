//
//  LL_Grid_Letter_CollectionViewCell.swift
//  LettroLine
//
//  Created by BLIN Michael on 12/02/2025.
//

import UIKit

public class LL_Grid_Letter_CollectionViewCell : LL_CollectionViewCell {
	
	public class override var identifier: String {
		
		return "gridLetterCellIdentifier"
	}
	
	public var letter:String? {
		
		didSet {
			
			label.text = letter
		}
	}
	private lazy var label:LL_Letter_Label = .init()
	public override var isSelected: Bool {
		
		didSet {
			
			if isSelected {
				
				LL_Audio.shared.playTap()
				UIApplication.feedBack(.On)
			}
			
			label.isSelected = isSelected
		}
	}
	public var isFirst:Bool = false {
		
		didSet {
			
			label.isFirst = isFirst
		}
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		contentView.addSubview(label)
		label.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
