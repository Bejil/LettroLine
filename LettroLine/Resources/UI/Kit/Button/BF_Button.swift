//
//  LL_Button.swift
//  LettroLine
//
//  Created by BLIN Michael on 19/03/2023.
//

import Foundation
import UIKit

public class LL_Button : UIButton {
	
	public enum Style {
		
		case solid
		case tinted
		case gray
		case bordered
		case transparent
	}
	
	public var style:Style = .solid {
		
		didSet {
			
			update()
		}
	}
	public var showTouchEffect:Bool = true
	public override var isEnabled: Bool {
		
		didSet {
			
			alpha = isEnabled ? 1.0 : 0.45
		}
	}
	public var isLoading:Bool = false {
		
		didSet {
			
			isUserInteractionEnabled = !isLoading
			configuration?.showsActivityIndicator = isLoading
		}
	}
	public var isPrimary:Bool = true {
		
		didSet {
			
			update()
		}
	}
	public var isDelete:Bool = false {
		
		didSet {
			
			update()
		}
	}
	public var isText:Bool = false {
		
		didSet {
			
			update()
		}
	}
	public var title:String? {
		
		didSet {
			
			update()
		}
	}
	public var titleFont:UIFont = Fonts.Content.Button.Title {
		
		didSet {
			
			update()
		}
	}
	public var subtitle:String? {
		
		didSet {
			
			update()
		}
	}
	public var subtitleFont:UIFont = Fonts.Content.Button.Subtitle {
		
		didSet {
			
			update()
		}
	}
	public var image:UIImage? {
		
		didSet {
			
			update()
		}
	}
	public typealias Handler = ((LL_Button?)->Void)?
	public var action:Handler = nil
	public var badge:String? {
		
		didSet {
			
			if let badgeText = badge, !badgeText.isEmpty {
				
				badgeView.text = badgeText
				badgeView.isHidden = false
				
				badgeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
					
					self?.badgeView.pulse()
				})
			}
			else {
				
				badgeView.isHidden = true
				
				badgeTimer?.invalidate()
				badgeTimer = nil
			}
		}
	}
	private lazy var badgeView:LL_Label = {
		
		$0.backgroundColor = Colors.Primary
		$0.textColor = .white
		$0.textAlignment = .center
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-2)
		$0.layer.cornerRadius = UI.Margins/2
		$0.clipsToBounds = true
		$0.contentInsets = .init(2)
		$0.isHidden = true
		$0.snp.makeConstraints { make in
			make.height.equalTo(UI.Margins)
			make.width.greaterThanOrEqualTo(UI.Margins)
		}
		return $0
		
	}(LL_Label())
	private var badgeTimer:Timer?
	
	deinit {
		
		badgeTimer?.invalidate()
		badgeTimer = nil
	}
	
	convenience init(_ title:String? = nil, _ handler:Handler = nil) {
		
		self.init(frame: .zero)
		
		defer {
			
			self.title = title
			self.action = handler
		}
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		layer.shadowOffset = .zero
		layer.shadowRadius = 1.5*UI.Margins
		layer.shadowOpacity = 0.25
		layer.masksToBounds = false
		snp.makeConstraints { make in
			
			make.size.greaterThanOrEqualTo(4*UI.Margins)
		}
		
		addSubview(badgeView)
		badgeView.snp.makeConstraints { make in
			make.top.right.equalToSuperview()
		}
		
		update()
		
		addAction(.init(handler: { [weak self] _ in
			
			UIApplication.feedBack(.On)
			LL_Audio.shared.playButton()
			
			self?.action?(self)
			
		}), for: .touchUpInside)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		super.touchesBegan(touches, with: event)
		
		UIApplication.feedBack(.On)
		
		if showTouchEffect, style != .transparent, let touch = event?.allTouches?.first, let touchView = touch.view {
			
			let effectContainerView:UIView = .init()
			effectContainerView.isUserInteractionEnabled = false
			effectContainerView.clipsToBounds = true
			touchView.addSubview(effectContainerView)
			
			effectContainerView.snp.makeConstraints { make in
				make.edges.equalToSuperview()
			}
			
			touchView.layoutIfNeeded()
			
			let touchLocation = touch.location(in: effectContainerView)
			
			let view:UIView = .init()
			view.backgroundColor = .white
			view.alpha = 0.25
			effectContainerView.addSubview(view)
			
			view.snp.makeConstraints { make in
				make.width.height.equalTo(0)
				make.center.equalTo(touchLocation)
			}
			
			let radius = max(effectContainerView.frame.size.width,effectContainerView.frame.size.height)
			
			UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
				
				view.layer.cornerRadius = radius
				
				view.snp.updateConstraints { make in
					
					make.width.height.equalTo(2*radius)
				}
				
				view.layoutIfNeeded()
				view.alpha = 0.0
				
			} completion: { _ in
				
				effectContainerView.removeFromSuperview()
			}
		}
	}
	
	private func update() {
		
		let oldConfiguration = configuration
		
		if style == .solid {
			
			configuration = .filled()
		}
		else if style == .tinted {
			
			configuration = .tinted()
		}
		else if style == .gray {
			
			configuration = .gray()
		}
		else if style == .bordered || style == .transparent {
			
			configuration = .plain()
			
			if style == .bordered {
				
				configuration?.background.strokeColor = isText ? Colors.Button.Text.Background : isDelete ? Colors.Button.Delete.Background : isPrimary ? Colors.Button.Primary.Background : Colors.Button.Secondary.Background
				configuration?.background.strokeWidth = 1
			}
		}
		
		configuration?.baseBackgroundColor = isText ? Colors.Button.Text.Background : isDelete ? Colors.Button.Delete.Background : isPrimary ? Colors.Button.Primary.Background : Colors.Button.Secondary.Background
		configuration?.baseForegroundColor = style == .tinted ? configuration?.baseBackgroundColor : isText ? Colors.Button.Text.Content : isDelete ? Colors.Button.Delete.Content : isPrimary ? Colors.Button.Primary.Content : Colors.Button.Secondary.Content
		
		if style == .bordered || style == .transparent {
			
			configuration?.baseForegroundColor = isText ? Colors.Button.Text.Background : isDelete ? Colors.Button.Delete.Background : isPrimary ? Colors.Button.Primary.Background : Colors.Button.Secondary.Background
		}
		
		configuration?.cornerStyle = .fixed
		
		configuration?.background.cornerRadius = (4*UI.Margins)/2.5
		
		if let baseBackgroundColor = configuration?.baseBackgroundColor {
			
			layer.shadowColor = baseBackgroundColor.cgColor
		}
		
		let inset = UI.Margins
		configuration?.contentInsets = .init(inset)
		
		let textColor = style == .tinted ? configuration?.baseBackgroundColor : (style == .bordered || style == .transparent ? (isText ? Colors.Button.Text.Background : isDelete ? Colors.Button.Delete.Background : isPrimary ? Colors.Button.Primary.Background : Colors.Button.Secondary.Background) : (isText ? Colors.Button.Text.Content : isDelete ? Colors.Button.Delete.Content : isPrimary ? Colors.Button.Primary.Content : Colors.Button.Secondary.Content))
		
		var titleAttributedString:AttributedString? = nil
		
		if let title = title {
			
			titleAttributedString = AttributedString.init(title)
			titleAttributedString?.font = titleFont
			titleAttributedString?.foregroundColor = textColor
		}
		
		configuration?.attributedTitle = titleAttributedString
		configuration?.titleAlignment = oldConfiguration?.titleAlignment ?? .center
		contentHorizontalAlignment = .center
		
		var subtitleAttributedString:AttributedString? = nil
		
		if let subtitle = subtitle {
			
			subtitleAttributedString = AttributedString.init(subtitle)
			subtitleAttributedString?.font = subtitleFont
			titleAttributedString?.foregroundColor = textColor
		}
		
		configuration?.attributedSubtitle = subtitleAttributedString
		
		configuration?.image = image
		configuration?.imagePlacement = oldConfiguration?.imagePlacement ?? .leading
		configuration?.imagePadding = UI.Margins
	}
}
