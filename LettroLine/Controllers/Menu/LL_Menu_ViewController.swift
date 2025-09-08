//
//  LL_Menu_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 11/02/2025.
//

import UIKit
import SnapKit

public class LL_Menu_ViewController: LL_ViewController {
	
	private lazy var classicGameStartButton:LL_Button = {
		
		$0.image = UIImage(systemName: "hand.point.up.braille.fill")
		return $0
		
	}(LL_Button(String(key: "menu.classic.button.start")) { _ in
		
		let startClosure:(()->Void) = {
			
			UI.MainController.present(LL_NavigationController(rootViewController: LL_Game_Classic_ViewController()), animated: true)
		}
		
		if LL_Game_Classic.current.score != 0 {
			
			let alertController:LL_Alert_ViewController = .init()
			alertController.title = String(key: "menu.classic.new.alert.title")
			alertController.add(String(key: "menu.classic.new.alert.content"))
			alertController.addDismissButton() { _ in
				
				LL_Game_Classic.current.reset()
				
				startClosure()
			}
			alertController.addCancelButton()
			alertController.present()
		}
		else {
			
			startClosure()
		}
	})
	private lazy var classicGameContinueButton:LL_Button = { button in
		
		button.image = UIImage(systemName: "play.fill")
		button.style = .tinted
		button.snp.makeConstraints { make in
			
			make.width.equalTo(button.snp.height)
		}
		return button
		
	}(LL_Button() { _ in
		
		UI.MainController.present(LL_NavigationController(rootViewController: LL_Game_Classic_ViewController()), animated: true)
	})
	private lazy var challengesGameStartButton:LL_Button = {
		
		$0.type = .tertiary
		$0.image = UIImage(systemName: "figure.strengthtraining.traditional")
		return $0
		
	}(LL_Button(String(key: "menu.challenges.button")) { _ in
		
		let alertController:LL_Alert_ViewController = .init()
		alertController.title = String(key: "menu.challenges.alert.title")
		
		let timeTrialButton = alertController.addButton(title: String(key: "menu.challenges.alert.button.timeTrial")) { _ in
			
			alertController.close {
				
				LL_Challenges_TimeTrial_Game.current.reset()
				UI.MainController.present(LL_NavigationController(rootViewController: LL_Game_Challenges_TimeTrial_ViewController()), animated: true)
			}
		}
		timeTrialButton.subtitle = String(key: "menu.challenges.alert.timeTrial.label")
		timeTrialButton.image = UIImage(systemName: "deskclock.fill")
		
		if let bestScore = UserDefaults.get(.challengesTimeTrialBestScore) as? Int, bestScore > 0 {
			
			timeTrialButton.subtitle = String(key: "menu.challenges.button.subtitle") + "\(bestScore)"
		}
		
		let moveLimitButton = alertController.addButton(title: String(key: "menu.challenges.alert.button.moveLimit")) { _ in
			
			alertController.close {
				
				LL_Challenges_MoveLimit_Game.current.reset()
				UI.MainController.present(LL_NavigationController(rootViewController: LL_Game_Challenges_MoveLimit_ViewController()), animated: true)
			}
		}
		moveLimitButton.subtitle = String(key: "menu.challenges.alert.moveLimit.label")
		moveLimitButton.image = UIImage(systemName: "numbers.rectangle.fill")
		
		if let bestScore = UserDefaults.get(.challengesMoveLimitBestScore) as? Int, bestScore > 0 {
			
			moveLimitButton.subtitle = String(key: "menu.challenges.button.subtitle") + "\(bestScore)"
		}
		
		let noLiftButton = alertController.addButton(title: String(key: "menu.challenges.alert.button.noLift")) { _ in
			
			alertController.close {
				
				LL_Challenges_NoLift_Game.current.reset()
				UI.MainController.present(LL_NavigationController(rootViewController: LL_Game_Challenges_NoLift_ViewController()), animated: true)
			}
		}
		noLiftButton.subtitle = String(key: "menu.challenges.alert.noLift.label")
		noLiftButton.image = UIImage(systemName: "point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath")
		
		if let bestScore = UserDefaults.get(.challengesNoLiftBestScore) as? Int, bestScore > 0 {
			
			noLiftButton.subtitle = String(key: "menu.challenges.button.subtitle") + "\(bestScore)"
		}
		
		alertController.addCancelButton()
		alertController.present()
	})
	private lazy var storyButton:LL_Button = {
		
		$0.type = .secondary
		$0.image = UIImage(systemName: "text.book.closed.fill")
		return $0
		
	}(LL_Button(String(key: "menu.story.button")) { [weak self] _ in
		
		let viewController = LL_Story_Selection_ViewController()
		viewController.modalPresentationStyle = .pageSheet
		UI.MainController.present(LL_NavigationController(rootViewController: viewController), animated: true)
	})
	private lazy var bannerView = LL_Ads.shared.presentBanner(Ads.Banner.Menu, self)
	private lazy var stackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = 1.5*UI.Margins
		
