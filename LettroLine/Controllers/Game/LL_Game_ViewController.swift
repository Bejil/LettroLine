//
//  LL_Game_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 11/02/2025.
//

import UIKit
import SnapKit
import GoogleMobileAds

public class LL_Game_ViewController: LL_ViewController {
	
	public var canAddMorePoint:Bool = true
	public var game:LL_Game? {
		
		return nil
	}
	public var isBestScore:Bool = false {
		
		didSet {
			
			if oldValue != isBestScore {
				
				pause()
				
				let viewController:LL_Tutorial_ViewController = .init()
				viewController.items = [
					
					LL_Tutorial_ViewController.Item(title: String(key: "game.score.subtitle"), timeInterval: 0.5)
				]
				viewController.completion = { [weak self] in
					
					self?.play()
				}
				viewController.present()
			}
		}
	}
	public lazy var usedIndexPaths: Array<IndexPath> = []
	private var lastSelectedIndexPath: IndexPath?
	public var allowFingerLift: Bool {
		
		return true
	}
	private lazy var showFirst:Bool = false {
		
		didSet {
			
			collectionView.indexPathsForVisibleItems.forEach({
				
				if let cell = collectionView.cellForItem(at: $0) as? LL_Grid_Letter_CollectionViewCell {
					
					let row = $0.item / columns
					let col = $0.item % columns
					
					if let grid = grid?.grid, row < grid.count, col < grid[row].count {
						
						cell.isFirst = showFirst && grid[row][col].uppercased() == solutionWord?.first?.uppercased()
					}
				}
			})
		}
	}
	private lazy var isGameOver = false
	public var grid: (grid: [[Character]], positions: [CGPoint], bonus: IndexPath?)? {
		
		didSet {
			
			collectionView.reloadData()
		}
	}
	public lazy var columns: Int = 5
	public lazy var rows: Int = 5
	public var solutionWord: String? {
		
		didSet {
			
			resetGame()
			
			wordStackView.word = solutionWord
			grid = generateGrid()
		}
	}
	private lazy var currentSolutionIndex: Int = 0
	private lazy var userPathLayer:CAShapeLayer = {
		
		$0.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
		$0.lineWidth = 1.5*UI.Margins
		$0.fillColor = UIColor.clear.cgColor
		$0.lineCap = .round
		$0.lineJoin = .round
		return $0
		
	}(CAShapeLayer())
	private lazy var userPath:UIBezierPath = .init()
	private lazy var solutionPathLayer:CAShapeLayer = {
		
		$0.strokeColor = Colors.Primary.withAlphaComponent(0.5).cgColor
		$0.lineWidth = 1.5*UI.Margins
		$0.fillColor = UIColor.clear.cgColor
		$0.lineCap = .round
		$0.lineJoin = .round
		return $0
		
	}(CAShapeLayer())
	private lazy var settingsButton:UIBarButtonItem = .init(image: UIImage(systemName: "slider.vertical.3"), menu: settingsMenu)
	private var settingsMenu:UIMenu {
		
		return .init(children: [
			
			UIAction(title: String(key: "game.settings.sounds"), subtitle: String(key: "game.settings.sounds." + (LL_Audio.shared.isSoundsEnabled ? "on" : "off")), image: UIImage(systemName: LL_Audio.shared.isSoundsEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"), handler: { [weak self] _ in
				
				LL_Audio.shared.play(.button)
				
				UserDefaults.set(!LL_Audio.shared.isSoundsEnabled, .soundsEnabled)
				
				self?.settingsButton.menu = self?.settingsMenu
			}),
			UIAction(title: String(key: "game.settings.music"), subtitle: String(key: "game.settings.music." + (LL_Audio.shared.isMusicEnabled ? "on" : "off")), image: UIImage(systemName: LL_Audio.shared.isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"), handler: { [weak self] _ in
				
				LL_Audio.shared.play(.button)
				
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
	public lazy var scoreStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.alignment = .fill
		$0.distribution = .equalCentering
		return $0
		
	}(UIStackView(arrangedSubviews: [scoreButton,helpButton]))
	public lazy var scoreButton:LL_Button = {
		
		$0.subtitleFont = Fonts.Content.Button.Subtitle.withSize(Fonts.Content.Button.Subtitle.pointSize-4)
		$0.configuration?.contentInsets = .init(horizontal: UI.Margins, vertical: UI.Margins/2)
		$0.configuration?.imagePadding = UI.Margins/2
		$0.snp.removeConstraints()
		$0.image = UIImage(systemName: "trophy")?.applyingSymbolConfiguration(.init(pointSize: 12))
		return $0
		
	}(LL_Button() { [weak self] _ in
		
		if self?.game?.score != 0 {
			
			self?.pause()
			
			let alertController:LL_Alert_ViewController = .init()
			alertController.title = String(key: "game.words.alert.title")
			
			self?.game?.words.forEach {
				
				alertController.add($0.uppercased())
			}
			
			alertController.addDismissButton(sticky: true)
			alertController.dismissHandler = { [weak self] in
				
				self?.play()
			}
			alertController.present(as: .Sheet, withAnimation: false)
		}
	})
	public lazy var helpButton:LL_Button = {
		
		$0.image = UIImage(systemName: "star.fill")?.withTintColor(Colors.Button.Delete.Background, renderingMode: .alwaysOriginal).applyingSymbolConfiguration(.init(pointSize: 12))
		$0.title = String(key: "game.help")
		$0.style = .tinted
		$0.configuration?.contentInsets = .init(horizontal: UI.Margins, vertical: UI.Margins/2)
		$0.configuration?.imagePadding = UI.Margins/2
		$0.snp.removeConstraints()
		return $0
		
	}(LL_Button() { [weak self] _ in
		
		if var bonus = UserDefaults.get(.userBonus) as? Int, bonus != 0 {
			
			self?.pause()
			
			let alertController:LL_Alert_ViewController = .init()
			alertController.title = String(key: "game.help.alert.title")
			alertController.add(String(key: "game.help.alert.text"))
			let button = alertController.addDismissButton { [weak self] _ in
				
				self?.play()
				
				bonus -= 1
				UserDefaults.set(bonus, .userBonus)
				
				NotificationCenter.post(.updateUserBonus)
				
				self?.updateScore()
				self?.showSolution()
			}
			button.style = .solid
			alertController.addCancelButton()
			alertController.present()
		}
		else {
			
			self?.pause()
			
			let alertController:LL_Alert_ViewController = .init()
			alertController.title = String(key: "game.help.alert.title")
			alertController.add(String(key: "game.help.alert.content.0"))
			alertController.add(String(key: "game.help.alert.content.1"))
			alertController.addButton(title: String(key: "game.help.alert.button.title"), subtitle: String(key: "game.help.alert.button.subtitle")) { [weak self] button in
				
				if LL_Network.shared.isConnected {
					
					button?.isLoading = true
					
					Task {
						
						await LL_Ads.shared.presentRewardedAd(Ads.FullScreen.GameBonus) { [weak self] state, exception in
							
							button?.isLoading = true
							
							alertController.close { [weak self] in
								
								if state {
									
									self?.showSolution()
									self?.play()
								}
								else {
									
									let alertController = LL_Alert_ViewController.present(LL_Error([String(key: "ads.error"),exception ?? false ? String(key: "ads.error.exception") : nil].compactMap({ $0 }).joined(separator: "\n")))
									alertController.dismissHandler = { [weak self] in
										
										if exception ?? false {
											
											self?.showSolution()
										}
										
										self?.play()
									}
								}
							}
						}
					}
				}
				else {
					
					LL_Alert_ViewController.present(LL_Error(String(key: "ads.network.error")))
				}
			}
			
			alertController.addCancelButton() { [weak self] _ in
				
				self?.play()
			}
			alertController.present()
		}
	})
	public lazy var wordStackView:LL_Word_StackView = .init()
	private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
		
		$0.scrollDirection = .vertical
		$0.sectionInset = .init(horizontal: UI.Margins)
		$0.minimumInteritemSpacing = UI.Margins
		$0.minimumLineSpacing = UI.Margins
		return $0
		
	}(UICollectionViewFlowLayout())
	private lazy var panGestureRecognizer:UIPanGestureRecognizer = .init { [weak self] gestureRecognizer in
		guard let self = self, let gesture = gestureRecognizer as? UIPanGestureRecognizer else { return }
		
		let location = gesture.location(in: self.collectionView)
		
		switch gesture.state {
		case .began:
			
			self.hideSolution()
				// Réinitialisation du tracé et des index utilisés
			self.userPath.removeAllPoints()
			self.usedIndexPaths.removeAll()
			self.currentSolutionIndex = 0
			
				// Dérélection des cellules visibles
			if let cells = self.collectionView.visibleCells as? [LL_Grid_Letter_CollectionViewCell] {
				
				cells.forEach {
					
					$0.isSelected = false
					$0.isFirst = false
					$0.resetTimers()
				}
			}
			
			self.userPathLayer.removeAllAnimations()
			self.userPathLayer.strokeEnd = 1.0
			
			UIView.animation {
				self.userPathLayer.opacity = 1.0
			}
			
				// Traitement immédiat de la position de départ
			self.processPanGesture(at: location)
			
		case .changed:
			if isGameOver { return }
			
			if !self.collectionView.bounds.contains(location) {
				if !isGameOver {
					self.fail(reason: String(key: "game.fail.reason.outOfBounds"))
					return
				}
			}
				// Traitement de la position mise à jour
			self.processPanGesture(at: location)
			
		case .ended, .cancelled:
			if self.allowFingerLift {
				UIApplication.feedBack(.Off)
				self.userPathLayer.removeAnimation(forKey: "strokeEndReverse")
				
				CATransaction.begin()
				CATransaction.setCompletionBlock { [weak self] in
					guard let self = self else { return }
					self.userPath.removeAllPoints()
					self.usedIndexPaths.removeAll()
					self.currentSolutionIndex = 0
					
					if let cells = self.collectionView.visibleCells as? [LL_Grid_Letter_CollectionViewCell] {
						
						cells.forEach {
							
							$0.isSelected = false
							$0.isFirst = self.showFirst && $0.letter == self.solutionWord?.first?.uppercased()
							$0.startTimers()
						}
					}
					
					for cell in self.collectionView.visibleCells {
						cell.isSelected = false
						(cell as? LL_Grid_Letter_CollectionViewCell)?.startTimers()
					}
					self.showFirst = self.showFirst
					self.userPathLayer.path = nil
					self.wordStackView.deselectAll()
				}
				
				let currentStrokeEnd = self.userPathLayer.presentation()?.strokeEnd ?? 1.0
				let animation = CABasicAnimation(keyPath: "strokeEnd")
				animation.fromValue = currentStrokeEnd
				animation.toValue = 0.0
				animation.duration = 0.1 * Double(self.usedIndexPaths.count)
				animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
				self.userPathLayer.strokeEnd = 0.0
				self.userPathLayer.add(animation, forKey: "strokeEndReverse")
				CATransaction.commit()
			} else if !isGameOver, let word = self.solutionWord?.lowercased(), self.currentSolutionIndex < word.count {
				self.fail(reason: String(key: "game.fail.reason.fingerLift"))
				return
			}
			
		default:
			break
		}
	}
	public lazy var collectionView: LL_CollectionView = {
		
		$0.register(LL_Grid_Letter_CollectionViewCell.self, forCellWithReuseIdentifier: LL_Grid_Letter_CollectionViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		$0.allowsSelection = false
		$0.clipsToBounds = false
		$0.isHeightDynamic = true
		
		$0.addGestureRecognizer(panGestureRecognizer)
		
		$0.layer.addSublayer(solutionPathLayer)
		$0.layer.addSublayer(userPathLayer)
		return $0
		
	}(LL_CollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout))
	private lazy var bannerView = LL_Ads.shared.presentBanner(Ads.Banner.Game, self)
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.rightBarButtonItem = settingsButton
		
		let gridBackgroundView:UIView = .init()
		gridBackgroundView.backgroundColor = Colors.Background.Grid
		gridBackgroundView.layer.cornerRadius = UI.CornerRadius
		gridBackgroundView.addSubview(collectionView)
		collectionView.snp.makeConstraints { make in
			make.left.right.equalToSuperview().inset(UI.Margins/2)
			make.top.bottom.equalToSuperview().inset(1.25*UI.Margins)
		}
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [scoreStackView,wordStackView,gridBackgroundView,.init(),bannerView])
		contentStackView.axis = .vertical
		contentStackView.spacing = 2*UI.Margins
		view.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(2*UI.Margins)
		}
		contentStackView.setCustomSpacing(3*UI.Margins, after: scoreStackView)
		
		newWord()
		
		contentStackView.animate()
		
		updateScore()
		
		LL_Ads.shared.presentInterstitial(Ads.FullScreen.GameStart, { [weak self] in
			
			self?.pause()
			
		}, { [weak self] in
			
			self?.tutorial()
		})
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		updateScore()
	}
	
