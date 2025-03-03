//
//  LL_Game_Object.swift
//  LettroLine
//
//  Created by BLIN Michael on 03/03/2025.
//

import Foundation

public class LL_Game : Codable {
	
	public static var current: LL_Game {
		
		if let savedData = UserDefaults.get(.currentGame) as? Data, let decodedGame = try? JSONDecoder().decode(LL_Game.self, from: savedData) {
			
			return decodedGame
		}
		
		return LL_Game()
	}
	public var words: [String] = []
	public var score:Int {
		
		return words.count
	}
	
	public func reset() {
		
		if let encoded = try? JSONEncoder().encode(LL_Game()) {
			
			UserDefaults.set(encoded, .currentGame)
		}
	}
	
	public func add(_ word:String?) {
		
		if let word {
			
			let game = self
			game.words.append(word)
				
			if let encoded = try? JSONEncoder().encode(game) {
				
				UserDefaults.set(encoded, .currentGame)
			}
		}
	}
}
