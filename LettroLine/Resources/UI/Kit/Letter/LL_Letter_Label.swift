//
//  LL_Letter_Label.swift
//  LettroLine
//
//  Created by BLIN Michael on 14/02/2025.
//

import UIKit

public class LL_Letter_Label : LL_Label {
	
	public var isSelected: Bool? {
		
		didSet {
			
			backgroundColor = isSelected ?? false ? Colors.Letter.Selected : Colors.Letter.Unselected
			
			if isSelected ?? false {
				
				pulse(.white)
			}
		}
	}
	public var isFirst: Bool = false {
		
		didSet {
			
			updateLabelText(text)
		}
	}
	private var animationTimer: Timer?
	public override var text: String? {
		
		get {
			
			return super.text
		}
		
		set {
			
			animationTimer?.invalidate()
			
			if let finalText = newValue?.uppercased() {
				
				if !finalText.isEmpty {
					
					let animationDuration: TimeInterval = 0.3
					let steps = 10
					let interval = animationDuration / Double(steps)
					var currentStep = 0
					
					animationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
						
						UIApplication.feedBack(.On)
						
						currentStep += 1
						
						if currentStep >= steps {
							
							self?.updateLabelText(finalText)
							self?.pulse(.white)
							
							timer.invalidate()
						}
						else {
							
							var animatedText = ""
							
							finalText.forEach({ _ in
								
								let randomLetter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement()!
								animatedText.append(String(randomLetter))
							})
							
							self?.updateLabelText(animatedText)
						}
					}
				}
				else {
					
					isFirst = false
					updateLabelText(finalText)
				}
			}
		}
	}
	
	private func updateLabelText(_ newText: String?) {
		
		super.text = newText
		
		backgroundColor = isFirst ? Colors.Tertiary : Colors.Letter.Unselected
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		textColor = .white
		font = Fonts.Content.Title.H1
		adjustsFontSizeToFitWidth = true
		minimumScaleFactor = 0.5
		textAlignment = .center
		clipsToBounds = true
		contentInsets = .init(UI.Margins)
		
		defer {
			
			isSelected = false
		}
	}
	
	@MainActor required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		layer.cornerRadius = frame.size.width/3
	}
}