	public func updateBestScore() {
		
	}
	
	private func tutorial() {
		
		let viewController:LL_Tutorial_ViewController = .init()
		viewController.key = .tutorialClassicGame
		viewController.items = [
			
			LL_Tutorial_ViewController.Item(
				title: String(key: "game.tutorial.0.title"),
				subtitle: String(key: "game.tutorial.0.content"),
				button: String(key: "game.tutorial.0.button")
			),
			LL_Tutorial_ViewController.Item(
				title: String(key: "game.tutorial.3.title"),
				subtitle: String(key: "game.tutorial.3.content"),
				button: String(key: "game.tutorial.3.button")
			),
			LL_Tutorial_ViewController.Item(
				title: String(key: "game.tutorial.4.title"),
				subtitle: String(key: "game.tutorial.4.content"),
				button: String(key: "game.tutorial.4.button")
			),
			LL_Tutorial_ViewController.Item(
				sourceView: scoreButton,
				title: String(key: "game.tutorial.1.title"),
				subtitle: String(key: "game.tutorial.1.content"),
				button: String(key: "game.tutorial.1.button")
			),
			LL_Tutorial_ViewController.Item(
				sourceView: helpButton,
				title: String(key: "game.tutorial.2.title"),
				subtitle: String(key: "game.tutorial.2.content"),
				button: String(key: "game.tutorial.2.button")
			)
		]
		viewController.completion = { [weak self] in
			
			self?.specificTutorial()
		}
		viewController.present()
	}
	
