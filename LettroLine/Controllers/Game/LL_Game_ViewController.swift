//
//  LL_Game_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 11/02/2025.
//

import UIKit
import SnapKit

public class LL_Game_ViewController: LL_ViewController {
	
	private lazy var usedIndexPaths: Array<IndexPath> = []
	private var lastSelectedIndexPath: IndexPath?
	private lazy var allowFingerLift: Bool = UserDefaults.get(.allowFingerLift) as? Bool ?? false
	private lazy var showFirst:Bool = UserDefaults.get(.showFirstLetter) as? Bool ?? false {
		
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
	private var grid: (grid: [[Character]], positions: [CGPoint])? {
		
		didSet {
			
			collectionView.reloadData()
		}
	}
	private lazy var columns: Int = 5
	private lazy var rows: Int = 5
	private var solutionWord: String? {
		
		didSet {
			
			resetGame()
			
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
	private lazy var scoreButton:LL_Button = {
		
		$0.configuration?.contentInsets = .init(horizontal: UI.Margins, vertical: UI.Margins/2)
		$0.snp.removeConstraints()
		return $0
		
	}(LL_Button() { _ in
		
		if LL_Game.current.score != 0 {
				
			let alertController:LL_Alert_ViewController = .init()
			alertController.title = String(key: "game.words.alert.title")
			
			LL_Game.current.words.forEach {
				
				alertController.add($0.uppercased())
			}
			
			alertController.addDismissButton(sticky: true)
			alertController.present(as: .Sheet)
		}
	})
	private lazy var wordStackView:LL_Word_StackView = .init()
	private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
		
		$0.scrollDirection = .vertical
		$0.sectionInset = .init(horizontal: UI.Margins)
		$0.minimumInteritemSpacing = UI.Margins
		$0.minimumLineSpacing = UI.Margins
		return $0
		
	}(UICollectionViewFlowLayout())
	private lazy var collectionView: LL_CollectionView = {
		
		$0.register(LL_Grid_Letter_CollectionViewCell.self, forCellWithReuseIdentifier: LL_Grid_Letter_CollectionViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		$0.allowsSelection = false
		$0.clipsToBounds = false
		$0.isHeightDynamic = true
		
		let panGestureRecognizer = UIPanGestureRecognizer { [weak self] gestureRecognizer in
			
			if let self, let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
				
				let location = gestureRecognizer.location(in: self.collectionView)
				
				switch gestureRecognizer.state {
					
				case .began:
					
					self.userPath.removeAllPoints()
					self.usedIndexPaths.removeAll()
					self.currentSolutionIndex = 0
					
					for cell in self.collectionView.visibleCells {
						
						cell.isSelected = false
					}
					
					self.userPathLayer.removeAllAnimations()
					self.userPathLayer.strokeEnd = 1.0
					
					UIView.animation {
						
						self.userPathLayer.opacity = 1.0
					}
					
				case .changed:
					
					if isGameOver {
						
						return
					}
					
					if !self.collectionView.bounds.contains(location) {
						
						if !isGameOver {
							
							self.fail(reason: String(key: "game.fail.reason.outOfBounds"))
							
							return
						}
					}
					
					if let indexPath = self.collectionView.indexPathForItem(at: location), let cell = self.collectionView.cellForItem(at: indexPath) as? LL_Grid_Letter_CollectionViewCell, let word = self.solutionWord?.lowercased(), self.currentSolutionIndex < word.count {
						
						let expectedLetter = word[word.index(word.startIndex, offsetBy: self.currentSolutionIndex)]
						
						if !cell.isSelected && cell.letter?.lowercased() != String(expectedLetter) && self.usedIndexPaths.last != indexPath {
							
							LL_Audio.shared.playButton()
							UIApplication.feedBack(.Off)
						}
						
						if self.usedIndexPaths.last != indexPath {
							
							let center = cell.superview?.convert(cell.center, to: self.collectionView) ?? CGPoint.zero
							
							if self.usedIndexPaths.isEmpty {
								
								self.userPath.move(to: center)
							}
							else {
								
								self.userPath.addLine(to: center)
							}
							self.userPathLayer.path = self.userPath.cgPath
							
							self.usedIndexPaths.append(indexPath)
						}
						
						if self.isSelfIntersecting(path: self.userPath) && !isGameOver {
							
							self.fail(reason: String(key: "game.fail.reason.intersect"))
							
							return
						}
						
						if cell.isSelected {
							
							if let lastSelected = self.lastSelectedIndexPath, lastSelected == indexPath {
								
							} else if !isGameOver {
								
								self.fail(reason: String(key: "game.fail.reason.sameLetter"))
								
								return
							}
						}
						
						if !cell.isSelected {
							
							if cell.letter?.lowercased() == String(expectedLetter) {
								
								cell.isSelected = true
								self.wordStackView.select(expectedLetter)
								self.lastSelectedIndexPath = indexPath
								self.currentSolutionIndex += 1
								
								if self.currentSolutionIndex == word.count {
									
									LL_Audio.shared.playSuccess()
									UIApplication.feedBack(.Success)

									LL_Confettis.start()

									if let solutionWord = self.solutionWord {
										
										LL_Game.current.add(solutionWord)
										
										self.updateScore()
									}

									UIApplication.wait { [weak self] in

										self?.newWord()
									}

									UIApplication.wait(1.0) { [weak self] in

										LL_Confettis.stop()
									}
								}
							}
						}
					}
					
				case .ended, .cancelled:
					
					if self.allowFingerLift {
						
						UIApplication.feedBack(.Off)
						
						self.userPathLayer.removeAnimation(forKey: "strokeEndReverse")
						
						CATransaction.begin()
						CATransaction.setCompletionBlock { [weak self] in
							
							if let self {
								
								self.userPath.removeAllPoints()
								self.usedIndexPaths.removeAll()
								
								for cell in self.collectionView.visibleCells {
									
									cell.isSelected = false
								}
								
								self.showFirst = self.showFirst
								
								self.userPathLayer.path = nil
								self.wordStackView.deselectAll()
							}
						}
						
						let currentStrokeEnd = self.userPathLayer.presentation()?.strokeEnd ?? 1.0
						let animation = CABasicAnimation(keyPath: "strokeEnd")
						animation.fromValue = currentStrokeEnd
						animation.toValue = 0.0
						animation.duration = 0.1 * Double(usedIndexPaths.count)
						animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
						self.userPathLayer.strokeEnd = 0.0
						self.userPathLayer.add(animation, forKey: "strokeEndReverse")
						CATransaction.commit()
					}
					else if !isGameOver, let word = self.solutionWord?.lowercased(), self.currentSolutionIndex < word.count {
						
						self.fail(reason: String(key: "game.fail.reason.fingerLift"))
						
						return
					}
					
					break
					
				default:
					
					break
				}
			}
		}
		$0.addGestureRecognizer(panGestureRecognizer)
		
		$0.layer.addSublayer(solutionPathLayer)
		$0.layer.addSublayer(userPathLayer)
		return $0
		
	}(LL_CollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout))
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		title = String(key: "game.title")
		
		navigationItem.rightBarButtonItem = settingsButton
		
		let solutionButton:LL_Button = .init(String(key: "game.help")) { [weak self] _ in
			
			self?.showSolution()
		}
		solutionButton.isPrimary = false
		solutionButton.image = UIImage(systemName: "lightbulb.min.fill")?.applyingSymbolConfiguration(.init(scale: .small))
		solutionButton.configuration?.imagePadding = UI.Margins/2
		solutionButton.configuration?.contentInsets = .init(horizontal: UI.Margins, vertical: UI.Margins/2)
		solutionButton.snp.removeConstraints()
		
		let scoreStackView:UIStackView = .init(arrangedSubviews: [scoreButton,.init(),solutionButton])
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
		contentStackView.setCustomSpacing(3*UI.Margins, after: scoreStackView)
		
		newWord()
		
		contentStackView.animate()
		
		updateScore()
	}
	
