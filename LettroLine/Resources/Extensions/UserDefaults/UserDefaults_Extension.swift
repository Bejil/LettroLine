//
//  UserDefaults_Extension.swift
//  ListYa
//
//  Created by BLIN Michael on 21/06/2022.
//

import Foundation

extension UserDefaults {

	public enum Keys : String, CaseIterable {
		
		case userId = "userId"
		case userName = "userName"
		case userBonus = "userBonus"
		
		case lastConnexionDate = "lastConnexionDate"
		case lastGameDate = "lastGameDate"
		case lastBestScoreDate = "lastBestScoreDate"
		case lastRewardsDate = "lastRewardsDate"
		
		case shouldDisplayAds = "shouldDisplayAds"
		case inAppPurchaseAlertCapping = "inAppPurchaseAlertCapping"
		case onboarding = "onboarding"
		case soundsEnabled = "soundsEnabled"
		case musicEnabled = "musicEnabled"
		case vibrationsEnabled = "vibrationsEnabled"
		
		case currentClassicGame = "currentClassicGame"
		case currentStoryGame = "currentStoryGame"
		case currentChallengesNoLift = "currentChallengesNoLift"
		case currentChallengesMoveLimit = "currentChallengesMoveLimit"
		case currentChallengesTimeTrialGame = "currentChallengesTimeTrialGame"
		
		case classicBestScore = "classicBestScore"
		case challengesMoveLimitBestScore = "challengesMoveLimitBestScore"
		case challengesNoLiftBestScore = "challengesNoLiftBestScore"
		case challengesTimeTrialBestScore = "challengesTimeTrialBestScore"
		
		case tutorialClassicGame = "tutorialClassicGame"
		case tutorialTimeTrialGame = "tutorialTimeTrialGame"
		case notifications = "notifications"
	}
	
	public static func set(_ value:Any?, _ key:UserDefaults.Keys) {
		
		let standardUserDefaults = UserDefaults.standard
		standardUserDefaults.set(value, forKey: key.rawValue)
		standardUserDefaults.synchronize()
	}
	
	public static func get(_ key:UserDefaults.Keys) -> Any? {
		
		let standardUserDefaults = UserDefaults.standard
		return standardUserDefaults.value(forKey: key.rawValue)
	}
	
	public static func delete(_ key:UserDefaults.Keys) {
		
		let standardUserDefaults = UserDefaults.standard
		standardUserDefaults.removeObject(forKey: key.rawValue)
		standardUserDefaults.synchronize()
	}
	
	public static func reset() {
		
		Keys.allCases.forEach({ delete($0) })
	}
}
