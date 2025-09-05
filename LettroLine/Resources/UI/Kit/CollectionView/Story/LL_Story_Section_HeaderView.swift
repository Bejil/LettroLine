//
//  LL_Story_Section_HeaderView.swift
//  LettroLine
//
//  Created by BLIN Michael on 14/02/2025.
//

import UIKit
import SnapKit

public class LL_Story_Section_HeaderView: UICollectionReusableView {
	
	public class var identifier: String {
		
		return "storySectionHeaderViewIdentifier"
	}
	public var title: String? {
		
		didSet {
			
			titleLabel.text = title
		}
	}
	public var count:Int? {
		
		didSet {
			
			let count = count ?? 0
			countLabel.isHidden = count == 0
			countLabel.text = "\(count)"
		}
	}
	
	private lazy var titleLabel: LL_Label = {
		
		$0.font = Fonts.Content.Title.H2
		$0.textColor = Colors.Content.Title
		$0.textAlignment = .left
		return $0
		
	}(LL_Label())
	private lazy var countLabel:LL_Label = {
		
		$0.isHidden = true
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size)
		$0.textColor = .white
		$0.layer.cornerRadius = 6
		$0.backgroundColor = Colors.Button.Badge
		$0.contentInsets = .init(horizontal: UI.Margins/3, vertical: 3)
		$0.textAlignment =  .center
		$0.layer.cornerRadius = UI.Margins/2
		return $0
		
	}(LL_Label())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		let stackView:UIStackView = .init(arrangedSubviews: [titleLabel,countLabel,.init()])
		stackView.axis = .horizontal
		stackView.spacing = UI.Margins
		stackView.alignment = .center
		addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.left.right.equalToSuperview().inset(UI.Margins)
			make.top.bottom.equalToSuperview()
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func prepareForReuse() {
		
		super.prepareForReuse()
		
		countLabel.isHidden = true
	}
}
