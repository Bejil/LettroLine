//
//  LL_User_ProgressView.swift
//  LettroLine
//
//  Created by BLIN Michael on 14/08/2025.
//

import UIKit

public class LL_User_ProgressView : UIProgressView {
	
	private var stackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.distribution = .equalCentering
		$0.alignment = .center
		
		$0.addArrangedSubview(.init())
		
		let dotHeight = 1.25*UI.Margins
		
		for _ in 0...2 {
			
			let imageView:UIImageView = .init()
			imageView.backgroundColor = .white
			imageView.tintColor = Colors.Primary
			imageView.contentMode = .scaleAspectFit
			imageView.layer.cornerRadius = dotHeight/2
			imageView.layer.borderWidth = 3
			imageView.layer.borderColor = Colors.Tertiary.cgColor
			imageView.snp.makeConstraints { make in
				make.size.equalTo(dotHeight)
			}
			$0.addArrangedSubview(imageView)
		}
		
		return $0
		
	}(UIStackView())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		progressTintColor = Colors.Tertiary
		trackTintColor = Colors.Tertiary.withAlphaComponent(0.2)
		progressViewStyle = .bar
		snp.makeConstraints { make in
			make.height.equalTo(UI.Margins/2)
		}
		
		addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.left.equalToSuperview()
			make.right.equalToSuperview().offset(2)
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	private func updateDots(for progress: Float) {
		
		let imageViews = stackView.arrangedSubviews.compactMap({ $0 as? UIImageView })
		
		for i in 0..<imageViews.count {
			
			let threshold = Float(i + 1) / Float(imageViews.count)
			let state = progress >= threshold
			let justCompleted = progress >= threshold && progress < threshold + 0.01 // Marge pour détecter le moment exact
			
			imageViews[i].image = state ? UIImage(systemName: "smallcircle.filled.circle") : nil
			
			// Pulse seulement quand l'étape vient d'être complétée
			if justCompleted {
				
				imageViews[i].pulse()
			}
		}
	}
	
	public func animateProgress(to target: Float, duration: TimeInterval) {
		
		let steps: Int = 60
		let stepDuration = duration / Double(steps)
		let start = progress
		let delta = target - start
		
		var currentStep = 0
		
		Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
			
			currentStep += 1
			
			let newProgress = start + delta * Float(currentStep) / Float(steps)
			self?.progress = newProgress
			self?.setProgress(newProgress, animated: false)
			self?.updateDots(for: newProgress)
			
			if currentStep >= steps {
				
				timer.invalidate()
			}
		}
	}
}
