//
//  LL_Grid_CollectionView.swift
//  LettroLine
//
//  Created by BLIN Michael on 12/02/2025.
//

import UIKit

public class LL_Grid_CollectionView : LL_CollectionView {
	
	private var usedIndexPaths: Array<IndexPath> = []
	private var lastSelectedIndexPath: IndexPath?
	public var allowFingerLift: Bool = false
	public var showFirst:Bool = false {
		
		didSet {
			
			indexPathsForVisibleItems.forEach({
				
				if let cell = cellForItem(at: $0) as? LL_Grid_Letter_CollectionViewCell {
					
					let row = $0.item / columns
					let col = $0.item % columns
					
					if let grid = grid?.grid, row < grid.count, col < grid[row].count {
						
						cell.isFirst = showFirst && grid[row][col].uppercased() == solutionWord?.first?.uppercased()
					}
				}
			})
		}
	}
	private var isGameOver = false
	public var successHanlder:(()->Void)?
	public var failureHanlder:((String?)->Void)?
	public var selectionHanlder:((Character?)->Void)?
	public var deselectionHanlder:(()->Void)?
	private var grid: (grid: [[Character]], positions: [CGPoint])? {
		
		didSet {
			
			reloadData()
		}
	}
	public var columns: Int = 5 {
		
		didSet {
			
			reloadData()
		}
	}
	public var rows: Int = 5 {
		
		didSet {
			
			reloadData()
		}
	}
	public var solutionWord: String? {
		
		didSet {
			
			resetGame()
			
			grid = generateGrid()
		}
	}
	private var currentSolutionIndex: Int = 0
	private lazy var userPathLayer:CAShapeLayer = {
		
		$0.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
		$0.lineWidth = 1.5*UI.Margins
		$0.fillColor = UIColor.clear.cgColor
		$0.lineCap = .round
		$0.lineJoin = .round
		return $0
		
	}(CAShapeLayer())
	private var userPath = UIBezierPath()
	private lazy var solutionPathLayer:CAShapeLayer = {
		
		$0.strokeColor = Colors.Primary.withAlphaComponent(0.5).cgColor
		$0.lineWidth = 1.5*UI.Margins
		$0.fillColor = UIColor.clear.cgColor
		$0.lineCap = .round
		$0.lineJoin = .round
		return $0
		
	}(CAShapeLayer())
	
	public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		
		super.init(frame: frame, collectionViewLayout: layout)
		
		register(LL_Grid_Letter_CollectionViewCell.self, forCellWithReuseIdentifier: LL_Grid_Letter_CollectionViewCell.identifier)
		
		delegate = self
		dataSource = self
		allowsSelection = false
		clipsToBounds = false
		isHeightDynamic = true
		
