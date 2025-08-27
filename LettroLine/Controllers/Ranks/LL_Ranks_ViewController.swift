//
//  LL_Ranks_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 08/08/2025.
//

import UIKit

public class LL_Ranks_ViewController : LL_ViewController {
	
	private lazy var tableView:LL_TableView = {
		
		$0.delegate = self
		$0.dataSource = self
		$0.register(LL_Ranks_TableViewCell.self, forCellReuseIdentifier: LL_Ranks_TableViewCell.identifier)
		$0.allowsSelection = false
		return $0
		
	}(LL_TableView())
	private var objects:[LL_Game.FirebaseObject]? {
		
		didSet {
			
			tableView.reloadData()
		}
	}
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		title = String(key: "ranks.title")
		
		let segmentedControl:LL_SegmentedControl = .init(items: [String(key: "ranks.classic"), String(key: "ranks.challenges.timetrial"), String(key: "ranks.challenges.moveLimit"), String(key: "ranks.challenges.noLift")])
		segmentedControl.addAction(.init(handler: { [weak self] _ in
			
			if segmentedControl.selectedSegmentIndex == 0 {
				
				LL_Game_Classic.getAll { [weak self] objects in
					
					self?.objects = objects
				}
			}
			else if segmentedControl.selectedSegmentIndex == 1 {
				
				LL_Challenges_TimeTrial_Game.getAll { [weak self] objects in
					
					self?.objects = objects
				}
			}
			else if segmentedControl.selectedSegmentIndex == 2 {
				
				LL_Challenges_MoveLimit_Game.getAll { [weak self] objects in
					
					self?.objects = objects
				}
			}
			else if segmentedControl.selectedSegmentIndex == 2 {
				
				LL_Challenges_NoLift_Game.getAll { [weak self] objects in
					
					self?.objects = objects
				}
			}
			
		}), for: .valueChanged)
		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.sendActions(for: .valueChanged)
		view.addSubview(segmentedControl)
		segmentedControl.snp.makeConstraints { make in
			
			make.top.left.right.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			
			make.top.equalTo(segmentedControl.snp.bottom).offset(UI.Margins)
			make.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
	}
}

extension LL_Ranks_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		
		return 1
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return objects?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell:LL_Ranks_TableViewCell = tableView.dequeueReusableCell(withIdentifier: LL_Ranks_TableViewCell.identifier, for: indexPath) as! LL_Ranks_TableViewCell
		cell.rank = indexPath.row + 1
		cell.object = objects?[indexPath.row]
		return cell
	}
}