	public func play() {
		
		LL_Rewards.shared.updateLastGameDate()
	}
	
	public func pause() {
		
	}
	
	public func newWord() {
		
		updateBestScore()
		
		showFirst = false
		
		let score = Double(game?.score ?? 0)
		
		var wordLength = String.minLetters
		
		for n in (String.minLetters + 1)...String.maxLetters {
			
			let threshold = Game.firstPointsLevel * pow(Game.pointsLevelMultiplier, Double(n - (String.minLetters + 1)))
			
			if score >= threshold {
				
				wordLength = n
			}
			else {
				
				break
			}
		}
		
		solutionWord = game?.newWord(wordLength)
		
		bannerView.refresh()
	}
	
	public func specificTutorial() {
		
		play()
	}
	
	private func resetGame() {
		
		isGameOver = false
		currentSolutionIndex = 0
		userPath.removeAllPoints()
		usedIndexPaths.removeAll()
		userPathLayer.path = nil
		hideSolution()
		grid = generateGrid()
	}
	
	public func fail(reason:String?) {
		
		collectionView.delegate = nil
		collectionView.delegate = self
		
		isGameOver = true
		
		LL_Audio.shared.play(.error)
		UIApplication.feedBack(.Error)
		
		pause()
		
		let alertController:LL_Alert_ViewController = .init()
		alertController.title = String(key: "game.fail.alert.title")
		alertController.add(reason)
		alertController.backgroundView.isUserInteractionEnabled = false
		alertController.add(String(key: "game.fail.alert.content"))
		alertController.addButton(title: String(key: "game.fail.alert.button")) { [weak self] button in
			
			if LL_Network.shared.isConnected {
				
				self?.pause()
				
				button?.isLoading = true
				
				Task {
					
					await LL_Ads.shared.presentRewardedAd(Ads.FullScreen.GameChance) {  [weak self] state, exception in
						
						alertController.close { [weak self] in
							
							if state {
								
								self?.play()
								self?.newWord()
							}
							else {
								
								let alertController = LL_Alert_ViewController.present(LL_Error([String(key: "ads.error"),exception ?? false ? String(key: "ads.error.exception") : nil].compactMap({ $0 }).joined(separator: "\n")))
								alertController.dismissHandler = { [weak self] in
									
									if exception ?? false {
										
										self?.play()
										self?.newWord()
									}
									else {
										
										self?.game?.reset()
										self?.dismiss()
									}
								}
							}
						}
					}
				}
			}
			else {
				
				LL_Alert_ViewController.present(LL_Error(String(key: "ads.network.error")))
			}
		}
		alertController.addDismissButton { [weak self] _ in
			
			self?.game?.reset()
			
			self?.dismiss()
		}
		alertController.present()
		
		UIView.animation { [weak self] in
			
			self?.userPathLayer.opacity = 0.0
		}
	}
	
