//
//  LL_Menu_Settings_Alert_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 21/02/2025.
//

import UIKit

public class LL_Menu_Settings_Alert_ViewController : LL_Alert_ViewController {
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = String(key: "menu.settings.alert.title")
		
		func setupToggleButton(for key: UserDefaults.Keys, title: String?, subtitleOn: String, subtitleOff: String, imageOn: String, imageOff: String, _ completion: (() -> Void)? = nil) -> LL_Button {
			
			let button = LL_Button()
			
			if let title {
				
				button.title = String(key: title)
			}
			
			func update() {
				
				let state = (UserDefaults.get(key) as? Bool) ?? true
				
				if title != nil {
					
					button.subtitle = String(key: state ? subtitleOn : subtitleOff)
				}
				else {
					
					button.title = String(key: state ? subtitleOn : subtitleOff)
				}
				
				button.image = UIImage(systemName: state ? imageOn : imageOff)
				button.style = state ? .solid : .tinted
			}
			
			button.action = { _ in
				
				let state = (UserDefaults.get(key) as? Bool) ?? true
				UserDefaults.set(!state, key)
				update()
				
				completion?()
			}
			
			update()
			
			return button
		}
		
		let audioTitleLabel = add(String(key: "menu.settings.alert.audio.title"))
		audioTitleLabel.font = Fonts.Content.Title.H4
		audioTitleLabel.textColor = .white
		
		let musicButton = setupToggleButton(for: .musicEnabled,
											title: "menu.settings.alert.audio.music.button.title",
											subtitleOn: "menu.settings.alert.audio.music.button.subtitle.on",
											subtitleOff: "menu.settings.alert.audio.music.button.subtitle.off",
											imageOn: "speaker.wave.2.fill",
											imageOff: "speaker.slash.fill", {
			
			LL_Audio.shared.isMusicEnabled ? LL_Audio.shared.playMusic() : LL_Audio.shared.stopMusic()
		})
		
		let soundsButton = setupToggleButton(for: .soundsEnabled,
											 title: "menu.settings.alert.audio.sounds.button.title",
											 subtitleOn: "menu.settings.alert.audio.sounds.button.subtitle.on",
											 subtitleOff: "menu.settings.alert.audio.sounds.button.subtitle.off",
											 imageOn: "speaker.wave.2.fill",
											 imageOff: "speaker.slash.fill")
		
		let audioStackView:UIStackView = .init(arrangedSubviews: [musicButton,soundsButton])
		audioStackView.axis = .horizontal
		audioStackView.alignment = .center
		audioStackView.spacing = UI.Margins
		add(audioStackView)
		
		let rulesTitleLabel = add(String(key: "menu.settings.alert.rules.title"))
		rulesTitleLabel.font = Fonts.Content.Title.H4
		rulesTitleLabel.textColor = .white
		
		let showFirstLetterLabel:LL_Label = .init(String(key: "menu.settings.alert.rules.showFirstLetter.content"))
		showFirstLetterLabel.textColor = .white
		
		let showFirstLetterButton = setupToggleButton(for: .showFirstLetter,
													  title: nil,
													  subtitleOn: "menu.settings.alert.rules.showFirstLetter.button.title.on",
													  subtitleOff: "menu.settings.alert.rules.showFirstLetter.button.title.off",
													  imageOn: "a.square.fill",
													  imageOff: "a.square")
		
		let showFirstLetterStackView:UIStackView = .init(arrangedSubviews: [showFirstLetterLabel,showFirstLetterButton])
		showFirstLetterStackView.axis = .horizontal
		showFirstLetterStackView.alignment = .center
		showFirstLetterStackView.spacing = UI.Margins
		add(showFirstLetterStackView)
		
		let allowFingerLiftLabel:LL_Label = .init(String(key: "menu.settings.alert.rules.allowFingerLift.content"))
		allowFingerLiftLabel.textColor = .white
		
		let allowFingerLiftButton = setupToggleButton(for: .allowFingerLift,
													  title: nil,
													  subtitleOn: "menu.settings.alert.rules.allowFingerLift.button.title.on",
													  subtitleOff: "menu.settings.alert.rules.allowFingerLift.button.title.off",
													  imageOn: "hand.tap.fill",
													  imageOff: "hand.tap")
		
		let allowFingerLiftStackView:UIStackView = .init(arrangedSubviews: [allowFingerLiftLabel,allowFingerLiftButton])
		allowFingerLiftStackView.axis = .horizontal
		allowFingerLiftStackView.alignment = .center
		allowFingerLiftStackView.spacing = UI.Margins
		add(allowFingerLiftStackView)
		
		contentStackView.arrangedSubviews.forEach({
			
			contentStackView.setCustomSpacing(UI.Margins*2, after: $0)
		})
		
		contentStackView.setCustomSpacing(UI.Margins, after: showFirstLetterStackView)
		
		addDismissButton()
	}
	
	@MainActor required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func present(as style: LL_Alert_ViewController.Style = .Alert, withAnimation animated: Bool = true, _ completion: (() -> Void)? = nil) {
		
		super.present(as: .Sheet)
	}
}
