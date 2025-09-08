//
//  LL_Game_Classic_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 04/03/2025.
//

import Foundation

public class LL_Game_Classic_ViewController : LL_Game_ViewController {
	
	public override var game: LL_Game? {
		
		return LL_Game_Classic.current
	}
	
	public override func loadView() {
		
		super.loadView()
		
		title = String(key: "game.classic.title")
	}
	
	public override func updateBestScore() {
		
		super.updateBestScore()
		
		if (UserDefaults.get(.classicBestScore) as? Int) ?? 0 < game?.score ?? 0 {
			
			UserDefaults.set(game?.score ?? 0, .classicBestScore)
			LL_Game_Classic.current.saveBestScore()
			LL_Rewards.shared.updateLastBestScoreDate()
		}
	}
	
	public override func updateScore() {
		
		super.updateScore()
		
		isBestScore = (UserDefaults.get(.classicBestScore) as? Int) ?? 0 < game?.score ?? 0
	}
}