		let panGestureRecognizer = UIPanGestureRecognizer { [weak self] gestureRecognizer in
			
			if let self, let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
				
				let location = gestureRecognizer.location(in: self)
				
				switch gestureRecognizer.state {
					
				case .began:
					
					self.userPath.removeAllPoints()
					self.usedIndexPaths.removeAll()
					self.currentSolutionIndex = 0
					
					for cell in self.visibleCells {
						
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
					
					if !self.bounds.contains(location) {
						
						if !isGameOver {
							
							self.fail(reason: String(key: "game.fail.reason.outOfBounds"))
							
							return
						}
					}
					
					if let indexPath = self.indexPathForItem(at: location), let cell = self.cellForItem(at: indexPath) as? LL_Grid_Letter_CollectionViewCell, let word = self.solutionWord?.lowercased(), self.currentSolutionIndex < word.count {
						
						let expectedLetter = word[word.index(word.startIndex, offsetBy: self.currentSolutionIndex)]
						
						if !cell.isSelected && cell.letter?.lowercased() != String(expectedLetter) && self.usedIndexPaths.last != indexPath {
							
							LL_Audio.shared.playButton()
							UIApplication.feedBack(.Off)
						}
						
						if self.usedIndexPaths.last != indexPath {
							
							let center = cell.superview?.convert(cell.center, to: self) ?? CGPoint.zero
							
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
								self.selectionHanlder?(expectedLetter)
								self.lastSelectedIndexPath = indexPath
								self.currentSolutionIndex += 1
								
								if self.currentSolutionIndex == word.count {
									
									self.successHanlder?()
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
								self.currentSolutionIndex = 0
								
								for cell in self.visibleCells {
									
									cell.isSelected = false
								}
								
								self.showFirst = self.showFirst
								
								self.userPathLayer.path = nil
								self.deselectionHanlder?()
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
					
				default:
					
					break
				}
			}
		}
		addGestureRecognizer(panGestureRecognizer)
		
		layer.addSublayer(solutionPathLayer)
		layer.addSublayer(userPathLayer)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
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
		
		delegate = nil
		delegate = self
		
		isGameOver = true
		failureHanlder?(reason)
		
		UIView.animation { [weak self] in
			
			self?.userPathLayer.opacity = 0.0
		}
	}
	
	private func generateGrid() -> (grid: [[Character]], positions: [CGPoint])? {
		let alphabet = Array("abcdefghijklmnopqrstuvwxyz")
			// Initialisation de la grille avec des espaces
		var grid = Array(repeating: Array(repeating: Character(" "), count: columns), count: rows)
		
			// Vérification du mot solution
		guard let solution = solutionWord?.lowercased(), !solution.isEmpty else { return nil }
		let letters = Array(solution)
		
			// Les 8 directions autorisées
		let directions: [(dx: Int, dy: Int)] = [
			(-1, -1), (-1,  0), (-1,  1),
			( 0, -1),          ( 0,  1),
			( 1, -1), ( 1,  0), ( 1,  1)
		]
		
			// Fonction utilitaire : retourne le centre d'une cellule
		func centerPoint(for row: Int, col: Int) -> CGPoint {
			return CGPoint(x: CGFloat(col) + 0.5, y: CGFloat(row) + 0.5)
		}
		
			// Vérifie que le segment allant du dernier point du chemin au candidat n'intersecte aucun segment précédent.
		func causesIntersection(path: [(row: Int, col: Int)], candidate: (row: Int, col: Int)) -> Bool {
			let newStart = centerPoint(for: path.last!.row, col: path.last!.col)
			let newEnd = centerPoint(for: candidate.row, col: candidate.col)
				// S'il y a moins de 3 points, il ne peut pas y avoir d'intersection.
			if path.count < 3 { return false }
				// On vérifie chaque segment déjà défini (sauf le dernier qui partage le point de départ)
			for i in 0..<(path.count - 2) {
				let p1 = centerPoint(for: path[i].row, col: path[i].col)
				let p2 = centerPoint(for: path[i+1].row, col: path[i+1].col)
				if lineSegmentsIntersect(p1, p2, newStart, newEnd) {
					return true
				}
			}
			return false
		}
		
			// Fonction récursive de backtracking pour placer les lettres à partir de l'index donné.
		func backtrack(index: Int, currentPos: (row: Int, col: Int), path: [(row: Int, col: Int)]) -> [(row: Int, col: Int)]? {
			if index == letters.count {
				return path
			}
			var candidates = [(row: Int, col: Int)]()
				// Pour chaque direction, on tente tous les pas possibles tant qu'on reste dans la grille.
			for direction in directions {
				var step = 1
				while true {
					let newRow = currentPos.row + direction.dy * step
					let newCol = currentPos.col + direction.dx * step
					if newRow < 0 || newRow >= rows || newCol < 0 || newCol >= columns {
						break // On sort si on dépasse la grille
					}
						// Éviter de réutiliser une cellule déjà utilisée par le mot solution.
					if path.contains(where: { $0.row == newRow && $0.col == newCol }) {
						step += 1
						continue
					}
					candidates.append((row: newRow, col: newCol))
					step += 1
				}
			}
				// Mélange des candidats pour ajouter un peu d'aléatoire
			candidates.shuffle()
			for candidate in candidates {
					// On vérifie qu'ajouter ce candidat ne crée pas d'intersection
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
		
			// On essaie des positions de départ aléatoires pour le premier caractère.
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
		
			// Placement des lettres du mot solution dans la grille selon le chemin trouvé.
		for (i, pos) in validPath.enumerated() {
			grid[pos.row][pos.col] = letters[i]
		}
		
			// Remplissage des autres cellules avec des lettres aléatoires.
		for row in 0..<rows {
			for col in 0..<columns {
				if grid[row][col] == " " {
					grid[row][col] = alphabet.randomElement()!
				}
			}
		}
		
			// Calcul des positions sous forme de centres (pour le dessin du tracé, par exemple).
		let letterPositions = validPath.map { CGPoint(x: CGFloat($0.col) + 0.5, y: CGFloat($0.row) + 0.5) }
		
		return (grid: grid, positions: letterPositions)
	}

	private func lineSegmentsIntersect(_ p1: CGPoint, _ p2: CGPoint, _ q1: CGPoint, _ q2: CGPoint) -> Bool {
		let epsilon: CGFloat = 0.001
		let r = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
		let s = CGPoint(x: q2.x - q1.x, y: q2.y - q1.y)
		
		let rxs = r.x * s.y - r.y * s.x
		
			// Si rxs est pratiquement nul, les segments sont parallèles ou colinéaires
		if abs(rxs) < epsilon {
				// Vérifier la colinéarité : le vecteur (q1 - p1) doit être colinéaire à r
			let qp = CGPoint(x: q1.x - p1.x, y: q1.y - p1.y)
			let cross = qp.x * r.y - qp.y * r.x
			if abs(cross) < epsilon {
					// Les segments sont colinéaires. On vérifie alors s'ils se recouvrent.
					// On projette sur r (en utilisant le produit scalaire)
				let rDotr = r.x * r.x + r.y * r.y
				if rDotr < epsilon { return false } // segment nul
				let t0 = ((q1.x - p1.x) * r.x + (q1.y - p1.y) * r.y) / rDotr
				let t1 = t0 + ((s.x * r.x + s.y * r.y) / rDotr)
				let tmin = min(t0, t1)
				let tmax = max(t0, t1)
					// Les segments se recouvrent s'il y a un intervalle commun à [0,1]
				if tmax < 0 || tmin > 1 {
					return false
				}
				return true
			}
			return false
		} else {
			let qp = CGPoint(x: q1.x - p1.x, y: q1.y - p1.y)
			let t = (qp.x * s.y - qp.y * s.x) / rxs
			let u = (qp.x * r.y - qp.y * r.x) / rxs
			return (t >= -epsilon && t <= 1 + epsilon) && (u >= -epsilon && u <= 1 + epsilon)
		}
	}
	
	private func isSelfIntersecting(path: UIBezierPath) -> Bool {
		var pts = path.flattenedPoints
		guard pts.count > 1 else { return false }
		
			// Simplification pour éviter des micro-segments
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
			// Parcours de toutes les paires de segments (même adjacents)
		for i in 0..<segmentCount {
			let p1 = pts[i]
			let p2 = pts[i + 1]
			for j in i + 1..<segmentCount {
				let q1 = pts[j]
				let q2 = pts[j + 1]
				
				if j == i + 1 {
						// Cas particulier : segments adjacents.
						// Normalement, ils se rejoignent en un point, ce qui n'est pas une intersection.
						// Mais si le segment suivant revient exactement sur le précédent, c'est une intersection.
					if abs(p1.x - q2.x) < 0.001 && abs(p1.y - q2.y) < 0.001 &&
						abs(p2.x - q1.x) < 0.001 && abs(p2.y - q1.y) < 0.001 {
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
		
			// Conversion des positions de grille en positions dans la vue.
		if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout, let positions = grid?.positions {
			
			let totalSpacingX = layout.sectionInset.left + layout.sectionInset.right + (layout.minimumInteritemSpacing * CGFloat(columns - 1))
			let cellWidth = (self.frame.width - totalSpacingX) / CGFloat(columns)
			
			let totalSpacingY = layout.sectionInset.top + layout.sectionInset.bottom + (layout.minimumLineSpacing * CGFloat(rows - 1))
			let cellHeight = (self.frame.height - totalSpacingY) / CGFloat(rows)
			
			for (index, point) in positions.enumerated() {
					// Les positions retournées sont au format (col + 0.5, row + 0.5)
				let col = point.x - 0.5
				let row = point.y - 0.5
				
					// Calcul du centre de la cellule
				let x = layout.sectionInset.left + col * (cellWidth + layout.minimumInteritemSpacing) + cellWidth / 2
				let y = layout.sectionInset.top + row * (cellHeight + layout.minimumLineSpacing) + cellHeight / 2
				let cellCenter = CGPoint(x: x, y: y)
				
				if index == 0 {
					solutionPath.move(to: cellCenter)
				} else {
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
}

extension LL_Grid_CollectionView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
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
