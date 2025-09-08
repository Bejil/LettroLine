//
//  LL_Words.swift
//  LettroLine
//
//  Created by BLIN Michael on 04/09/2025.
//

import FirebaseFirestore

public class LL_Words : Codable {
	
	public class Word : Codable {
		
		public var word: String?
	}
	
	public static let shared:LL_Words = .init()
	public var words:[Word]?
    public var minLetters: Int {
		
		return words?.compactMap({ $0.word?.count ?? 0 }).min() ?? 0
	}
	public var maxLetters: Int {
		
		return words?.compactMap({ $0.word?.count ?? 0 }).max() ?? 0
	}
	
	public func getAll(_ completion: (()->Void)?) {
		
		Firestore.firestore().collection("words").getDocuments { [weak self] snapshot, error in
			
			self?.words = snapshot?.documents.compactMap({ try?$0.data(as: LL_Words.Word.self) })
			completion?()
		}
	}
	
	public func get(_ count: Int, _ excluded: [LL_Words.Word]) -> LL_Words.Word? {
		
		return words?.filter({ word in word.word?.count == count && !excluded.contains(where: { excludedWord in excludedWord.word == word.word }) }).randomElement()
	}
}
