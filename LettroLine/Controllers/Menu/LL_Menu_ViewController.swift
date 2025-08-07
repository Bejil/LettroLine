//
//  LL_Menu_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 11/02/2025.
//

import UIKit
import SnapKit

public class LL_Menu_ViewController: LL_ViewController {
	
	private lazy var classicGameRankingButton:LL_Button = { button in
		
		button.image = UIImage(systemName: "list.number")
		button.style = .tinted
		button.snp.makeConstraints { make in
			
			make.width.equalTo(button.snp.height)
		}
		return button
		
	}(LL_Button() { button in
		
		button?.isLoading = true
		
		LL_Classic_Game.getAll { objects in
			
			button?.isLoading = false
			
			let alertController:LL_Alert_ViewController = .init()
			alertController.title = String(key: "menu.classic.ranking.alert.title")
			
			let rank = objects?.filter { $0.score ?? 0 > (UserDefaults.get(.timeTrialBestScore) as? Int) ?? 0}.count ?? 0
			alertController.add([String(key: "menu.classic.ranking.alert.content.0"),"\(rank)",String(key: "menu.classic.ranking.alert.content." + (rank == 1 ? "1" : "2")),String(key: "menu.classic.ranking.alert.content.3"),"\(objects?.count ?? 0)"].joined(separator: " "))
			
			alertController.addDismissButton()
			alertController.present()
		}
	})
	private lazy var classicGameStartButton:LL_Button = {
		
		$0.image = UIImage(systemName: "hand.point.up.braille.fill")
		return $0
		
	}(LL_Button(String(key: "menu.classic.button.start")) { _ in
		
		let startClosure:(()->Void) = {
			
			UI.MainController.present(LL_NavigationController(rootViewController: LL_Game_Classic_ViewController()), animated: true)
		}
		
		if LL_Classic_Game.current.score != 0 {
			
			let alertController:LL_Alert_ViewController = .init()
			alertController.title = String(key: "menu.classic.new.alert.title")
			alertController.add(String(key: "menu.classic.new.alert.content"))
			alertController.addDismissButton() { _ in
				
				LL_Classic_Game.current.reset()
				
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
	private lazy var timeTrialGameRankingButton:LL_Button = { button in
		
		button.image = UIImage(systemName: "list.number")
		button.style = .tinted
		button.snp.makeConstraints { make in
			
			make.width.equalTo(button.snp.height)
		}
		return button
		
	}(LL_Button() { button in
		
		button?.isLoading = true
		
		LL_TimeTrial_Game.getAll { objects in
		
			button?.isLoading = false
			
			let alertController:LL_Alert_ViewController = .init()
			alertController.title = String(key: "menu.timetrial.ranking.alert.title")
			
			let rank = objects?.filter { $0.score ?? 0 > (UserDefaults.get(.timeTrialBestScore) as? Int) ?? 0}.count ?? 0
			alertController.add([String(key: "menu.timetrial.ranking.alert.content.0"),"\(rank)",String(key: "menu.timetrial.ranking.alert.content." + (rank == 1 ? "1" : "2")),String(key: "menu.timetrial.ranking.alert.content.3"),"\(objects?.count ?? 0)"].joined(separator: " "))
			
			alertController.addDismissButton()
			alertController.present()
		}
	})
	private lazy var challengesGameStartButton:LL_Button = {
		
		$0.isTertiary = true
		$0.image = UIImage(systemName: "figure.strengthtraining.traditional")
		return $0
		
	}(LL_Button(String(key: "menu.challenges.button")) { _ in
		
		let alertController:LL_Alert_ViewController = .init()
		alertController.title = String(key: "menu.challenges.alert.title")
		alertController.add(String(key: "menu.challenges.alert.content"))
		
		let moveLimitButton = alertController.addButton(title: String(key: "menu.challenges.alert.button.moveLimit")) { _ in
			
			alertController.close {
				
				LL_Challenges_Game.current.reset()
				UI.MainController.present(LL_NavigationController(rootViewController: LL_Game_Challenges_MoveLimit_ViewController()), animated: true)
			}
		}
		moveLimitButton.image = UIImage(systemName: "numbers.rectangle")
		
		if let bestScore = UserDefaults.get(.challengesMoveLimitBestScore) as? Int, bestScore > 0 {
			
			moveLimitButton.subtitle = String(key: "menu.challenges.button.subtitle") + "\(bestScore)"
		}
		else {
			
			moveLimitButton.subtitle = nil
		}
		
		let noLiftButton = alertController.addButton(title: String(key: "menu.challenges.alert.button.noLift")) { _ in
			
			alertController.close {
				
				LL_Challenges_Game.current.reset()
				UI.MainController.present(LL_NavigationController(rootViewController: LL_Game_Challenges_NoLift_ViewController()), animated: true)
			}
		}
		noLiftButton.image = UIImage(systemName: "point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath")
		
		if let bestScore = UserDefaults.get(.challengesNoLiftBestScore) as? Int, bestScore > 0 {
			
			noLiftButton.subtitle = String(key: "menu.challenges.button.subtitle") + "\(bestScore)"
		}
		else {
			
			noLiftButton.subtitle = nil
		}
		
		alertController.addCancelButton()
		alertController.present()
	})
	private lazy var timeTrialGameStartButton:LL_Button = {
		
		$0.image = UIImage(systemName: "deskclock")
		$0.isSecondary = true
		return $0
		
	}(LL_Button(String(key: "menu.timeTrial.button.title")) { _ in
		
		LL_TimeTrial_Game.current.reset()
		UI.MainController.present(LL_NavigationController(rootViewController: LL_Game_TimeTrial_ViewController()), animated: true)
	})
	private lazy var bannerView = LL_Ads.shared.presentBanner(Ads.Banner.Menu, self)
	private lazy var stackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = 2*UI.Margins
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(horizontal: 3*UI.Margins)
		
		let titleLabel:LL_Label = .init(String(key: "menu.title"))
		titleLabel.font = Fonts.Content.Title.H1.withSize(Fonts.Content.Title.H1.pointSize + 20)
		titleLabel.textColor = Colors.Content.Title
		titleLabel.textAlignment = .center
		$0.addArrangedSubview(titleLabel)
		
		let baselineLabel:LL_Label = .init(String(key: "menu.subtitle"))
		baselineLabel.textAlignment = .center
		$0.addArrangedSubview(baselineLabel)
		$0.setCustomSpacing(2*$0.spacing, after: baselineLabel)
		
		let classicGameStackView:UIStackView = .init(arrangedSubviews: [classicGameRankingButton,classicGameStartButton,classicGameContinueButton])
		classicGameStackView.axis = .horizontal
		classicGameStackView.spacing = UI.Margins
		classicGameStackView.alignment = .fill
		$0.addArrangedSubview(classicGameStackView)
		
		let timeTrialGameStackView:UIStackView = .init(arrangedSubviews: [timeTrialGameRankingButton,timeTrialGameStartButton])
		timeTrialGameStackView.axis = .horizontal
		timeTrialGameStackView.spacing = UI.Margins
		timeTrialGameStackView.alignment = .fill
		$0.addArrangedSubview(timeTrialGameStackView)
		
		$0.addArrangedSubview(challengesGameStartButton)
		$0.setCustomSpacing(1.5*$0.spacing, after: challengesGameStartButton)
		
		let settingsButton:LL_Button = .init(String(key: "menu.settings.button")) { _ in
			
			let alertController:LL_Menu_Settings_Alert_ViewController = .init()
			alertController.present()
		}
		settingsButton.style = .bordered
		settingsButton.image = UIImage(systemName: "slider.vertical.3")
		$0.addArrangedSubview(settingsButton)
		
		return $0
		
	}(UIStackView())
	
	public override func loadView() {
		
		super.loadView()
		
		let menuStackView:UIStackView = .init(arrangedSubviews: [stackView])
		menuStackView.axis = .horizontal
		menuStackView.alignment = .center
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [menuStackView,bannerView])
		contentStackView.axis = .vertical
		
		view.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		classicGameContinueButton.isHidden = LL_Classic_Game.current.score == 0
		classicGameContinueButton.badge = "\(LL_Classic_Game.current.score)"
		
		if let bestScore = UserDefaults.get(.classicBestScore) as? Int, bestScore > 0 {
			
			classicGameRankingButton.isHidden = false
			classicGameStartButton.subtitle = String(key: "menu.classic.button.subtitle") + "\(bestScore)"
		}
		else {
			
			classicGameRankingButton.isHidden = true
			classicGameStartButton.subtitle = nil
		}
		
		if let bestScore = UserDefaults.get(.timeTrialBestScore) as? Int, bestScore > 0 {
			
			timeTrialGameRankingButton.isHidden = false
			timeTrialGameStartButton.subtitle = String(key: "menu.timeTrial.button.subtitle") + "\(bestScore)"
		}
		else {
			
			timeTrialGameRankingButton.isHidden = true
			timeTrialGameStartButton.subtitle = nil
		}
		
		stackView.animate()
		
		bannerView.refresh()
	}
}
