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
					
					if let grid = gridData, row < grid.count, col < grid[row].count {
						
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
	private var gridData: [[Character]]?
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
			
			if let result = generateGrid() {
				
				gridData = result.grid
			}
			
			reloadData()
		}
	}
	private var currentSolutionIndex: Int = 0
	private let userPathLayer = CAShapeLayer()
	private var userPath = UIBezierPath()
	
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
						animation.duration = 0.3
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
		
		userPathLayer.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
		userPathLayer.lineWidth = 1.5*UI.Margins
		userPathLayer.fillColor = UIColor.clear.cgColor
		userPathLayer.lineCap = .round
		userPathLayer.lineJoin = .round
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
		
		gridData = generateGrid()?.grid
		
		reloadData()
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
		var grid = Array(repeating: Array(repeating: Character(" "), count: columns), count: rows)
		var allCells = [(row: Int, col: Int)]()
		
		for row in 0..<rows {
			
			for col in 0..<columns {
				
				allCells.append((row: row, col: col))
			}
		}
		
		var letterPositions = [CGPoint]()
		
		for letter in solutionWord?.lowercased() ?? "" {
			
			if allCells.isEmpty {
				
				return nil
			}
			
			let index = Int(arc4random_uniform(UInt32(allCells.count)))
			let cell = allCells.remove(at: index)
			
			grid[cell.row][cell.col] = letter
			letterPositions.append(CGPoint(x: CGFloat(cell.col) + 0.5, y: CGFloat(cell.row) + 0.5))
		}
		
		for cell in allCells {
			
			let randomLetter = alphabet[Int(arc4random_uniform(UInt32(alphabet.count)))]
			grid[cell.row][cell.col] = randomLetter
		}
		
		return (grid: grid, positions: letterPositions)
	}
	
	private func lineSegmentsIntersect(_ p1: CGPoint, _ p2: CGPoint, _ q1: CGPoint, _ q2: CGPoint) -> Bool {
			// On réduit l'epsilon pour détecter même les intersections proches des extrémités
		let epsilon: CGFloat = 0.001
		let r = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
		let s = CGPoint(x: q2.x - q1.x, y: q2.y - q1.y)
		let denominator = r.x * s.y - r.y * s.x
		if abs(denominator) < epsilon {
			return false
		}
		let uNumerator = (q1.x - p1.x) * r.y - (q1.y - p1.y) * r.x
		let tNumerator = (q1.x - p1.x) * s.y - (q1.y - p1.y) * s.x
		let t = tNumerator / denominator
		let u = uNumerator / denominator
			// On considère l'intersection même si elle se trouve aux extrémités
		return (t >= 0 && t <= 1) && (u >= 0 && u <= 1)
	}
	
	private func isSelfIntersecting(path: UIBezierPath) -> Bool {
		var pts = path.flattenedPoints
		guard pts.count > 1 else { return false }
		
			// Simplification pour éviter les micro-segments
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
		guard pts.count >= 4 else { return false }
		
			// Parcours de tous les segments du tracé
		for i in 0..<(pts.count - 2) {
			let p1 = pts[i]
			let p2 = pts[i + 1]
			for j in (i + 2)..<(pts.count - 1) {
					// On ne fait plus l'exclusion du premier et de l'avant-dernier segment
				let q1 = pts[j]
				let q2 = pts[j + 1]
				if lineSegmentsIntersect(p1, p2, q1, q2) {
					return true
				}
			}
		}
		return false
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
		
		if let grid = gridData, row < grid.count, col < grid[row].count {
			
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
