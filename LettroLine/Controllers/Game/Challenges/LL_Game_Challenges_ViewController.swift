//
//  LL_Game_Challenges_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 04/03/2025.
//

import Foundation

public class LL_Game_Challenges_ViewController : LL_Game_ViewController {
	
	public override func close() {
		
		pause()
		
		let alertController:LL_Alert_ViewController = .init()
		alertController.title = String(key: "game.challenges.close.alert.title")
		alertController.add(String(key: "game.challenges.close.alert.content"))
		alertController.addDismissButton() { _ in
			
			super.close()
		}
		alertController.addCancelButton()
		alertController.dismissHandler = { [weak self] in
			
			self?.play()
		}
		alertController.present()
	}
}
