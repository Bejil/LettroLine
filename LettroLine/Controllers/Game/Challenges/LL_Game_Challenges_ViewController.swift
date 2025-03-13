//
//  LL_Game_Challenges_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 04/03/2025.
//

import Foundation

public class LL_Game_Challenges_ViewController : LL_Game_ViewController {
	
	public override var game: LL_Game {
		
		return LL_Challenges_Game.current
	}
	private var constraintButton:LL_Button = {
		
		$0.isTertiary = true
		$0.style = .solid
		$0.configuration?.contentInsets = .init(horizontal: UI.Margins, vertical: UI.Margins/2)
		$0.snp.removeConstraints()
		$0.isUserInteractionEnabled = false
		return $0
		
	}(LL_Button())
	public override var grid: (grid: [[Character]], positions: [CGPoint], bonus: IndexPath?)? {
		
		didSet {
			
			updateConstraintsButton()
		}
	}
	public override var usedIndexPaths: Array<IndexPath> {
		
		didSet {
			
			updateConstraintsButton()
		}
	}
	
	public func updateConstraintsButton() {
		
		let count = minimumCellsCount() - (!usedIndexPaths.isEmpty ? usedIndexPaths.count : 0)
		
		if count >= 0 {
			
			constraintButton.title = "\(count)" + String(key: "game.challenges.remaining")
		}
		else {
			
			fail(reason: String(key: "game.challenges.fail.alert.content"))
		}
		
		canAddMorePoint = count >= 0
	}
	
	public override func loadView() {
		
		super.loadView()
		
		title = String(key: "game.challenges.title")
		
		scoreStackView.insertArrangedSubview(constraintButton, at: 1)
	}
	
	private func minimumCellsCount() -> Int {
		
		if let positions = grid?.positions {
			
			let validPath: [(row: Int, col: Int)] = positions.map { point in
				let col = Int(point.x - 0.5)
				let row = Int(point.y - 0.5)
				return (row: row, col: col)
			}
			
			var count = 1
			
			for i in 0..<validPath.count - 1 {
				
				let current = validPath[i]
				let next = validPath[i+1]
				let deltaRow = abs(next.row - current.row)
				let deltaCol = abs(next.col - current.col)
				count += max(deltaRow, deltaCol)
			}
			
			if let bonus = grid?.bonus {
				
				let bonusCell = (row: bonus.row, col: bonus.section)
				var minExtra = Int.max
				
				for i in 0..<validPath.count - 1 {
					
					let p = validPath[i]
					let q = validPath[i+1]
					
					let dWithout = max(abs(q.row - p.row), abs(q.col - p.col))
					
					let d1 = max(abs(bonusCell.row - p.row), abs(bonusCell.col - p.col))
					let d2 = max(abs(q.row - bonusCell.row), abs(q.col - bonusCell.col))
					let dWith = d1 + d2
					
					let extra = dWith - dWithout
					
					if extra < minExtra {
						
						minExtra = extra
					}
				}
				
				count += minExtra
			}
			
			return count
		}
		
		return 0
	}
	
	public override func dismiss(_ completion: (() -> Void)? = nil) {
		
		super.dismiss(completion)
		
		if (UserDefaults.get(.challengesBestScore) as? Int) ?? 0 < game.score {
			
			UserDefaults.set(game.score, .challengesBestScore)
		}
	}
	
	public override func updateScore() {
		
		super.updateScore()
		
		isBestScore = (UserDefaults.get(.challengesBestScore) as? Int) ?? 0 < game.score
	}
}