	private func newWord() {
		
		let word = String.randomWord(withLetters: Int.random(in: 3...7))
		wordStackView.word = word
		solutionWord = word
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
	
	private func fail(reason:String?) {
		
		collectionView.delegate = nil
		collectionView.delegate = self
		
		isGameOver = true
		
		LL_Audio.shared.playError()
		UIApplication.feedBack(.Error)
		
		let alertViewController:LL_Alert_ViewController = .init()
		alertViewController.title = String(key: "game.fail.alert.title")
		alertViewController.add(reason)
		alertViewController.addDismissButton()
		alertViewController.dismissHandler = { [weak self] in
			
			LL_Game.current.reset()
			
			self?.updateScore()
			
			self?.newWord()
		}
		alertViewController.present()
		
		UIView.animation { [weak self] in
			
			self?.userPathLayer.opacity = 0.0
		}
	}
	
	private func generateGrid() -> (grid: [[Character]], positions: [CGPoint])? {
		
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
		
			// Calcul des positions (centres) pour l'affichage du tracé
		let letterPositions = validPath.map { CGPoint(x: CGFloat($0.col) + 0.5, y: CGFloat($0.row) + 0.5) }
		
		return (grid: grid, positions: letterPositions)
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
		
		let solutionPath = UIBezierPath()
		
		if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, let positions = grid?.positions {
			
			let totalSpacingX = layout.sectionInset.left + layout.sectionInset.right + (layout.minimumInteritemSpacing * CGFloat(columns - 1))
			let cellWidth = (collectionView.frame.width - totalSpacingX) / CGFloat(columns)
			
			let totalSpacingY = layout.sectionInset.top + layout.sectionInset.bottom + (layout.minimumLineSpacing * CGFloat(rows - 1))
			let cellHeight = (collectionView.frame.height - totalSpacingY) / CGFloat(rows)
			
			for (index, point) in positions.enumerated() {
				
				let col = point.x - 0.5
				let row = point.y - 0.5
				
				let x = layout.sectionInset.left + col * (cellWidth + layout.minimumInteritemSpacing) + cellWidth / 2
				let y = layout.sectionInset.top + row * (cellHeight + layout.minimumLineSpacing) + cellHeight / 2
				let cellCenter = CGPoint(x: x, y: y)
				
				if index == 0 {
					
					solutionPath.move(to: cellCenter)
				}
				else {
					
					solutionPath.addLine(to: cellCenter)
				}
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
	
	private func updateScore() {
		
		scoreButton.title = String(key: "game.score") + "\(LL_Game.current.score)"
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
				
				cell.letter = String(grid[row][col])
				cell.isFirst = self?.showFirst ?? false && grid[row][col].uppercased() == self?.solutionWord?.first?.uppercased()
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
