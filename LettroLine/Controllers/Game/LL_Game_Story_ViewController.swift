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
	
	public override func success() {
		
		if story?.currentWordIndex ?? 0 < (story?.chapters?[story?.currentChapterIndex ?? 0].words?.count ?? 0) - 1 {
			
			story?.currentWordIndex = (story?.currentWordIndex ?? 0) + 1
			
			super.success()
		}
		else {
			
			story?.currentChapterIndex = (story?.currentChapterIndex ?? 0) + 1
			story?.currentWordIndex = 0
			
			navigationItem.leftBarButtonItem?.isHidden = true
			navigationItem.rightBarButtonItem?.isHidden = true
			title = nil
			
			let imageView:UIImageView = .init(image: UIImage(named: story?.chapters?[story?.currentChapterIndex ?? 0].background ?? ""))
			imageView.contentMode = .scaleAspectFill
			imageView.alpha = 0.0
			view.layer.insertSublayer(imageView.layer, at: 1)
			imageView.frame = view.bounds
			
			UIView.animation(1.0) { [weak self] in
				
				self?.contentStackView.alpha = 0.0
				imageView.alpha = 1.0
				
			} _: { [weak self] in
				
				let viewController:LL_Tutorial_ViewController = .init()
				viewController.items = [
					
					LL_Tutorial_ViewController.Item(
						title: self?.story?.chapters?[self?.story?.currentChapterIndex ?? 0].title,
						attributedSubtitle: self?.createAttributedDescription(),
						button: String(key: "story.continue.button")
					)
				]
				viewController.completion = { [weak self] in
					
					self?.newWord()
					self?.updateScore()
					
					self?.navigationItem.leftBarButtonItem?.isHidden = false
					self?.navigationItem.rightBarButtonItem?.isHidden = false
					self?.title = self?.story?.chapters?[self?.story?.currentChapterIndex ?? 0].title
					
					UIView.animation(1.0) { [weak self] in
						
						self?.contentStackView.alpha = 1.0
						imageView.alpha = 0.0
						
					} _: {
						
						imageView.layer.removeFromSuperlayer()
					}
				}
				viewController.present()
			}
		}
		
		story?.save()
	}
	
	private func createAttributedDescription() -> NSAttributedString? {
		guard let chapter = story?.chapters?[story?.currentChapterIndex ?? 0],
			  let descriptions = chapter.subtitle,
			  let words = chapter.words else { return nil }
		
		let fullText = descriptions.joined(separator: "\n\n")
		let attributedString = NSMutableAttributedString(string: fullText)
		
		// Style de base
		let baseAttributes: [NSAttributedString.Key: Any] = [
			.font: Fonts.Content.Text.Regular
		]
		attributedString.addAttributes(baseAttributes, range: NSRange(location: 0, length: fullText.count))
		
		// Mettre en avant les mots trouvés
		for word in words {
			let wordRange = (fullText as NSString).range(of: word, options: .caseInsensitive)
			if wordRange.location != NSNotFound {
				let highlightAttributes: [NSAttributedString.Key: Any] = [
					.font: Fonts.Letter.withSize(Fonts.Content.Title.H2.pointSize)
				]
				attributedString.addAttributes(highlightAttributes, range: wordRange)
			}
		}
		
		return attributedString
	}
}
