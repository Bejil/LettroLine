//
//  LL_Audio.swift
//  LettroLine
//
//  Created by BLIN Michael on 23/06/2022.
//

import Foundation
import SwiftySound

public class LL_Audio : NSObject {
	
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
	
	public func playSuccess() {
		
		if isSoundsEnabled {
			
			Sound.play(file: "Success.mp3", numberOfLoops: 0)
		}
	}
	
	public func playError() {
		
		if isSoundsEnabled {
			
			Sound.play(file: "Error.mp3", numberOfLoops: 0)
		}
	}
	
	public func playButton() {
		
		if isSoundsEnabled {
			
			Sound.play(file: "Button.mp3", numberOfLoops: 0)
		}
	}
	
	public func playTap() {
		
		if isSoundsEnabled {
			
			Sound.play(file: "Tap.mp3", numberOfLoops: 0)
		}
	}
}
