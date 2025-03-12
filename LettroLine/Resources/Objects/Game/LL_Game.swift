//
//  LL_Game_Object.swift
//  LettroLine
//
//  Created by BLIN Michael on 03/03/2025.
//

import Foundation
import FirebaseFirestore

public class LL_Game: Codable {
	
	public var words: [String] = [] {
		
		didSet {
			
			save()
		}
	}
	
	public var bonus: Int = 0 {
		
		didSet {
			
			save()
		}
	}
	
	public var score: Int {
		
		return words.count
	}
	
	public class var currentUserDefaultsKey: UserDefaults.Keys? {
		
		return nil
	}
	
	public static var current: Self {
		
		if let currentUserDefaultsKey, let savedData = UserDefaults.get(currentUserDefaultsKey) as? Data, let decodedGame = try? JSONDecoder().decode(Self.self, from: savedData) {
			
			return decodedGame
		}
		
		return Self.init()
	}
	
	public required init() {}
	
	public func reset() {
		
		self.words = []
		self.bonus = 0
		save()
	}
	
	public func save() {
		
		if let currentUserDefaultsKey = type(of: self).currentUserDefaultsKey, let encoded = try? JSONEncoder().encode(self) {
			
			UserDefaults.set(encoded, currentUserDefaultsKey)
		}
	}
	
	public func newWord(_ letters:Int = Int.random(in: 3...8)) -> String? {
		
		return String.randomWord(withLetters: letters, excludingWords: words)
	}
}