	public override func dismiss(_ completion: (() -> Void)? = nil) {
		
		super.dismiss(completion)
		
		LL_Ads.shared.presentInterstitial(Ads.FullScreen.GameLose, nil, {
			
			if LL_Ads.shared.shouldDisplayAd {
				
				LL_InAppPurchase.shared.promptInAppPurchaseAlert(withCapping: true)
			}
		})
	}
	
	private func generateGrid() -> (grid: [[Character]], positions: [CGPoint], bonus: IndexPath?)? {
		
		let alphabet = Array("abcdefghijklmnopqrstuvwxyz")
		
			// Initialisation de la grille avec des espaces
		var grid = Array(repeating: Array(repeating: Character(" "), count: columns), count: rows)
		
			// Vérification et récupération du mot solution
		guard let solution = solutionWord?.lowercased(), !solution.isEmpty else { return nil }
		let letters = Array(solution)
		
			// Définition des 8 directions autorisées
		let directions: [(dx: Int, dy: Int)] = [
			(-1, -1), (-1,  0), (-1,  1),
			( 0, -1),          ( 0,  1),
			( 1, -1), ( 1,  0), ( 1,  1)
		]
		
			// Fonction utilitaire : retourne le centre d'une cellule en fonction de sa ligne et colonne
		func centerPoint(for row: Int, col: Int) -> CGPoint {
			return CGPoint(x: CGFloat(col) + 0.5, y: CGFloat(row) + 0.5)
		}
		
			// Vérifie que l'ajout d'un candidat au chemin ne crée pas d'intersection avec un segment déjà tracé
		func causesIntersection(path: [(row: Int, col: Int)], candidate: (row: Int, col: Int)) -> Bool {
			let newStart = centerPoint(for: path.last!.row, col: path.last!.col)
			let newEnd = centerPoint(for: candidate.row, col: candidate.col)
			
				// S'il y a moins de 3 points, il ne peut pas y avoir d'intersection
			if path.count < 3 { return false }
			
			for i in 0..<(path.count - 2) {
				let p1 = centerPoint(for: path[i].row, col: path[i].col)
				let p2 = centerPoint(for: path[i+1].row, col: path[i+1].col)
				if lineSegmentsIntersect(p1, p2, newStart, newEnd) {
					return true
				}
			}
			
			return false
		}
		
			// Backtracking récursif pour trouver un chemin valide pour le mot solution
		func backtrack(index: Int, currentPos: (row: Int, col: Int), path: [(row: Int, col: Int)]) -> [(row: Int, col: Int)]? {
				// Si toutes les lettres ont été placées, le chemin est complet
			if index == letters.count {
				return path
			}
			
			var candidates = [(row: Int, col: Int)]()
			
				// Pour chaque direction, on tente tous les pas possibles tant qu'on reste dans la grille
			for direction in directions {
				var step = 1
				while true {
					let newRow = currentPos.row + direction.dy * step
					let newCol = currentPos.col + direction.dx * step
					
						// Sortir si la nouvelle position est hors grille
					if newRow < 0 || newRow >= rows || newCol < 0 || newCol >= columns {
						break
					}
					
						// On évite de réutiliser une cellule déjà présente dans le chemin
					if path.contains(where: { $0.row == newRow && $0.col == newCol }) {
						step += 1
						continue
					}
					
					candidates.append((row: newRow, col: newCol))
					step += 1
				}
			}
			
				// Mélange aléatoire des candidats pour varier les solutions
			candidates.shuffle()
			
			for candidate in candidates {
					// Vérification pour empêcher de revenir sur le chemin (retour immédiat)
				if path.count >= 2 {
					let last = path.last!
					let previous = path[path.count - 2]
					let previousMove = (row: last.row - previous.row, col: last.col - previous.col)
					let candidateMove = (row: candidate.row - last.row, col: candidate.col - last.col)
						// Si le mouvement candidat est exactement l'inverse du dernier mouvement, on l'ignore
					if candidateMove.row == -previousMove.row && candidateMove.col == -previousMove.col {
						continue
					}
				}
				
					// Vérifier si l'ajout du candidat crée une intersection avec le chemin existant
				if causesIntersection(path: path, candidate: candidate) {
					continue
				}
				
				var newPath = path
				newPath.append(candidate)
				
				if let result = backtrack(index: index + 1, currentPos: candidate, path: newPath) {
					return result
				}
			}
			
			return nil
		}
		
			// Sélection d'une cellule de départ aléatoire
		var solutionPath: [(row: Int, col: Int)]? = nil
		var startingCells = [(row: Int, col: Int)]()
		for row in 0..<rows {
			for col in 0..<columns {
				startingCells.append((row: row, col: col))
			}
		}
		startingCells.shuffle()
		
		for start in startingCells {
			if let path = backtrack(index: 1, currentPos: start, path: [start]) {
				solutionPath = path
				break
			}
		}
		
		guard let validPath = solutionPath else {
			print("Aucune configuration valide trouvée pour le mot solution")
			return nil
		}
		
			// Placement des lettres du mot solution dans la grille suivant le chemin trouvé
		for (i, pos) in validPath.enumerated() {
			grid[pos.row][pos.col] = letters[i]
		}
		
			// Remplissage des autres cellules avec des lettres aléatoires
		for row in 0..<rows {
			for col in 0..<columns {
				if grid[row][col] == " " {
					grid[row][col] = alphabet.randomElement()!
				}
			}
		}
		
		var bonus:IndexPath? = nil
		
		if Double.random(in: 0...1) < Game.BonusRate {
			var candidateCells = [(row: Int, col: Int)]()
			for row in 0..<rows {
				for col in 0..<columns {
					if !validPath.contains(where: { $0.row == row && $0.col == col }) {
						candidateCells.append((row: row, col: col))
					}
				}
			}
			if let bonusCell = candidateCells.randomElement() {
				
				bonus = .init(row: bonusCell.row, section: bonusCell.col)
				grid[bonusCell.row][bonusCell.col] = " "
			}
		}
		
			// Calcul des positions (centres) pour l'affichage du tracé
		let letterPositions = validPath.map { CGPoint(x: CGFloat($0.col) + 0.5, y: CGFloat($0.row) + 0.5) }
		
		return (grid: grid, positions: letterPositions, bonus: bonus)
	}
	
