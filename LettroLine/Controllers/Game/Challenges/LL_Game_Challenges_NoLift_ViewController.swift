//
//  LL_Game_Challenges_NoLift_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 13/03/2025.
//

import Foundation

public class LL_Game_Challenges_NoLift_ViewController : LL_Game_Challenges_ViewController {
	
	public override var allowFingerLift: Bool {
		
		return false
	}
	
	public override func loadView() {
		
		super.loadView()
		
		title = String(key: "game.challenges.noLift.title")
	}
	
	public override func updateBestScore() {
		
		super.updateBestScore()
		
		if (UserDefaults.get(.challengesNoLiftBestScore) as? Int) ?? 0 < game.score {
			
			UserDefaults.set(game.score, .challengesNoLiftBestScore)
		}
	}
	
	public override func updateScore() {
		
		super.updateScore()
		
		isBestScore = (UserDefaults.get(.challengesNoLiftBestScore) as? Int) ?? 0 < game.score
	}
}
