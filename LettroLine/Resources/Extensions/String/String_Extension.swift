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
	
	private static var wordsDictionary: [String: [String]]? = {
		
		if let url = Bundle.main.url(forResource: "LL_Words", withExtension: "json"), let data = try? Data(contentsOf: url), let dict = try? JSONDecoder().decode([String: [String]].self, from: data) {
			
			return dict
		}
		
		return nil
	}()
	
	static public func randomWord(withLetters: Int, excludingWords: [String] = []) -> String? {
		
		if let wordsDict = wordsDictionary, let words = wordsDict[String(withLetters)] {
			
			let availableWords = words.filter { word in
				
				!excludingWords.contains { existingWord in
					
					existingWord.folding(options: .diacriticInsensitive, locale: .current).caseInsensitiveCompare(word) == .orderedSame
				}
			}
			
			if !availableWords.isEmpty {
				
				return availableWords.randomElement()?.folding(options: .diacriticInsensitive, locale: .current)
			}
		}
		
		return nil
	}
	
	static public var minLetters: Int {
		
		return wordsDictionary?.keys.compactMap { Int($0) }.min() ?? 0
	}
	
	static public var maxLetters: Int {
		
		return wordsDictionary?.keys.compactMap { Int($0) }.max() ?? 0
	}
}