		let titleLabel:LL_Label = .init(String(key: "menu.title"))
		titleLabel.font = Fonts.Content.Title.H1.withSize(Fonts.Content.Title.H1.pointSize + 20)
		titleLabel.textColor = Colors.Content.Title
		titleLabel.textAlignment = .center
		$0.addArrangedSubview(titleLabel)
		
		let baselineLabel:LL_Label = .init(String(key: "menu.subtitle"))
		baselineLabel.textAlignment = .center
		$0.addArrangedSubview(baselineLabel)
		$0.setCustomSpacing(1.5*$0.spacing, after: baselineLabel)
		
		let classicGameStackView:UIStackView = .init(arrangedSubviews: [classicGameStartButton,classicGameContinueButton])
		classicGameStackView.axis = .horizontal
		classicGameStackView.spacing = UI.Margins
		classicGameStackView.alignment = .fill
		$0.addArrangedSubview(classicGameStackView)
		
		$0.addArrangedSubview(storyButton)
		$0.addArrangedSubview(challengesGameStartButton)
		$0.setCustomSpacing(UI.Margins*3, after: challengesGameStartButton)
		
		let ranksButton:LL_Button = .init(String(key: "menu.ranks.button")) { [weak self] _ in
			
			UI.MainController.present(LL_NavigationController(rootViewController: LL_Ranks_ViewController()), animated: true)
		}
		ranksButton.style = .tinted
		ranksButton.image = UIImage(systemName: "trophy.fill")
		$0.addArrangedSubview(ranksButton)
		
		if LL_Ads.shared.shouldDisplayAd {
			
			let adsButton:LL_Button = .init(String(key: "menu.ads.button")) { [weak self] _ in
				
				LL_InAppPurchase.shared.promptInAppPurchaseAlert(withCapping: false)
			}
			adsButton.type = .primary
			adsButton.image = UIImage(systemName: "rectangle.stack.badge.minus")
			$0.addArrangedSubview(adsButton)
		}
		
		return $0
		
	}(UIStackView())
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.rightBarButtonItem = LL_Settings_BarButtonItem()
		
		let menuStackView:UIStackView = .init(arrangedSubviews: [stackView])
		menuStackView.axis = .horizontal
		menuStackView.alignment = .center
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [menuStackView,bannerView])
		contentStackView.spacing = 2*UI.Margins
		contentStackView.axis = .vertical
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .init(horizontal: 3*UI.Margins)
		
		let stackView:UIStackView = .init(arrangedSubviews: [contentStackView,LL_User_StackView()])
		stackView.spacing = 2*UI.Margins
		stackView.axis = .vertical
		
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.left.right.equalTo(view.safeAreaLayoutGuide)
			make.top.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
			make.bottom.equalToSuperview()
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		classicGameContinueButton.isHidden = LL_Game_Classic.current.score == 0
		classicGameContinueButton.badge = "\(LL_Game_Classic.current.score)"
		
		if let bestScore = UserDefaults.get(.classicBestScore) as? Int, bestScore > 0 {
			
			classicGameStartButton.subtitle = String(key: "menu.classic.button.subtitle") + "\(bestScore)"
		}
		else {
			
			classicGameStartButton.subtitle = nil
		}
		
		storyButton.badge = nil
		
		LL_Game_Story.getAll { [weak self] stories in
			
			if let count = stories?.notStarted?.count, count > 0 {
				
				self?.storyButton.badge = "\(count)"
			}
		}
		
		stackView.animate()
		
		bannerView.refresh()
	}
}
