//
//  LL_Challenges_NoLift_Game.swift
//  LettroLine
//
//  Created by BLIN Michael on 10/03/2025.
//

import Foundation
import FirebaseFirestore

public class LL_Challenges_NoLift_Game: LL_Game {
	
	public struct FirebaseObject : Codable {
		
		@DocumentID public var id: String?
		public var uuid:String? = UserDefaults.get(.userId) as? String
		public var name:String? = UserDefaults.get(.userName) as? String
		public var score:Int?
	}
	
	public override class var currentUserDefaultsKey: UserDefaults.Keys? {
		
		return .currentChallengesNoLift
	}
	
	public func saveBestScore() {
		
		var object:FirebaseObject = .init()
		object.score = score
		
		let firestore = Firestore.firestore()
		let collection = firestore.collection("noLiftScores")
		
		collection.whereField("uuid", isEqualTo: object.uuid ?? "").getDocuments { snapshot, error in
			
			if let docID = snapshot?.documents.first?.documentID {
				
				let docRef = collection.document(docID)
				
				do {
					
					try docRef.setData(from: object)
				}
				catch {
					
					print(error)
				}
			}
			else {
				
				do {
					
					_ = try collection.addDocument(from: object)
				}
				catch {
					
					print(error)
				}
			}
		}
	}
	
	public static func getAll(_ completion: (([LL_Game.FirebaseObject]?) -> Void)?) {
		
		let collectionRef = Firestore.firestore().collection("noLiftScores")
		
		collectionRef.order(by: "score", descending: true).getDocuments { (snapshot, error) in
			
			let objects = snapshot?.documents.compactMap({ document in
				
				return try? document.data(as: LL_Game.FirebaseObject.self)
				
			}).sorted(by: {
				
				$0.score ?? 0 > $1.score ?? 0
			})
			
			completion?(objects)
		}
	}
}
