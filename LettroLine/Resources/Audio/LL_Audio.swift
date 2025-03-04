//
//  LL_Audio.swift
//  LettroLine
//
//  Created by BLIN Michael on 23/06/2022.
//

import Foundation
import SwiftySound

public class LL_Audio : NSObject {
	
	public enum Keys : String, CaseIterable {
		
		case success = "Success"
		case error = "Error"
		case button = "Button"
		case tap = "Tap"
		case bonus = "Bonus"
	}
	
	private var currentMusic:Sound?
	public static let shared:LL_Audio = .init()
	
	public override init() {
		
		super.init()
		
		Sound.category = .playback
	}
	
	public var isSoundsEnabled:Bool {
		
		return (UserDefaults.get(.soundsEnabled) as? Bool) ?? true
	}
	
	public var isMusicEnabled:Bool {
		
		return (UserDefaults.get(.musicEnabled) as? Bool) ?? true
	}
	
	public func stopMusic() {
		
		currentMusic?.stop()
	}
	
	public func playMusic() {
		
		if isMusicEnabled {
			
			if let url = Bundle.main.url(forResource: "\(Int.random(in: 0...2))", withExtension: "mp3") {
				
				currentMusic = Sound(url: url)
				currentMusic?.play(numberOfLoops: -1)
			}
		}
	}
	
	public func play(_ sound:Keys) {
		
		if isSoundsEnabled {
			
			Sound.play(file: "\(sound.rawValue).mp3")
		}
	}
}
