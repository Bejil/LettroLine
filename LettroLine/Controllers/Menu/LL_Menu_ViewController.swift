//
//  LL_Menu_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 11/02/2025.
//

import UIKit
import SnapKit

public class LL_Menu_ViewController: LL_ViewController {
	
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
	private lazy var stackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = 2*UI.Margins
		
		$0.addArrangedSubview(.init())
		
		let titleLabel:LL_Label = .init(String(key: "menu.title"))
		titleLabel.font = Fonts.Content.Title.H1.withSize(Fonts.Content.Title.H1.pointSize + 20)
		titleLabel.textColor = Colors.Content.Title
		titleLabel.textAlignment = .center
		$0.addArrangedSubview(titleLabel)
		
		let baselineLabel:LL_Label = .init(String(key: "menu.subtitle"))
		baselineLabel.textAlignment = .center
		$0.addArrangedSubview(baselineLabel)
		$0.setCustomSpacing(2*$0.spacing, after: baselineLabel)
		
		let classicGameStartButton:LL_Button = .init(String(key: "menu.classic.button.start")) { _ in
			
			let startClosure:(()->Void) = {
				
				UI.MainController.present(LL_NavigationController(rootViewController: LL_Game_Classic_ViewController()), animated: true)
			}
			
			if LL_Game.current.score != 0 {
				
				let alertController:LL_Alert_ViewController = .init()
				alertController.title = String(key: "menu.classic.new.alert.title")
				alertController.add(String(key: "menu.classic.new.alert.content"))
				alertController.addDismissButton() { _ in
					
					LL_Game.current.reset()
					
					startClosure()
				}
				alertController.addCancelButton()
				alertController.present()
			}
			else {
				
				startClosure()
			}
		}
		classicGameStartButton.image = UIImage(systemName: "hand.point.up.braille.fill")
		
		let classicGameStackView:UIStackView = .init(arrangedSubviews: [classicGameStartButton,classicGameContinueButton])
		classicGameStackView.axis = .horizontal
		classicGameStackView.spacing = UI.Margins
		classicGameStackView.alignment = .fill
		$0.addArrangedSubview(classicGameStackView)
		
		let timeTrialGameStartButton:LL_Button = .init(String(key: "menu.timeTrial.button")) { _ in
			
			UI.MainController.present(LL_NavigationController(rootViewController: LL_Game_TimeTrial_ViewController()), animated: true)
		}
		timeTrialGameStartButton.isSecondary = true
		$0.addArrangedSubview(timeTrialGameStartButton)
		timeTrialGameStartButton.image = UIImage(systemName: "deskclock.fill")
		
		let challengesGameStartButton:LL_Button = .init(String(key: "menu.challenges.button")) { _ in
			
			UI.MainController.present(LL_NavigationController(rootViewController: LL_Game_Challenges_ViewController()), animated: true)
		}
		challengesGameStartButton.isTertiary = true
		challengesGameStartButton.image = UIImage(systemName: "figure.strengthtraining.traditional")
		$0.addArrangedSubview(challengesGameStartButton)
		$0.setCustomSpacing(1.5*$0.spacing, after: challengesGameStartButton)
		
		let settingsButton:LL_Button = .init(String(key: "menu.settings.button")) { _ in
			
			let alertController:LL_Menu_Settings_Alert_ViewController = .init()
			alertController.present()
		}
		settingsButton.style = .bordered
		settingsButton.image = UIImage(systemName: "slider.vertical.3")
		$0.addArrangedSubview(settingsButton)
		
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
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(5*UI.Margins)
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		classicGameContinueButton.isHidden = LL_Game.current.score == 0
		classicGameContinueButton.badge = "\(LL_Game.current.score)"
		
		stackView.animate()
	}
}
