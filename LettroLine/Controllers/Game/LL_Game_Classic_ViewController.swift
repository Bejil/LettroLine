//
//  LL_Game_Classic_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 04/03/2025.
//

import Foundation

public class LL_Game_Classic_ViewController : LL_Game_ViewController {
	
	public override var game: LL_Game {
		
		return LL_Classic_Game.current
	}
	
	public override func loadView() {
		
		super.loadView()
		
		title = String(key: "game.classic.title")
	}
	
	public override func updateBestScore() {
		
		super.updateBestScore()
		
		if (UserDefaults.get(.classicBestScore) as? Int) ?? 0 < game.score {
			
			UserDefaults.set(game.score, .classicBestScore)
			LL_Classic_Game.current.saveBestScore()
			LL_Rewards.shared.updateLastBestScoreDate()
		}
	}
	
	public override func updateScore() {
		
		super.updateScore()
		
		isBestScore = (UserDefaults.get(.classicBestScore) as? Int) ?? 0 < game.score
	}
}
