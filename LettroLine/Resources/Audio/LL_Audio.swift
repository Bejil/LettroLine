//
//  LL_Audio.swift
//  LetttroLine
//
//  Created by BLIN Michael on 09/10/2025.
//

import AVFoundation

public class LL_Audio : NSObject {
	
	public enum Sounds : String {
		
		case Success = "Success"
		case Error = "Error"
		case Button = "Button"
		case Tap = "Tap"
		case Bonus = "Bonus"
	}
	
	public static var shared:LL_Audio = .init()
	private var soundPlayer:AVAudioPlayer?
	private var musicPlayer:AVAudioPlayer?
	public var isSoundsEnabled:Bool {
		
		return (UserDefaults.get(.soundsEnabled) as? Bool) ?? true
	}
	public var isMusicEnabled:Bool {
		
		return (UserDefaults.get(.musicEnabled) as? Bool) ?? true
	}
	
	public func playSound(_ sound:Sounds) {
		
		stopSound()
		
		if isSoundsEnabled, let path = Bundle.main.path(forResource: sound.rawValue, ofType: "mp3") {
			
			let url = URL(fileURLWithPath: path)
			
			try?AVAudioSession.sharedInstance().setCategory(.playback)
			try?AVAudioSession.sharedInstance().setActive(true)
			
			try?soundPlayer = AVAudioPlayer(contentsOf: url)
			soundPlayer?.prepareToPlay()
			soundPlayer?.play()
		}
	}
	
	private func stopSound() {
		
		soundPlayer?.stop()
		soundPlayer = nil
	}
	
	public func playMusic() {
		
		stopMusic()
		
		if isMusicEnabled, let index = (0...2).randomElement(), let path = Bundle.main.path(forResource: "music_\(index)", ofType: "mp3") {
			
			let url = URL(fileURLWithPath: path)
			
			try?AVAudioSession.sharedInstance().setCategory(.playback)
			try?AVAudioSession.sharedInstance().setActive(true)
			
			try?musicPlayer = AVAudioPlayer(contentsOf: url)
			musicPlayer?.delegate = self
			musicPlayer?.prepareToPlay()
			musicPlayer?.play()
		}
	}
	
	public func stopMusic() {
		
		musicPlayer?.stop()
		musicPlayer = nil
	}
}

extension LL_Audio : AVAudioPlayerDelegate {
	
	public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		
		playMusic()
	}
}
