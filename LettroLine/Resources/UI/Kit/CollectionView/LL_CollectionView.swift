//
//  LL_CollectionView.swift
//  LettroLine
//
//  Created by BLIN Michael on 13/02/2025.
//

import UIKit

public class LL_CollectionView : UICollectionView {
	
	public var isHeightDynamic:Bool = false {
		
		didSet {
			
			isScrollEnabled = !isHeightDynamic
		}
	}
	public override var contentSize: CGSize {
		
		didSet {
			
			if isHeightDynamic {
				
				self.invalidateIntrinsicContentSize()
			}
		}
	}
	public override var intrinsicContentSize: CGSize {
		
		if isHeightDynamic {
			
			return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
		}
		
		return super.intrinsicContentSize
	}
	
	public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		
		super.init(frame: frame, collectionViewLayout: layout)
		
		backgroundColor = .clear
		register(LL_CollectionViewCell.self, forCellWithReuseIdentifier: LL_CollectionViewCell.identifier)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
