//
//  LL_Letter_Label.swift
//  LettroLine
//
//  Created by BLIN Michael on 14/02/2025.
//

import UIKit

public class LL_Letter_Label : LL_Label {
	
	public var isBonus:Bool = false {
	
		didSet {
			
			bonusImageView.isHidden = !isBonus
		}
	}
	public var isSelected: Bool? {
		
		didSet {
			
			updateColor()
			
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
			animationTimer = nil
			
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
	private lazy var bonusImageView: UIImageView = {
		
		$0.tintColor = Colors.Button.Delete.Background
		$0.contentMode = .scaleAspectFit
		$0.isHidden = true
		return $0
		
	}(UIImageView(image: UIImage(systemName: "star.fill")))
	
	private func updateLabelText(_ newText: String?) {
		
		super.text = newText
		
		updateColor()
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
		
		addSubview(bonusImageView)
		bonusImageView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
		
		defer {
			
			isSelected = false
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		layer.cornerRadius = frame.size.width/3
	}
	
	private func updateColor()	{
		
		backgroundColor = isSelected ?? false ? Colors.Letter.Selected :  isFirst ? Colors.Tertiary : Colors.Letter.Unselected
	}
}