	private func lineSegmentsIntersect(_ p1: CGPoint, _ p2: CGPoint, _ q1: CGPoint, _ q2: CGPoint) -> Bool {
		
		let epsilon: CGFloat = 0.001
		let r = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
		let s = CGPoint(x: q2.x - q1.x, y: q2.y - q1.y)
		
		let rxs = r.x * s.y - r.y * s.x
		
		if abs(rxs) < epsilon {
			
			let qp = CGPoint(x: q1.x - p1.x, y: q1.y - p1.y)
			let cross = qp.x * r.y - qp.y * r.x
			
			if abs(cross) < epsilon {
				
				let rDotr = r.x * r.x + r.y * r.y
				
				if rDotr < epsilon { return false }
				
				let t0 = ((q1.x - p1.x) * r.x + (q1.y - p1.y) * r.y) / rDotr
				let t1 = t0 + ((s.x * r.x + s.y * r.y) / rDotr)
				let tmin = min(t0, t1)
				let tmax = max(t0, t1)
				
				if tmax < 0 || tmin > 1 {
					
					return false
				}
				
				return true
			}
			
			return false
		}
		else {
			
			let qp = CGPoint(x: q1.x - p1.x, y: q1.y - p1.y)
			let t = (qp.x * s.y - qp.y * s.x) / rxs
			let u = (qp.x * r.y - qp.y * r.x) / rxs
			
			return (t >= -epsilon && t <= 1 + epsilon) && (u >= -epsilon && u <= 1 + epsilon)
		}
	}
	
