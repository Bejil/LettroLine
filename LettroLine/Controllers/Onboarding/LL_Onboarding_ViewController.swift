//
//  LL_Onboarding_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 10/03/2025.
//

import Foundation
import UIKit

public class LL_Onboarding_ViewController : LL_ViewController {
	
	public var completion:(()->Void)?
	private lazy var stackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = 2*UI.Margins
		$0.addArrangedSubview(.init())
		
		let titleLabel: LL_Label = .init(String(key: "onboarding.title"))
		titleLabel.font = Fonts.Content.Title.H1.withSize(Fonts.Content.Title.H1.pointSize + 20)
		titleLabel.textColor = Colors.Content.Title
		titleLabel.textAlignment = .center
		$0.addArrangedSubview(titleLabel)
		
		let emojiLabel: LL_Label = .init("👋")
		emojiLabel.font = Fonts.Content.Text.Regular.withSize(Fonts.Size+120)
		emojiLabel.textAlignment = .center
		$0.addArrangedSubview(emojiLabel)
			
		let contentLabel: LL_Label = .init(String(key: "onboarding.content"))
		contentLabel.font = Fonts.Content.Text.Regular.withSize(Fonts.Size+2)
		contentLabel.textAlignment = .center
		$0.addArrangedSubview(contentLabel)
			
		let button:LL_Button = .init(String(key: "onboarding.button")) { [weak self] _ in
			
			self?.dismiss(self?.completion)
		}
		$0.addArrangedSubview(button)
		
		$0.addArrangedSubview(.init())
		return $0
		
	}(UIStackView())
	
	public override func loadView() {
		
		super.loadView()
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [stackView])
		contentStackView.axis = .horizontal
		contentStackView.alignment = .center
		view.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(4*UI.Margins)
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		stackView.animate()
	}
}
