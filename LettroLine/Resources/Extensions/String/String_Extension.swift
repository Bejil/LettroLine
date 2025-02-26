//
//  String_Extension.swift
//  LettroLine
//
//  Created by BLIN Michael on 12/02/2025.
//

import Foundation

extension String {
	
	init(key:String) {
		
		self = NSLocalizedString(key, comment:"localizable string")
	}
	
	static public func randomWord(withLetters: Int) -> String? {
		
		if let url = Bundle.main.url(forResource: "LL_Words", withExtension: "json"), let data = try? Data(contentsOf: url), let wordsDict = try? JSONDecoder().decode([String: [String]].self, from: data) {
			
			let key = String(withLetters)
			
			if let words = wordsDict[key] {
				
				return words.randomElement()?.folding(options: .diacriticInsensitive, locale: .current)
			}
		}
		
		return nil
	}
}