	private func isSelfIntersecting(path: UIBezierPath) -> Bool {
		
		var pts = path.flattenedPoints
		
		guard pts.count > 1 else { return false }
		
		let minDistance: CGFloat = 5.0
		var simplified = [CGPoint]()
		simplified.append(pts.first ?? .zero)
		
		for i in 1..<pts.count {
			
			let dist = hypot(pts[i].x - simplified.last!.x, pts[i].y - simplified.last!.y)
			
			if dist > minDistance {
				
				simplified.append(pts[i])
			}
		}
		
		pts = simplified
		
		guard pts.count >= 2 else { return false }
		
		let segmentCount = pts.count - 1
		
		for i in 0..<segmentCount {
			
			let p1 = pts[i]
			let p2 = pts[i + 1]
			
			for j in i + 1..<segmentCount {
				
				let q1 = pts[j]
				let q2 = pts[j + 1]
				
				if j == i + 1 {
					
					if abs(p1.x - q2.x) < 0.001 && abs(p1.y - q2.y) < 0.001 && abs(p2.x - q1.x) < 0.001 && abs(p2.y - q1.y) < 0.001 {
						
						return true
					}
					
					continue
				}
				
				if lineSegmentsIntersect(p1, p2, q1, q2) {
					
					return true
				}
			}
		}
		
		return false
	}
	
