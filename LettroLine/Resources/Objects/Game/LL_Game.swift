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
	public var words: [String] = [] {
		
		didSet {
			
			save()
		}
	}
	public var bonus:Int = 0 {
		
		didSet {
			
			save()
		}
	}
	public var score:Int {
		
		return words.count
	}
	
	public func reset() {
		
		LL_Game().save()
	}
	
	private func save() {
		
		if let encoded = try? JSONEncoder().encode(self) {
			
			UserDefaults.set(encoded, .currentGame)
		}
	}
}
