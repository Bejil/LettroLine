//
//  LL_Settings_Button.swift
//  LettroLine
//
//  Created by BLIN Michael on 22/08/2025.
//

import UIKit

public class LL_Settings_Button : LL_Button {
	
	private var settingsMenu:UIMenu {
		
		return .init(children: [
			
			UIAction(title: String(key: "settings.sounds"), subtitle: String(key: "settings.sounds." + (LL_Audio.shared.isSoundsEnabled ? "on" : "off")), image: UIImage(systemName: LL_Audio.shared.isSoundsEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"), handler: { [weak self] _ in
				
				LL_Audio.shared.playSound(.Button)
				
				UserDefaults.set(!LL_Audio.shared.isSoundsEnabled, .soundsEnabled)
				
				self?.menu = self?.settingsMenu
			}),
			UIAction(title: String(key: "settings.music"), subtitle: String(key: "settings.music." + (LL_Audio.shared.isMusicEnabled ? "on" : "off")), image: UIImage(systemName: LL_Audio.shared.isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"), handler: { [weak self] _ in
				
				LL_Audio.shared.playSound(.Button)
				
				UserDefaults.set(!LL_Audio.shared.isMusicEnabled, .musicEnabled)
				
				LL_Audio.shared.isMusicEnabled ? LL_Audio.shared.playMusic() : LL_Audio.shared.stopMusic()
				
				self?.menu = self?.settingsMenu
			}),
			UIAction(title: String(key: "settings.vibrations"), subtitle: String(key: "settings.vibrations." + (UIApplication.isVibrationsEnabled ? "on" : "off")), image: UIImage(systemName: UIApplication.isVibrationsEnabled ? "water.waves" : "water.waves.slash"), handler: { [weak self] _ in
				
				UserDefaults.set(!UIApplication.isVibrationsEnabled, .vibrationsEnabled)
				
				self?.menu = self?.settingsMenu
			})
		])
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		title = String(key: "settings.button")
		image = UIImage(systemName: "slider.vertical.3")?.applyingSymbolConfiguration(.init(scale: .medium))
		menu = settingsMenu
		showsMenuAsPrimaryAction = true
		type = .navigation
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
