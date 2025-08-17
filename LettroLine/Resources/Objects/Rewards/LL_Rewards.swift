//
//  LL_Rewards.swift
//  LettroLine
//
//  Created by BLIN Michael on 14/08/2025.
//

import Foundation

public class LL_Rewards : Codable {
	
	static let shared:LL_Rewards = .init()
	public var lastConnexionDateStatus:Bool {
		
		return statusForKey(.lastConnexionDate)
	}
	public var lastGameDateStatus:Bool {
		
		return statusForKey(.lastGameDate)
	}
	public var lastBestScoreDateStatus:Bool {
		
		return statusForKey(.lastBestScoreDate)
	}
	public var steps:Int {
		
		var steps:Int = 0
		
		if statusForKey(.lastConnexionDate) {
			
			steps += 1
		}
		
		if statusForKey(.lastGameDate) {
			
			steps += 1
		}
		
		if statusForKey(.lastBestScoreDate) {
			
			steps += 1
		}
		
		return steps
	}
	public var canGetReward:Bool {
		
		return steps >= 3 && !alreadyGetReward
	}
	public var alreadyGetReward:Bool {
		
		return statusForKey(.lastRewardsDate)
	}
	
	private func updateKey(_ key:UserDefaults.Keys) {
		
		UserDefaults.set(Date(), key)
		
		if statusForKey(key) {
			
			NotificationCenter.post(.updateRewards)
		}
	}
	
	public func updateLastConnexionDate() {
		
		updateKey(.lastConnexionDate)
	}
	
	public func updateLastGameDate() {
		
		updateKey(.lastGameDate)
	}
	
	public func updateLastBestScoreDate() {
		
		updateKey(.lastBestScoreDate)
	}
	
	private func statusForKey(_ key:UserDefaults.Keys) -> Bool {
		
		if let date = UserDefaults.get(key) as? Date, Calendar.current.isDateInToday(date) {
			
			return true
		}
		
		return false
	}
	
	public func get() {
		
		var bonus = UserDefaults.get(.userBonus) as? Int ?? 0
		bonus += 3
		UserDefaults.set(bonus, .userBonus)
		
		NotificationCenter.post(.updateUserBonus)
		
		UserDefaults.set(Date(), .lastRewardsDate)
	}
}
