//
//  LL_Placeholder_View.swift
//  LettroLine
//
//  Created by BLIN Michael on 17/02/2025.
//

import UIKit
import SnapKit

public class LL_Placeholder_View: UIView {
	
	private class ScrollView: UIScrollView {
		
		public var isCentered:Bool = true {
			
			didSet {
				
				updateContentInset()
			}
		}
		
		public override var bounds: CGRect {
			
			didSet {
				
				updateContentInset()
			}
		}
		
		public override var contentSize: CGSize {
			
			didSet {
				
				updateContentInset()
			}
		}
		
		private func updateContentInset() {
			
			if isCentered {
				
				var top = CGFloat(0)
				var left = CGFloat(0)
				
				if contentSize.width < bounds.width {
					
					left = (bounds.width - contentSize.width) / 2
				}
				
				if contentSize.height < bounds.height {
					
					top = (bounds.height - contentSize.height) / 2
				}
				
				contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
			}
		}
	}
	
	public var isCentered:Bool = true {
		
		didSet {
			
			scrollView.isCentered = isCentered
		}
	}
	
	public enum Style {
		
		case Empty
		case Loading
		case Error
	}
	public var style:Style?
	private lazy var scrollView:ScrollView = {
		
		$0.clipsToBounds = false
		$0.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.width.equalToSuperview().inset(1.5*UI.Margins)
		}
		return $0
		
	}(ScrollView())
	public var title:String? {
		
		didSet {
			
			titleLabel.text = title
			titleLabel.isHidden = title == nil || title?.isEmpty ?? false
		}
	}
	public lazy var titleLabel:LL_Label = {
		
		$0.font = Fonts.Content.Title.H1
		$0.textColor = Colors.Content.Title
		$0.textAlignment = .center
		$0.isHidden = true
		return $0
		
	}(LL_Label(title))
	public var image:UIImage? {
		
		didSet {
			
			imageView.image = image
			imageView.isHidden = image == nil
		}
	}
	public lazy var imageView:UIImageView = {
		
		$0.contentMode = .scaleAspectFit
		$0.isHidden = true
		return $0
		
	}(UIImageView(image: image))
	public lazy var contentStackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = 1.5*UI.Margins
		return $0
		
	}(UIStackView(arrangedSubviews: [imageView,titleLabel]))
	
	convenience init(_ style:Style? = nil, _ error:Error? = nil, _ handler:LL_Button.Handler = nil) {
		
		self.init(frame: .zero)
		
		defer {
			
			if style == .Empty {
				
				image = UIImage(named: "placeholder_empty")
				title = String(key: "placeholder.empty.title")
				addLabel(String(key: "placeholder.empty.content"))
			}
			else if style == .Loading {
				
				image = UIImage(named: "placeholder_loading")
				title = String(key: "placeholder.loading.title")
				
				let label = addLabel(String(key: "placeholder.loading.content.0"))
				
				UIApplication.wait(3.0) {
					
					label.text = String(key: "placeholder.loading.content.1")
				}
			}
			else if style == .Error || error != nil {
				
				image = UIImage(named: "placeholder_error")
				title = String(key: "placeholder.error.title")
				
				if let error = error {
					
					addLabel(error.localizedDescription)
				}
				
				let button = addButton(String(key: "placeholder.error.button"), handler)
				button.isHidden = handler == nil
			}
		}
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		clipsToBounds = true
		
		addSubview(scrollView)
		scrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		imageView.snp.makeConstraints { make in
			make.height.equalTo(contentStackView.snp.width).multipliedBy(0.5)
		}
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public func scrollToTop(animated:Bool = true) {
		
		scrollView.setContentOffset(.zero, animated: animated)
	}
	
	@discardableResult public func addLabel(_ string:String) -> LL_Label {
		
		let label:LL_Label = .init(string)
		label.textAlignment = .center
		contentStackView.addArrangedSubview(label)
		
		return label
	}
	
	@discardableResult public func addButton(_ string:String? = nil, _ handler:LL_Button.Handler = nil) -> LL_Button {
		
		let button:LL_Button = .init(string,handler)
		contentStackView.addArrangedSubview(button)
		
		return button
	}
}
