	//
	//  LL_Home_ViewController.swift
	//  LettroLine
	//
	//  Created by BLIN Michael on 11/02/2025.
	//

import UIKit
import SnapKit

	// MARK: - Génération de la grille

	/// Génère une grille 5×5 contenant le mot donné (en majuscules) placé aléatoirement.
	/// Les autres cellules sont remplies avec des lettres aléatoires.
	/// Renvoie la grille et, pour information, les positions (en coordonnées grille) des lettres du mot.
func generateGrid(for word: String, gridSize: Int = 5) -> (grid: [[Character]], positions: [CGPoint])? {
	let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	var grid = Array(repeating: Array(repeating: Character(" "), count: gridSize), count: gridSize)
	
		// Crée une liste de toutes les cellules (row, col)
	var allCells = [(row: Int, col: Int)]()
	for row in 0..<gridSize {
		for col in 0..<gridSize {
			allCells.append((row: row, col: col))
		}
	}
	
	var letterPositions = [CGPoint]()
		// Place chaque lettre du mot dans une cellule aléatoire
	for letter in word.uppercased() {
		if allCells.isEmpty { return nil }
		let index = Int(arc4random_uniform(UInt32(allCells.count)))
		let cell = allCells.remove(at: index)
		grid[cell.row][cell.col] = letter
			// On considère le centre de la cellule comme (col + 0.5, row + 0.5)
		letterPositions.append(CGPoint(x: CGFloat(cell.col) + 0.5, y: CGFloat(cell.row) + 0.5))
	}
	
		// Remplit les cellules restantes avec des lettres aléatoires.
	for cell in allCells {
		let randomLetter = alphabet[Int(arc4random_uniform(UInt32(alphabet.count)))]
		grid[cell.row][cell.col] = randomLetter
	}
	
	return (grid: grid, positions: letterPositions)
}

	// MARK: - LL_Home_ViewController

public class LL_Home_ViewController: LL_ViewController {
	
		// MARK: - UI Components
	
	private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		layout.sectionInset = .init(horizontal: UI.Margins)
		layout.minimumInteritemSpacing = UI.Margins
		layout.minimumLineSpacing = UI.Margins
		return layout
	}()
	
	private lazy var collectionView: LL_Grid_CollectionView = {
		let cv = LL_Grid_CollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
		cv.delegate = self
		cv.dataSource = self
		cv.allowsMultipleSelection = true
		return cv
	}()
	
		// MARK: - Propriétés de la grille et du jeu
	
		/// La grille 5×5 contenant toutes les lettres.
	private var gridData: [[Character]]?
		/// Le mot solution (exemple "BONJOUR")
	private var solutionWord: String?
		/// Index de la prochaine lettre attendue.
	private var currentSolutionIndex: Int = 0
	
		// MARK: - Tracé du chemin utilisateur
	
		/// Calque pour dessiner le tracé utilisateur
	private let userPathLayer = CAShapeLayer()
		/// UIBezierPath qui stocke le tracé courant
	private var userPath = UIBezierPath()
		/// Tableau des points du tracé (pour éventuellement étendre la détection, etc.)
	private var userPathPoints: [CGPoint] = []
	
		// MARK: - Cycle de vie
	
	public override func loadView() {
		super.loadView()
		
		title = "LettroLine"
		view.addSubview(collectionView)
		collectionView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
			// On choisit le mot à trouver
		solutionWord = "BONJOUR"
		if let result = generateGrid(for: solutionWord!) {
			gridData = result.grid
		}
		collectionView.reloadData()
		
			// Ajoute un pan gesture pour que l'utilisateur puisse tracer son chemin
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
		collectionView.addGestureRecognizer(panGesture)
		
			// Configure le calque de tracé
		userPathLayer.strokeColor = UIColor.red.cgColor
		userPathLayer.lineWidth = 3.0
		userPathLayer.fillColor = UIColor.clear.cgColor
		collectionView.layer.addSublayer(userPathLayer)
	}
	
		// MARK: - Gestion du geste
	
	@objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
		let location = gesture.location(in: collectionView)
		
		switch gesture.state {
		case .began:
				// Réinitialise le tracé et la progression.
			userPath.removeAllPoints()
			userPathPoints.removeAll()
			userPath.move(to: location)
			userPathPoints.append(location)
			currentSolutionIndex = 0
			for cell in collectionView.visibleCells {
				cell.isSelected = false
			}
			
		case .changed:
			userPath.addLine(to: location)
			userPathPoints.append(location)
			userPathLayer.path = userPath.cgPath
			
				// Vérifie si le doigt survole une cellule contenant la lettre attendue.
			if let indexPath = collectionView.indexPathForItem(at: location),
			   let cell = collectionView.cellForItem(at: indexPath) as? LL_Grid_Letter_CollectionViewCell,
			   let word = solutionWord,
			   currentSolutionIndex < word.count {
				
				let expectedLetter = word[word.index(word.startIndex, offsetBy: currentSolutionIndex)]
				if cell.letter?.uppercased() == String(expectedLetter) && !cell.isSelected {
					cell.isSelected = true
					currentSolutionIndex += 1
					
						// Si la dernière lettre est atteinte, affiche l'alerte et réinitialise le jeu.
					if currentSolutionIndex == word.count {
						let alert = UIAlertController(title: "Bravo", message: "Mot complété !", preferredStyle: .alert)
						alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
							self.resetGame()
						}))
						present(alert, animated: true, completion: nil)
						gesture.isEnabled = false
					}
				}
			}
			
		case .ended, .cancelled:
			break
			
		default:
			break
		}
	}
	
	private func resetGame() {
			// Réinitialise l'état du jeu.
		currentSolutionIndex = 0
		userPath.removeAllPoints()
		userPathPoints.removeAll()
		userPathLayer.path = nil
		
			// Réactive tous les gesture recognizers de la collectionView.
		collectionView.gestureRecognizers?.forEach { $0.isEnabled = true }
		
			// Regénère la grille et recharge la collectionView.
		if let word = solutionWord, let result = generateGrid(for: word) {
			gridData = result.grid
			collectionView.reloadData()
		}
	}
}

	// MARK: - Extensions CollectionView

extension LL_Home_ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 25 // 5x5
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LL_Grid_Letter_CollectionViewCell.identifier, for: indexPath) as! LL_Grid_Letter_CollectionViewCell
		
		let row = indexPath.item / 5
		let col = indexPath.item % 5
		if let grid = gridData, row < grid.count, col < grid[row].count {
			cell.letter = String(grid[row][col])
		} else {
			cell.letter = ""
		}
		return cell
	}
	
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let layout = collectionViewLayout as! UICollectionViewFlowLayout
		let totalSpacing = layout.sectionInset.left + layout.sectionInset.right + (layout.minimumInteritemSpacing * 4)
		let width = (collectionView.frame.width - totalSpacing) / 5
		return CGSize(width: width, height: width)
	}
}
