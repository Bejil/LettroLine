//
//  LL_Game_Story.swift
//  LettroLine
//
//  Created by BLIN Michael on 25/08/2025.
//

import Foundation

public class LL_Game_Story : LL_Game {

	public class Story : Codable {
		
		public class Chapter : Codable {
			
			public var title: String?
			public var words: [String]?
			public var subtitle: [String]?
			public var background: String?
		}
		
		public var id: String?
		public var title: String?
		public var subtitle: String?
		public var genre: String?
		public var chapters:[Chapter]?
		public var currentChapterIndex:Int?
		public var currentWordIndex:Int?
		
		public func save() {
			
			if let id, let encoded = try? JSONEncoder().encode(self) {
				
				let standardUserDefaults = UserDefaults.standard
				standardUserDefaults.set(encoded, forKey: id)
				standardUserDefaults.synchronize()
			}
		}
		
		public var current:Self? {
			
			if let id, let savedData = UserDefaults.standard.value(forKey: id) as? Data, let decodedGame = try? JSONDecoder().decode(Self.self, from: savedData) {
				
				return decodedGame
			}
			
			return nil
		}
	}
	
	public static var stories:[Story]? {
		
		if let url = Bundle.main.url(forResource: "LL_Stories", withExtension: "json"),
		   let data = try? Data(contentsOf: url),
		   let storyData = try? JSONDecoder().decode([Story].self, from: data) {
			
			return storyData
		}
		
		return nil
	}
}
