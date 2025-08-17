//
//  LL_Ranks_TableViewCell.swift
//  LettroLine
//
//  Created by BLIN Michael on 09/08/2025.
//

import UIKit

public class LL_Ranks_TableViewCell : LL_TableViewCell {
	
	public override class var identifier: String {
		
		return "ranksTableViewCellIdentifier"
	}
	public var rank:Int? {
		
		didSet {
			
			rankButton.title = "\(rank ?? 0)"
		}
	}
	public var object:LL_TimeTrial_Game.FirebaseObject? {
		
		didSet {
			
			rankButton.isPrimary = !(object?.uuid == UserDefaults.get(.userId) as? String)
			rankButton.style = !(object?.uuid == UserDefaults.get(.userId) as? String) ? .tinted : .solid
			nameLabel.text = "\(object?.name ?? String(key: "ranks.anonymous"))"
			scoreLabel.text = "\(object?.score ?? 0) " + String(key: "ranks.points")
		}
	}
	private lazy var rankButton: LL_Button = {
		
		$0.isUserInteractionEnabled = false
		$0.setContentHuggingPriority(.init(1000), for: .horizontal)
		return $0
		
	}(LL_Button())
	private lazy var nameLabel: LL_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.numberOfLines = 1
		$0.adjustsFontSizeToFitWidth = true
		$0.minimumScaleFactor = 0.5
		return $0
		
	}(LL_Label())
	private lazy var scoreLabel: LL_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		return $0
		
	}(LL_Label())
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let textStackView:UIStackView = .init(arrangedSubviews: [nameLabel,scoreLabel])
		textStackView.axis = .vertical
		textStackView.spacing = UI.Margins/2
		
		let stackView:UIStackView = .init(arrangedSubviews: [rankButton,textStackView])
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.spacing = UI.Margins
		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.left.right.equalToSuperview().inset(UI.Margins)
			make.top.bottom.equalToSuperview().inset(UI.Margins)
		}
	}
	
	@MainActor required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