	public func showSolution() {
		
		showFirst = true
		
		let solutionPath = UIBezierPath()
		guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
			  let positions = grid?.positions else { return }
		
		let totalSpacingX = layout.sectionInset.left + layout.sectionInset.right + (layout.minimumInteritemSpacing * CGFloat(columns - 1))
		let cellWidth = (collectionView.frame.width - totalSpacingX) / CGFloat(columns)
		let totalSpacingY = layout.sectionInset.top + layout.sectionInset.bottom + (layout.minimumLineSpacing * CGFloat(rows - 1))
		let cellHeight = (collectionView.frame.height - totalSpacingY) / CGFloat(rows)
		
			// Conversion des positions en indices et centres
		var validIndices: [(row: Int, col: Int)] = []
		var validCenters: [CGPoint] = []
		for point in positions {
			let col = Int(point.x - 0.5)
			let row = Int(point.y - 0.5)
			validIndices.append((row: row, col: col))
			let center = CGPoint(
				x: layout.sectionInset.left + CGFloat(col) * (cellWidth + layout.minimumInteritemSpacing) + cellWidth / 2,
				y: layout.sectionInset.top + CGFloat(row) * (cellHeight + layout.minimumLineSpacing) + cellHeight / 2
			)
			validCenters.append(center)
		}
		
			// Filtrer pour ne garder qu'une seule occurrence par cellule
		var uniqueIndices: [(row: Int, col: Int)] = []
		var uniqueCenters: [CGPoint] = []
		for (i, idx) in validIndices.enumerated() {
			if !uniqueIndices.contains(where: { $0.row == idx.row && $0.col == idx.col }) {
				uniqueIndices.append(idx)
				uniqueCenters.append(validCenters[i])
			}
		}
		
			// Insertion du bonus dans le chemin si présent et si la cellule bonus n'a pas déjà été utilisée
		if let bonusIndexPath = grid?.bonus {
			let bonusIndex = (row: bonusIndexPath.row, col: bonusIndexPath.section)
			let bonusCenter = CGPoint(
				x: layout.sectionInset.left + CGFloat(bonusIndex.col) * (cellWidth + layout.minimumInteritemSpacing) + cellWidth / 2,
				y: layout.sectionInset.top + CGFloat(bonusIndex.row) * (cellHeight + layout.minimumLineSpacing) + cellHeight / 2
			)
			func isAllowedMove(from: (row: Int, col: Int), to: (row: Int, col: Int)) -> Bool {
				let dr = abs(to.row - from.row)
				let dc = abs(to.col - from.col)
				return (dr == 0 || dc == 0 || dr == dc)
			}
			var bestInsertionIndex: Int? = nil
			var minExtraDistance = CGFloat.greatestFiniteMagnitude
			for i in 0..<uniqueIndices.count - 1 {
				let from = uniqueIndices[i]
				let to = uniqueIndices[i+1]
				if !isAllowedMove(from: from, to: bonusIndex) || !isAllowedMove(from: bonusIndex, to: to) {
					continue
				}
				let directDistance = CGFloat(max(abs(to.row - from.row), abs(to.col - from.col)))
				let d1 = CGFloat(max(abs(bonusIndex.row - from.row), abs(bonusIndex.col - from.col)))
				let d2 = CGFloat(max(abs(to.row - bonusIndex.row), abs(to.col - bonusIndex.col)))
				let extra = (d1 + d2) - directDistance
				if extra < minExtraDistance {
					minExtraDistance = extra
					bestInsertionIndex = i + 1
				}
			}
			if let insertionIndex = bestInsertionIndex,
			   !uniqueIndices.contains(where: { $0.row == bonusIndex.row && $0.col == bonusIndex.col }) {
				uniqueIndices.insert(bonusIndex, at: insertionIndex)
				uniqueCenters.insert(bonusCenter, at: insertionIndex)
			}
		}
		
			// Construction du chemin interpolé (mouvement cellule par cellule)
		var interpolatedCenters: [CGPoint] = []
		func centerForIndex(_ index: (row: Int, col: Int)) -> CGPoint {
			return CGPoint(
				x: layout.sectionInset.left + CGFloat(index.col) * (cellWidth + layout.minimumInteritemSpacing) + cellWidth / 2,
				y: layout.sectionInset.top + CGFloat(index.row) * (cellHeight + layout.minimumLineSpacing) + cellHeight / 2
			)
		}
		for i in 0..<uniqueIndices.count - 1 {
			let start = uniqueIndices[i]
			let end = uniqueIndices[i+1]
			if i == 0 {
				interpolatedCenters.append(centerForIndex(start))
			}
			let dr = end.row - start.row
			let dc = end.col - start.col
			let steps = max(abs(dr), abs(dc))
			let stepRow = dr != 0 ? dr / steps : 0
			let stepCol = dc != 0 ? dc / steps : 0
			for s in 1...steps {
				let intermediate = (row: start.row + s * stepRow, col: start.col + s * stepCol)
				if !interpolatedCenters.contains(where: { abs(centerForIndex(intermediate).x - $0.x) < 0.1 && abs(centerForIndex(intermediate).y - $0.y) < 0.1 }) {
					interpolatedCenters.append(centerForIndex(intermediate))
				}
			}
		}
		
			// Construction du UIBezierPath
		for (index, center) in interpolatedCenters.enumerated() {
			if index == 0 {
				solutionPath.move(to: center)
			} else {
				solutionPath.addLine(to: center)
			}
		}
		solutionPathLayer.path = solutionPath.cgPath
		let animation = CABasicAnimation(keyPath: "strokeEnd")
		animation.fromValue = 0.0
		animation.toValue = 1.0
		animation.duration = 0.1 * Double(solutionWord?.count ?? 0)
		animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		solutionPathLayer.strokeEnd = 1.0
		solutionPathLayer.add(animation, forKey: "strokeEnd")
		CATransaction.commit()
	}


	private func hideSolution() {
		
		if solutionPathLayer.strokeEnd != 0 {
			
			let animation = CABasicAnimation(keyPath: "strokeEnd")
			animation.fromValue = 1.0
			animation.toValue = 0.0
			animation.duration = 0.1 * Double(solutionWord?.count ?? 0)
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			solutionPathLayer.strokeEnd = 0.0
			solutionPathLayer.add(animation, forKey: "strokeEndReverse")
			CATransaction.commit()
		}
	}
	
	public func updateScore() {
		
		scoreButton.title = "\(game?.score ?? 0)"
		scoreButton.pulse()
		
		let bonus = UserDefaults.get(.userBonus) as? Int ?? 0
		
		helpButton.badge = bonus > 0 ? "\(bonus)" : nil
		
		if bonus > 0 {
			
			helpButton.pulse()
		}
	}
	
