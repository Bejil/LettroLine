//
//  LL_Game_Story_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 24/08/2025.
//

import UIKit

public class LL_Game_Story_ViewController : LL_Game_ViewController {
	
	public override var game: LL_Game? {
		
		return LL_Game_Story.current
	}
	public var story:LL_Game_Story.Story?
	
	public override func loadView() {
		
		super.loadView()
		
		title = story?.chapters?[story?.currentChapterIndex ?? 0].title
	}
	
	public override func updateScore() {
		
		super.updateScore()
		
		scoreButton.title = "\(story?.currentWordIndex ?? 0)/\(story?.chapters?[story?.currentChapterIndex ?? 0].words?.count ?? 0)"
	}
	
	public override func newWord() {
		
		updateBestScore()
		
		if story?.currentWordIndex ?? 0 < story?.chapters?[story?.currentChapterIndex ?? 0].words?.count ?? 0 {
			
			solutionWord = story?.chapters?[story?.currentChapterIndex ?? 0].words?[story?.currentWordIndex ?? 0]
		}
	}
	
	public override func fail() {
		
		story?.reset()
		
		super.fail()
	}
	
	public override func success() {
		
		if story?.currentWordIndex ?? 0 < (story?.chapters?[story?.currentChapterIndex ?? 0].words?.count ?? 0) - 1 {
			
			story?.currentWordIndex = (story?.currentWordIndex ?? 0) + 1
			story?.save()
			
			super.success()
		}
		else {
			
			navigationItem.leftBarButtonItem?.isHidden = true
			navigationItem.rightBarButtonItem?.isHidden = true
			title = nil
			
			UIView.animation(1.0) { [weak self] in
				
				self?.contentStackView.alpha = 0.0
				
			} _: { [weak self] in
				
				let isFinished = (self?.story?.currentChapterIndex ?? 0) == (self?.story?.chapters?.count ?? 0) - 1 && (self?.story?.currentWordIndex ?? 0) == (self?.story?.chapters?[self?.story?.currentChapterIndex ?? 0].words?.count ?? 0) - 1
				
				let viewController:LL_Tutorial_ViewController = .init()
				viewController.items = [
					
					LL_Tutorial_ViewController.Item(
						title: self?.story?.chapters?[self?.story?.currentChapterIndex ?? 0].title,
						attributedSubtitle: self?.createAttributedDescription(),
						button: String(key: isFinished ? "story.finish.button" : "story.continue.button")
					)
				]
				
				viewController.completion = { [weak self] in
					
					if isFinished {
						
						self?.story?.currentChapterIndex = (self?.story?.currentChapterIndex ?? 0) + 1
						self?.story?.currentWordIndex = (self?.story?.currentWordIndex ?? 0) + 1
						
						self?.navigationController?.popViewController(animated: true)
					}
					else {
						
						self?.story?.currentChapterIndex = (self?.story?.currentChapterIndex ?? 0) + 1
						self?.story?.currentWordIndex = 0
						
						self?.newWord()
						self?.updateScore()
						
						self?.navigationItem.leftBarButtonItem?.isHidden = false
						self?.navigationItem.rightBarButtonItem?.isHidden = false
						self?.title = self?.story?.chapters?[self?.story?.currentChapterIndex ?? 0].title
						
						UIView.animation(1.0) { [weak self] in
							
							self?.contentStackView.alpha = 1.0
						}
					}
					
					self?.story?.save()
				}
				viewController.present()
			}
		}
	}
	
	private func createAttributedDescription() -> NSAttributedString? {
		
		if let chapter = story?.chapters?[story?.currentChapterIndex ?? 0], let descriptions = chapter.subtitle, let words = chapter.words {
			
			let fullText = descriptions.joined(separator: "\n\n")
			let attributedString = NSMutableAttributedString(string: fullText)
			let baseAttributes: [NSAttributedString.Key: Any] = [.font: Fonts.Content.Text.Regular]
			attributedString.addAttributes(baseAttributes, range: NSRange(location: 0, length: fullText.count))
			
			words.forEach({
				
				let wordRange = (fullText as NSString).range(of: $0, options: .caseInsensitive)
				
				if wordRange.location != NSNotFound {
					
					let highlightAttributes: [NSAttributedString.Key: Any] = [.font: Fonts.Letter.withSize(Fonts.Content.Title.H2.pointSize)]
					attributedString.addAttributes(highlightAttributes, range: wordRange)
				}
			})
			
			return attributedString
		}
		
		return nil
	}
}
