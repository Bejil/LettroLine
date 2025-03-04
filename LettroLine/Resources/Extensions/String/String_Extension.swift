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
	
	static public func randomWord(withLetters: Int, excludingWords: [String] = []) -> String? {
		
		guard let url = Bundle.main.url(forResource: "LL_Words", withExtension: "json"),
			  let data = try? Data(contentsOf: url),
			  let wordsDict = try? JSONDecoder().decode([String: [String]].self, from: data)
		else { return nil }
		
		let key = String(withLetters)
		
		guard let words = wordsDict[key] else { return nil }
		
			// Filtrer pour exclure les mots déjà utilisés dans LL_Game.current.words
		let availableWords = words.filter { word in
			!excludingWords.contains { existingWord in
					// Comparaison insensible aux accents et à la casse
				existingWord.folding(options: .diacriticInsensitive, locale: .current)
					.caseInsensitiveCompare(word) == .orderedSame
			}
		}
		
		guard !availableWords.isEmpty else { return nil }
		
			// Retourne un mot aléatoire parmi ceux restants
		return availableWords.randomElement()?.folding(options: .diacriticInsensitive, locale: .current)
	}
}