	private func processPanGesture(at location: CGPoint) {
		
		if let indexPath = collectionView.indexPathForItem(at: location), let cell = collectionView.cellForItem(at: indexPath) as? LL_Grid_Letter_CollectionViewCell, let word = solutionWord?.lowercased(), currentSolutionIndex < word.count {
			
			let expectedLetter = word[word.index(word.startIndex, offsetBy: currentSolutionIndex)]
			
			if !cell.isSelected && cell.letter?.lowercased() != String(expectedLetter) && usedIndexPaths.last != indexPath {
				
				LL_Audio.shared.play(.button)
				UIApplication.feedBack(.Off)
			}
			
			if usedIndexPaths.last != indexPath {
				
				let center = cell.superview?.convert(cell.center, to: collectionView) ?? CGPoint.zero
				
				if usedIndexPaths.isEmpty {
					
					userPath.move(to: center)
				}
				else {
					
					userPath.addLine(to: center)
				}
				
				userPathLayer.path = userPath.cgPath
				
				let row = indexPath.item / columns
				let col = indexPath.item % columns
				let lc_indexPath = IndexPath(row: row, section: col)
				
				if let bonus = grid?.bonus, lc_indexPath == bonus, !usedIndexPaths.compactMap({
					
					let row = $0.item / columns
					let col = $0.item % columns
					let indexPath = IndexPath(row: row, section: col)
					
					return indexPath
					
				}).contains(bonus) && canAddMorePoint {
					
					LL_Audio.shared.play(.bonus)
					UIApplication.feedBack(.Success)
				}
				
				usedIndexPaths.append(indexPath)
			}
			
			if isSelfIntersecting(path: userPath) && !isGameOver {
				
				fail(reason: String(key: "game.fail.reason.intersect"))
				
				return
			}
			
			if cell.isSelected {
				
				if let lastSelected = lastSelectedIndexPath, lastSelected == indexPath {
					
				}
				else if !isGameOver {
					
					fail(reason: String(key: "game.fail.reason.sameLetter"))
					
					return
				}
			}
			
			if !cell.isSelected {
				
				if cell.letter?.lowercased() == String(expectedLetter) {
					
					cell.isSelected = true
					wordStackView.select(expectedLetter)
					lastSelectedIndexPath = indexPath
					currentSolutionIndex += 1
					
					if currentSolutionIndex == word.count && canAddMorePoint {
						
						success()
					}
				}
			}
		}
	}
	
	public func success() {
		
		panGestureRecognizer.isEnabled = false
		
		LL_Audio.shared.play(.success)
		UIApplication.feedBack(.Success)
		
		LL_Confettis.start()
		
		if let solutionWord {
			
			game?.words.append(solutionWord)
			
			if let bonus = grid?.bonus, usedIndexPaths.compactMap({
				
				let row = $0.item / columns
				let col = $0.item % columns
				let indexPath = IndexPath(row: row, section: col)
				
				return indexPath
				
			}).contains(bonus) {
				
				var bonus = UserDefaults.get(.userBonus) as? Int ?? 0
				bonus += 1
				UserDefaults.set(bonus, .userBonus)
				
				NotificationCenter.post(.updateUserBonus)
			}
			
			updateScore()
		}
		
		UIApplication.wait { [weak self] in
			
			self?.panGestureRecognizer.isEnabled = true
			self?.newWord()
		}
		
		UIApplication.wait(1.0) {
			
			LL_Confettis.stop()
		}
	}
}

extension LL_Game_ViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		return rows * columns
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LL_Grid_Letter_CollectionViewCell.identifier, for: indexPath) as! LL_Grid_Letter_CollectionViewCell
		cell.letter = ""
		
		let row = indexPath.item / columns
		let col = indexPath.item % columns
		
		if let grid = grid?.grid, row < grid.count, col < grid[row].count {
			
			UIApplication.wait(Double(indexPath.row)*0.1) { [weak self] in
				
				let state = IndexPath(row: row, section: col) == self?.grid?.bonus
				cell.letter = state ? "" : String(grid[row][col])
				cell.isFirst = self?.showFirst ?? false && grid[row][col].uppercased() == self?.solutionWord?.first?.uppercased()
				cell.isBonus = state
			}
		}
		
		return cell
	}
	
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let layout = collectionViewLayout as! UICollectionViewFlowLayout
		let totalSpacing = layout.sectionInset.left + layout.sectionInset.right + (layout.minimumInteritemSpacing * CGFloat(columns-1))
		let width = (collectionView.frame.width - totalSpacing) / CGFloat(columns)
		return CGSize(width: width, height: width)
	}
}
