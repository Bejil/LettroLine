//
//  LL_Menu_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 11/02/2025.
//

import UIKit
import SnapKit

public class LL_Menu_ViewController: LL_ViewController {
	
	private lazy var classicGameContinueButton:LL_Button = {
		
		$0.style = .tinted
		return $0
		
	}(LL_Button(String(key: "menu.classic.button.continue")) { _ in
		
		let viewController:LL_Game_ViewController = .init()
		viewController.currentGameIndex = UserDefaults.get(.currentGameIndex) as? Int ?? 0
		UI.MainController.present(LL_NavigationController(rootViewController: viewController), animated: true)
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
		
		$0.addArrangedSubview(classicGameContinueButton)
		
		let classicGameStartButton:LL_Button = .init(String(key: "menu.classic.button.start")) { _ in
			
			let startClosure:(()->Void) = {
				
				UI.MainController.present(LL_NavigationController(rootViewController: LL_Game_ViewController()), animated: true)
			}
			
			if UserDefaults.get(.currentGameIndex) != nil {
				
				let alertController:LL_Alert_ViewController = .init()
				alertController.title = String(key: "Attention")
				alertController.add(String(key: "Si tu recommences une nouvelle pertie du perdra tes progrès précédents."))
				alertController.addDismissButton() { _ in
					
					UserDefaults.delete(.currentGameIndex)
					
					startClosure()
				}
				alertController.addCancelButton()
				alertController.present()
			}
			else {
				
				startClosure()
			}
		}
		$0.addArrangedSubview(classicGameStartButton)
		
		let timeTrialGameStartButton:LL_Button = .init(String(key: "menu.timeTrial.button")) { _ in
			
			
		}
		timeTrialGameStartButton.isPrimary = false
		$0.addArrangedSubview(timeTrialGameStartButton)
		
		let settingsButton:LL_Button = .init(String(key: "menu.settings.button")) { _ in
			
			let alertController:LL_Menu_Settings_Alert_ViewController = .init()
			alertController.present()
		}
		settingsButton.style = .bordered
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
		
		classicGameContinueButton.isHidden = UserDefaults.get(.currentGameIndex) == nil
		
		stackView.animate()
	}
}
