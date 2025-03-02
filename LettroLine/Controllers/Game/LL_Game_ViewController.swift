//
//  LL_Game_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 11/02/2025.
//

import UIKit
import SnapKit

public class LL_Game_ViewController: LL_ViewController {
	
	public var currentGameIndex:Int = 0 {
		
		didSet {
			
			scoreLabel.text = String(key: "Score: ") + "\(currentGameIndex)"
			
			UserDefaults.set(currentGameIndex, .currentGameIndex)
		}
	}
	private lazy var settingsButton:UIBarButtonItem = .init(image: UIImage(systemName: "slider.vertical.3"), menu: settingsMenu)
	private var settingsMenu:UIMenu {
		
		return .init(children: [
			
			UIAction(title: String(key: "game.settings.sounds"), subtitle: String(key: "game.settings.sounds." + (LL_Audio.shared.isSoundsEnabled ? "on" : "off")), image: UIImage(systemName: LL_Audio.shared.isSoundsEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"), handler: { [weak self] _ in
				
				LL_Audio.shared.playButton()
				
				UserDefaults.set(!LL_Audio.shared.isSoundsEnabled, .soundsEnabled)
				
				self?.settingsButton.menu = self?.settingsMenu
			}),
			UIAction(title: String(key: "game.settings.music"), subtitle: String(key: "game.settings.music." + (LL_Audio.shared.isMusicEnabled ? "on" : "off")), image: UIImage(systemName: LL_Audio.shared.isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"), handler: { [weak self] _ in
				
				LL_Audio.shared.playButton()
				
				UserDefaults.set(!LL_Audio.shared.isMusicEnabled, .musicEnabled)
				
				LL_Audio.shared.isMusicEnabled ? LL_Audio.shared.playMusic() : LL_Audio.shared.stopMusic()
				
				self?.settingsButton.menu = self?.settingsMenu
			}),
			UIAction(title: String(key: "game.settings.vibrations"), subtitle: String(key: "game.settings.vibrations." + (UIApplication.isVibrationsEnabled ? "on" : "off")), image: UIImage(systemName: UIApplication.isVibrationsEnabled ? "water.waves" : "water.waves.slash"), handler: { [weak self] _ in
				
				UserDefaults.set(!UIApplication.isVibrationsEnabled, .vibrationsEnabled)
				
				self?.settingsButton.menu = self?.settingsMenu
			})
		])
	}
	private lazy var scoreLabel:LL_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.textColor = .white
		$0.backgroundColor = Colors.Background.Grid
		$0.contentInsets = .init(horizontal: UI.Margins, vertical: UI.Margins/2)
		$0.layer.cornerRadius = UI.CornerRadius
		$0.textAlignment = .center
		$0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		return $0
		
	}(LL_Label())
	private lazy var wordStackView:LL_Word_StackView = .init()
	private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
		
		$0.scrollDirection = .vertical
		$0.sectionInset = .init(horizontal: UI.Margins)
		$0.minimumInteritemSpacing = UI.Margins
		$0.minimumLineSpacing = UI.Margins
		return $0
		
	}(UICollectionViewFlowLayout())
	private lazy var collectionView: LL_Grid_CollectionView = {
		
		$0.columns = 4
		$0.rows = 5
		$0.showFirst = UserDefaults.get(.showFirstLetter) as? Bool ?? false
		$0.allowFingerLift = UserDefaults.get(.allowFingerLift) as? Bool ?? false
		$0.selectionHanlder = { [weak self] character in
			
			self?.wordStackView.select(character)
		}
		$0.deselectionHanlder = { [weak self] in
			
			self?.wordStackView.deselectAll()
		}
		$0.successHanlder = { [weak self] in
			
			LL_Audio.shared.playSuccess()
			UIApplication.feedBack(.Success)
			
			LL_Confettis.start()
			
			self?.currentGameIndex += 1
			
			UIApplication.wait { [weak self] in
				
				self?.newWord()
			}
			
			UIApplication.wait(1.0) { [weak self] in
				
				LL_Confettis.stop()
			}
		}
		$0.failureHanlder = { [weak self] string in
			
			LL_Audio.shared.playError()
			UIApplication.feedBack(.Error)
			
			let alertViewController:LL_Alert_ViewController = .init()
			alertViewController.title = String(key: "game.fail.alert.title")
			alertViewController.add(string)
			alertViewController.addDismissButton()
			alertViewController.dismissHandler = { [weak self] in
				
				self?.currentGameIndex = 0
				UserDefaults.delete(.currentGameIndex)
				
				self?.newWord()
			}
			alertViewController.present()
		}
		return $0
		
	}(LL_Grid_CollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout))
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		title = String(key: "game.title")
		
		navigationItem.rightBarButtonItem = settingsButton
		
		let solutionButton:LL_Button = .init(String(key: "game.help")) { [weak self] _ in
			
			self?.collectionView.showSolution()
		}
		solutionButton.image = UIImage(systemName: "lightbulb.min")
		solutionButton.configuration?.background.cornerRadius = UI.CornerRadius
		solutionButton.configuration?.imagePadding = UI.Margins/2
		solutionButton.configuration?.contentInsets = .init(horizontal: UI.Margins, vertical: UI.Margins/2)
		solutionButton.snp.removeConstraints()
		
		let scoreStackView:UIStackView = .init(arrangedSubviews: [scoreLabel,.init(),solutionButton])
		scoreStackView.axis = .horizontal
		scoreStackView.alignment = .fill
		
		let gridBackgroundView:UIView = .init()
		gridBackgroundView.backgroundColor = Colors.Background.Grid
		gridBackgroundView.layer.cornerRadius = UI.CornerRadius
		gridBackgroundView.addSubview(collectionView)
		collectionView.snp.makeConstraints { make in
			make.left.right.equalToSuperview().inset(UI.Margins/2)
			make.top.bottom.equalToSuperview().inset(1.25*UI.Margins)
		}
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [scoreStackView,wordStackView,gridBackgroundView,.init()])
		contentStackView.axis = .vertical
		contentStackView.spacing = 2*UI.Margins
		view.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(2*UI.Margins)
		}
		contentStackView.setCustomSpacing(3*UI.Margins, after: scoreLabel)
		
		newWord()
		
		contentStackView.animate()
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		currentGameIndex = { currentGameIndex }()
	}
	
	private func newWord() {
		
		let word = String.randomWord(withLetters: Int.random(in: 3...7))
		wordStackView.word = word
		collectionView.solutionWord = word
	}
}
