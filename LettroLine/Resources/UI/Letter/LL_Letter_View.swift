//
//  LL_Letter_View.swift
//  LettroLine
//
//  Created by BLIN Michael on 14/02/2025.
//

import UIKit

public class LL_Letter_View : UIView {
	
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
	private lazy var label:LL_Label = {
		
		$0.textColor = .white
		$0.font = Fonts.Letter
		$0.adjustsFontSizeToFitWidth = true
		$0.minimumScaleFactor = 0.4
		$0.textAlignment = .center
		$0.layer.shadowOffset = .zero
		$0.layer.shadowRadius = 1.5*UI.Margins
		$0.layer.shadowOpacity = 1.4
		$0.layer.masksToBounds = false
		$0.layer.shadowColor = UIColor.black.cgColor
		return $0
		
	}(LL_Label())
	private var animationTimer: Timer?
	public var letter: String? {
		
		didSet {
			
			animationTimer?.invalidate()
			animationTimer = nil
			
			if let finalText = letter {
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
						} else {
							var animatedText = ""
							finalText.forEach({ _ in
								let randomLetter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement()!
								animatedText.append(String(randomLetter))
							})
							self?.updateLabelText(animatedText)
						}
					}
				} else {
					
					updateLabelText(finalText)
				}
			}
		}
	}
	private lazy var bonusImageView: UIImageView = {
		
		$0.tintColor = .white
		$0.contentMode = .scaleAspectFit
		$0.isHidden = true
		return $0
		
	}(UIImageView(image: UIImage(systemName: "star.fill")))
	private lazy var gradientBackgroundLayer:CAGradientLayer = {
		
		let pastelPalette: [(UIColor, UIColor)] = [
			(UIColor(red: 1.0, green: 0.45, blue: 0.55, alpha: 1.0),
			 UIColor(red: 1.0, green: 0.70, blue: 0.77, alpha: 1.0)),
			(UIColor(red: 0.30, green: 0.65, blue: 1.0, alpha: 1.0),
			 UIColor(red: 0.55, green: 0.80, blue: 1.0, alpha: 1.0)),
			(UIColor(red: 0.35, green: 0.90, blue: 0.50, alpha: 1.0),
			 UIColor(red: 0.60, green: 0.95, blue: 0.70, alpha: 1.0)),
			(UIColor(red: 1.0, green: 0.80, blue: 0.25, alpha: 1.0),
			 UIColor(red: 1.0, green: 0.90, blue: 0.50, alpha: 1.0))
		]
		
		let chosen = pastelPalette.randomElement()!
		
		$0.colors = [chosen.0.cgColor, chosen.1.cgColor]
		$0.startPoint = CGPoint(x: 0, y: 0)
		$0.endPoint = CGPoint(x: 1, y: 1)
		$0.cornerRadius = layer.cornerRadius
		return $0
		
	}(CAGradientLayer())
	private lazy var gradientBorderLayer: CAGradientLayer = {
		
		$0.startPoint = CGPoint(x: 0, y: 0)
		$0.endPoint = CGPoint(x: 1, y: 1)
		$0.cornerRadius = layer.cornerRadius
		return $0
		
	}(CAGradientLayer())
	private lazy var borderShapeLayer: CAShapeLayer = {
		
		$0.lineWidth = 3
		$0.strokeColor = UIColor.black.cgColor
		$0.fillColor = UIColor.clear.cgColor
		return $0
		
	}(CAShapeLayer())
	
	private func syncGradientColors() {
		
		gradientBorderLayer.colors = gradientBackgroundLayer.colors?.reversed()
	}
	
	private func updateLabelText(_ newText: String?) {
		
		label.text = newText?.uppercased()
		
		updateColor()
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		layer.addSublayer(gradientBackgroundLayer)
		layer.addSublayer(gradientBorderLayer)
		
		gradientBorderLayer.mask = borderShapeLayer
		syncGradientColors()
		
		layer.masksToBounds = false
		clipsToBounds = true
		
		addSubview(label)
		label.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
		
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
		gradientBackgroundLayer.frame = bounds
		
		gradientBorderLayer.frame = bounds
		gradientBorderLayer.cornerRadius = layer.cornerRadius
		
		let borderPath = UIBezierPath(roundedRect: bounds.insetBy(dx: 1.5, dy: 1.5), cornerRadius: layer.cornerRadius - 1.5)
		borderShapeLayer.path = borderPath.cgPath
	}
	
	private func updateColor() {
		
		UIView.animation() {
			
			let state = self.isSelected ?? false
			self.gradientBackgroundLayer.isHidden = state
			self.gradientBorderLayer.isHidden = state
			
			self.backgroundColor = self.isSelected ?? false ? Colors.Letter.Selected : .clear
		}
	}
}
