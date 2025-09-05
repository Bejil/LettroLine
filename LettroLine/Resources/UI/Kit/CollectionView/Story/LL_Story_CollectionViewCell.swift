//
//  LL_Story_CollectionViewCell.swift
//  LettroLine
//
//  Created by BLIN Michael on 14/02/2025.
//

import UIKit
import SnapKit

public class LL_Story_CollectionViewCell : LL_CollectionViewCell {
	
	public class override var identifier: String {
		
		return "storyCellIdentifier"
	}
	public var story: LL_Game_Story.Story? {
		
		didSet {
			
			titleLabel.text = story?.title
			subtitleLabel.text = story?.subtitle
			genreLabel.text = story?.genre
			chaptersLabel.text = "\(story?.chapters?.count ?? 0) " + String(key: "story.chapters")
			
			var numberOfWords = 0
			var totalNumberOfWords = 0
			
			for index in 0..<(story?.chapters?.count ?? 0) {
				
				if let chapter = story?.chapters?[index] {
					
					totalNumberOfWords += chapter.words?.count ?? 0
					
					if index < story?.currentChapterIndex ?? 0 {
						
						numberOfWords += chapter.words?.count ?? 0
					}
					else if index == story?.currentChapterIndex ?? 0 {
						
						numberOfWords += story?.currentWordIndex ?? 0
					}
				}
			}
			
			let progress = Float(numberOfWords)/Float(totalNumberOfWords)
			progressView.setProgress(progress, animated: true)
			progressLabel.text = "\(Int(progress*100.0))%"
		}
	}
	private lazy var containerVisualEffectView: UIVisualEffectView = {
		
		$0.layer.masksToBounds = true
		$0.layer.cornerRadius = (4*UI.Margins)/2.5
		
		let tagsStackView:UIStackView = .init(arrangedSubviews: [genreLabel,chaptersLabel])
		tagsStackView.axis = .horizontal
		tagsStackView.spacing = UI.Margins/2
		tagsStackView.alignment = .center
		tagsStackView.distribution = .fillEqually
		
		let contentStackView = UIStackView(arrangedSubviews: [tagsStackView,titleLabel,subtitleLabel,.init(),progressStackView])
		contentStackView.axis = .vertical
		contentStackView.spacing = UI.Margins
		contentStackView.setCustomSpacing(0, after: subtitleLabel)
		$0.contentView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
		
		return $0
		
	}(UIVisualEffectView(effect: UIBlurEffect(style: .light)))
	private lazy var titleLabel: LL_Label = {
		
		$0.font = Fonts.Content.Title.H3
		$0.textColor = Colors.Content.Title
		$0.textAlignment = .center
		$0.adjustsFontSizeToFitWidth = true
		$0.minimumScaleFactor = 0.8
		$0.numberOfLines = 2
		return $0
		
	}(LL_Label())
	private lazy var genreLabel: LL_Label = {
		
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-3)
		$0.textColor = .white
		$0.numberOfLines = 1
		$0.adjustsFontSizeToFitWidth = true
		$0.minimumScaleFactor = 0.5
		$0.backgroundColor = Colors.Primary
		$0.layer.cornerRadius = UI.Margins/2
		$0.contentInsets = .init(horizontal: UI.Margins/5, vertical: UI.Margins/7)
		$0.textAlignment = .center
		return $0
		
	}(LL_Label())
	
	private lazy var chaptersLabel: LL_Label = {
		
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-3)
		$0.textColor = .white
		$0.numberOfLines = 1
		$0.adjustsFontSizeToFitWidth = true
		$0.minimumScaleFactor = 0.5
		$0.backgroundColor = Colors.Tertiary
		$0.layer.cornerRadius = UI.Margins/2
		$0.contentInsets = .init(horizontal: UI.Margins/5, vertical: UI.Margins/7)
		$0.textAlignment = .center
		return $0
		
	}(LL_Label())
	private lazy var subtitleLabel: LL_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		$0.textColor = Colors.Content.Text
		$0.textAlignment = .center
		return $0
		
	}(LL_Label())
	private lazy var progressStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.spacing = UI.Margins/2
		$0.alignment = .center
		$0.snp.makeConstraints { make in
			make.height.equalTo(UI.Margins/2)
		}
		return $0
		
	}(UIStackView(arrangedSubviews: [progressView,progressLabel]))
	private lazy var progressView:UIProgressView = .init()
	private lazy var progressLabel:LL_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-4)
		return $0
		
	}(LL_Label())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		contentView.addSubview(containerVisualEffectView)
		containerVisualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		selectedBackgroundView = UIView()
		selectedBackgroundView?.backgroundColor = UIColor.white.withAlphaComponent(0.1)
		selectedBackgroundView?.layer.cornerRadius = (4*UI.Margins)/2.5
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
