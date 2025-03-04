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
				
				LL_Audio.shared.play(.tap)
				UIApplication.feedBack(.On)
			}
			
			label.isSelected = isSelected
		}
	}
	public var isFirst:Bool = false {
		
		didSet {
			
			label.isFirst = isFirst
			
			startTimers()
		}
	}
	public var isBonus:Bool = false {
		
		didSet {
			
			startTimers()
		}
	}
	private var firstTimer: Timer?
	private var bonusTimer: Timer?
	
	deinit {
		
		resetTimers()
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
	
	public override func prepareForReuse() {
		
		super.prepareForReuse()
		
		resetTimers()
	}
	
	public func resetTimers() {
		
		firstTimer?.invalidate()
		firstTimer = nil
		
		bonusTimer?.invalidate()
		bonusTimer = nil
	}
	
	public func startTimers() {
		
		resetTimers()
		
		if isFirst {
			
			firstTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { [weak self] _ in
				
				self?.pulse(Colors.Tertiary)
			})
		}
		
		if isBonus {
			
			bonusTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { [weak self] _ in
				
				self?.pulse()
			})
		}
	}
}
