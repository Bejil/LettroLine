//
//  LL_Game_Challenges_TimeTrial_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 04/03/2025.
//

import UIKit
import GoogleMobileAds

public class LL_Game_Challenges_TimeTrial_ViewController : LL_Game_Challenges_ViewController {
	
	public override var game: LL_Game? {
		
		return LL_Challenges_TimeTrial_Game.current
	}
	private var timer: Timer?
	private var remainingTime:TimeInterval = Game.TimeTrialDuration
	private var timerButton:LL_Button = {
		
		$0.type = .tertiary
		$0.style = .solid
		$0.configuration?.contentInsets = .init(horizontal: UI.Margins, vertical: UI.Margins/2)
		$0.snp.removeConstraints()
		$0.isUserInteractionEnabled = false
		return $0
		
	}(LL_Button())
	
	deinit {
		
		pause()
	}
	
	public override func loadView() {
		
		super.loadView()
		
		title = String(key: "game.timeTrial.title")
		
		scoreStackView.insertArrangedSubview(timerButton, at: 1)
		
		updateText()
	}
	
	public override func specificTutorial() {
		
		let viewController:LL_Tutorial_ViewController = .init()
		viewController.key = .tutorialTimeTrialGame
		viewController.items = [
			
			LL_Tutorial_ViewController.Item(title: String(key: "game.timeTrial.tutorial.0.title"), subtitle: String(key: "game.timeTrial.tutorial.0.content"), button: String(key: "game.timeTrial.tutorial.0.button")),
			LL_Tutorial_ViewController.Item(sourceView: timerButton, title: String(key: "game.timeTrial.tutorial.1.title"), subtitle: String(key: "game.timeTrial.tutorial.1.content"), button: String(key: "game.timeTrial.tutorial.1.button"))
		]
		viewController.completion = { [weak self] in
			
			let viewController:LL_Tutorial_ViewController = .init()
			viewController.items = [
				
				LL_Tutorial_ViewController.Item(title: String(key: "game.timeTrial.tutorial.start.0"), timeInterval: 2.0, closure: {
					
					UIApplication.feedBack(.On)
					LL_Audio.shared.play(.button)
				}),
				LL_Tutorial_ViewController.Item(title: String(key: "game.timeTrial.tutorial.start.1"), timeInterval: 1.0, closure: {
					
					UIApplication.feedBack(.On)
					LL_Audio.shared.play(.button)
				}),
				LL_Tutorial_ViewController.Item(title: String(key: "game.timeTrial.tutorial.start.2"), timeInterval: 1.0, closure: {
					
					UIApplication.feedBack(.On)
					LL_Audio.shared.play(.button)
				}),
				LL_Tutorial_ViewController.Item(title: String(key: "game.timeTrial.tutorial.start.3"), timeInterval: 1.0, closure: {
					
					UIApplication.feedBack(.Success)
					LL_Audio.shared.play(.tap)
				}),
				LL_Tutorial_ViewController.Item(title: String(key: "game.timeTrial.tutorial.start.4"), timeInterval: 2.0)
			]
			viewController.completion = { [weak self] in
				
				self?.play()
			}
			viewController.present()
		}
		viewController.present()
	}
	
	public override func pause() {
		
		super.pause()
		
		timer?.invalidate()
		timer = nil
	}
	
	public override func play() {
		
		super.play()
	
		updateText()
		
		pause()
		
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
			
			if self?.remainingTime ?? 0 > 0 {
				
				self?.remainingTime -= 1
				self?.updateText()
			}
			else {
				
				self?.pause()
				
				let newBestScoreState = (UserDefaults.get(.challengesTimeTrialBestScore) as? Int) ?? 0 < LL_Challenges_TimeTrial_Game.current.score
				
				let viewController:LL_Tutorial_ViewController = .init()
				viewController.items = [
					
					LL_Tutorial_ViewController.Item(title: String(key: "game.timeTrial.tutorial.end.0"), timeInterval: 2.0),
					LL_Tutorial_ViewController.Item(title: String(key: "game.timeTrial.tutorial.end.1"), subtitle: [String(format: String(key: "game.timeTrial.tutorial.end.2"),LL_Challenges_TimeTrial_Game.current.score),String(key: "game.timeTrial.tutorial.end.newBestScore" + (newBestScoreState ? ".on" : ".off"))].joined(separator: "\n\n"), button: String(key: "game.timeTrial.tutorial.end.button"))
				]
				viewController.completion = { [weak self] in
					
					LL_Confettis.stop()
					
					self?.dismiss()
				}
				viewController.present()
				
				if newBestScoreState {
					
					LL_Confettis.start()
				}
			}
		})
	}
	
	private func updateText() {
		
		let minutes = Int(remainingTime) / 60
		let seconds = Int(remainingTime) % 60
		
		timerButton.title = String(format: "%02d:%02d", minutes, seconds)
		timerButton.pulse(.clear)
	}
	
	public override func newWord() {
		
		updateBestScore()
		
		solutionWord = game?.newWord(3)
	}
	
	public override func success() {
		
		super.success()
		
		remainingTime += 3
		updateText()
	}
	
	public override func updateBestScore() {
		
		super.updateBestScore()
		
		if (UserDefaults.get(.challengesTimeTrialBestScore) as? Int) ?? 0 < game?.score ?? 0 {
			
			UserDefaults.set(game?.score ?? 0, .challengesTimeTrialBestScore)
			LL_Challenges_TimeTrial_Game.current.saveBestScore()
			LL_Rewards.shared.updateLastBestScoreDate()
		}
	}
	
	public override func updateScore() {
		
		super.updateScore()
		
		isBestScore = (UserDefaults.get(.challengesTimeTrialBestScore) as? Int) ?? 0 < game?.score ?? 0
	}
}
