//
//  LL_User_StackView.swift
//  LettroLine
//
//  Created by BLIN Michael on 12/08/2025.
//

import UIKit
import FlexibleSteppedProgressBar

public class LL_User_StackView : UIStackView {
	
	private lazy var imageView:LL_User_ImageView = .init()
	private lazy var nameLabel:LL_Label = {
		
		$0.font = Fonts.Content.Title.H3
		$0.numberOfLines = 1
		$0.text = UserDefaults.get(.userName) as? String ?? UserDefaults.get(.userId) as? String
		return $0
		
	}(LL_Label())
	private lazy var bonusLabel:LL_Label = {
		
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-3)
		$0.textColor = .white
		
		let bonus = UserDefaults.get(.userBonus) as? Int ?? 0
		$0.text = "\(bonus)"
		$0.isHidden = bonus == 0
		
		return $0
		
	}(LL_Label())
	private lazy var bonusStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.spacing = UI.Margins/5
		$0.layer.cornerRadius = 6
		$0.backgroundColor = Colors.Primary
		$0.alignment = .center
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(horizontal: UI.Margins/3, vertical: 3)
		
		$0.addArrangedSubview(bonusLabel)
		
		let imageView:UIImageView = .init(image: UIImage(systemName: "star.fill"))
		imageView.contentMode = .scaleAspectFit
		imageView.tintColor = .white
		imageView.snp.makeConstraints { make in
			make.size.equalTo(2*UI.Margins/3)
		}
		$0.addArrangedSubview(imageView)
		
		return $0
		
	}(UIStackView())
	private lazy var progressView:LL_User_ProgressView = .init()
	private lazy var bonusImageView:UIImageView = {
		
		$0.contentMode = .scaleAspectFit
		$0.tintColor = Colors.Tertiary
		$0.isUserInteractionEnabled = true
		$0.snp.makeConstraints { make in
			make.size.equalTo(3*UI.Margins)
		}
		$0.addGestureRecognizer(UITapGestureRecognizer(block: { _ in
			
			UIApplication.feedBack(.On)
			LL_Audio.shared.play(.button)
			
			let alertController:LL_Alert_ViewController = .init()
			alertController.title = String(key: "rewards.alert.title")
			
			if LL_Rewards.shared.canGetReward {
				
				alertController.add(String(key: "rewards.alert.success.label"))
				alertController.addButton(title: String(key: "rewards.alert.success.button")) { _ in
					
					alertController.close {
						
						LL_Confettis.stop()
						
						LL_Rewards.shared.get()
						
						NotificationCenter.post(.updateRewards)
					}
				}
				alertController.present {
					
					LL_Confettis.start()
				}
			}
			else {
				
				if LL_Rewards.shared.alreadyGetReward {
					
					alertController.add(String(key: "rewards.alert.already.label"))
				}
				else {
					
					alertController.add(String(key: "rewards.alert.default.label"))
					
					var state = LL_Rewards.shared.lastConnexionDateStatus
					var button = alertController.addButton(title: String(key: "rewards.alert.default.button.0"))
					button.isUserInteractionEnabled = false
					button.style = state ? .solid : .tinted
					button.image = UIImage(systemName: state ? "checkmark.square" : "square")
					
					state = LL_Rewards.shared.lastGameDateStatus
					button = alertController.addButton(title: String(key: "rewards.alert.default.button.1"))
					button.isUserInteractionEnabled = false
					button.style = state ? .solid : .tinted
					button.image = UIImage(systemName: state ? "checkmark.square" : "square")
					
					state = LL_Rewards.shared.lastBestScoreDateStatus
					button = alertController.addButton(title: String(key: "rewards.alert.default.button.2"))
					button.isUserInteractionEnabled = false
					button.style = state ? .solid : .tinted
					button.image = UIImage(systemName: state ? "checkmark.square" : "square")
				}
				
				alertController.addDismissButton()
				alertController.present()
			}
		}))
		return $0
		
	}(UIImageView(image: UIImage(systemName: "bubble.right.fill")))
	private var bonusTimer:Timer?
	
	deinit {
		
		stopTimer()
	}
	
	public override init(frame: CGRect) {
	
		super.init(frame: frame)
		
		axis = .horizontal
		spacing = UI.Margins
		isLayoutMarginsRelativeArrangement = true
		layoutMargins = .init(horizontal: 2*UI.Margins)
		alignment = .center
		
		addArrangedSubview(imageView)
		
		let starImageView:UIImageView = .init(image: UIImage(systemName: "star.fill"))
		starImageView.contentMode = .scaleAspectFit
		starImageView.tintColor = .white
		bonusImageView.addSubview(starImageView)
		starImageView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
		starImageView.transform = .init(translationX: 0, y: -UI.Margins/7)
		
		let nameStackView:UIStackView = .init(arrangedSubviews: [nameLabel,bonusStackView,.init(),bonusImageView])
		nameStackView.axis = .horizontal
		nameStackView.alignment = .center
		nameStackView.spacing = 2*UI.Margins/3
		
		let stackView:UIStackView = .init(arrangedSubviews: [nameStackView,progressView])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins/3
		addArrangedSubview(stackView)
		
		stackView.transform = .init(translationX: 0, y: -UI.Margins/3)
		
		NotificationCenter.add(.updateUserName) { [weak self] _ in
			
			self?.imageView.loadAvatar()
			self?.nameLabel.text = UserDefaults.get(.userName) as? String
		}
		
		NotificationCenter.add(.updateUserBonus) { [weak self] _ in
			
			let bonus = UserDefaults.get(.userBonus) as? Int ?? 0
			self?.bonusLabel.text = "\(bonus)"
			self?.bonusStackView.isHidden = bonus == 0
		}
		
		NotificationCenter.add(.updateRewards) { [weak self] _ in
			
			self?.progressView.animateProgress(to: (1.0/3.0)*Float(LL_Rewards.shared.steps), duration: 1.0)
			
			self?.stopTimer()
			
			if LL_Rewards.shared.canGetReward {
				
				self?.startTimer()
			}
		}
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func startTimer() {
		
		bonusTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { [weak self] _ in
			
			self?.bonusImageView.pulse()
		})
	}
	
	private func stopTimer() {
		
		bonusTimer?.invalidate()
		bonusTimer = nil
	}
}
