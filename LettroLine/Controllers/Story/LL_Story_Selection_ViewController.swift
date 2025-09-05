//
//  LL_Story_Selection_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 14/02/2025.
//

import UIKit
import SnapKit

public class LL_Story_Selection_ViewController: LL_ViewController {
	
	private var stories:[LL_Game_Story.Story]? {
		
		didSet {
			
			collectionView.reloadData()
		}
	}
	private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
		
		$0.scrollDirection = .vertical
		$0.minimumInteritemSpacing = UI.Margins
		$0.minimumLineSpacing = UI.Margins
		$0.sectionInset = UIEdgeInsets(top: UI.Margins, left: UI.Margins, bottom: UI.Margins, right: UI.Margins)
		$0.headerReferenceSize = CGSize(width: 0, height: 3*UI.Margins)
		return $0
		
	}(UICollectionViewFlowLayout())
	private lazy var collectionView: LL_CollectionView = {
		
		$0.register(LL_Story_CollectionViewCell.self, forCellWithReuseIdentifier: LL_Story_CollectionViewCell.identifier)
		$0.register(LL_Story_Section_HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LL_Story_Section_HeaderView.identifier)
		$0.delegate = self
		$0.dataSource = self
		$0.backgroundColor = .clear
		$0.showsVerticalScrollIndicator = false
		$0.contentInset = .zero
		return $0
		
	}(LL_CollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout))
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		title = String(key: "story.title")
		
		view.addSubview(collectionView)
		collectionView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		LL_Alert_ViewController.presentLoading { [weak self] alertController in
			
			LL_Game_Story.getAll { [weak self] stories in
				
				alertController?.close()
				
				self?.stories = stories
			}
		}
		
		collectionView.reloadData()
	}
}

// MARK: - UICollectionViewDataSource

extension LL_Story_Selection_ViewController: UICollectionViewDataSource {
	
	public func numberOfSections(in collectionView: UICollectionView) -> Int {
		
		var sectionCount = 0
		
		// Compter les sections qui ont des éléments
		if (stories?.started?.count ?? 0) > 0 {
			sectionCount += 1
		}
		if (stories?.notStarted?.count ?? 0) > 0 {
			sectionCount += 1
		}
		if (stories?.finished?.count ?? 0) > 0 {
			sectionCount += 1
		}
		
		return sectionCount
	}
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		var currentSection = 0
		
		// Section "Started"
		if (stories?.started?.count ?? 0) > 0 {
			if section == currentSection {
				return stories?.started?.count ?? 0
			}
			currentSection += 1
		}
		
		// Section "Not Started"
		if (stories?.notStarted?.count ?? 0) > 0 {
			if section == currentSection {
				return stories?.notStarted?.count ?? 0
			}
			currentSection += 1
		}
		
		// Section "Finished"
		if (stories?.finished?.count ?? 0) > 0 {
			if section == currentSection {
				return stories?.finished?.count ?? 0
			}
		}
		
		return 0
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LL_Story_CollectionViewCell.identifier, for: indexPath) as! LL_Story_CollectionViewCell
		
		var currentSection = 0
		
		// Section "Started"
		if (stories?.started?.count ?? 0) > 0 {
			if indexPath.section == currentSection {
				cell.story = stories?.started?[indexPath.item].current
				return cell
			}
			currentSection += 1
		}
		
		// Section "Not Started"
		if (stories?.notStarted?.count ?? 0) > 0 {
			if indexPath.section == currentSection {
				cell.story = stories?.notStarted?[indexPath.item]
				return cell
			}
			currentSection += 1
		}
		
		// Section "Finished"
		if (stories?.finished?.count ?? 0) > 0 {
			if indexPath.section == currentSection {
				cell.story = stories?.finished?[indexPath.item].current
				return cell
			}
		}
		
		return cell
	}
	
	public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		if kind == UICollectionView.elementKindSectionHeader {
			
			let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LL_Story_Section_HeaderView.identifier, for: indexPath) as! LL_Story_Section_HeaderView
			
			var currentSection = 0
			
			// Section "Started"
			if (stories?.started?.count ?? 0) > 0 {
				if indexPath.section == currentSection {
					headerView.title = String(key: "story.section.started")
					return headerView
				}
				currentSection += 1
			}
			
			// Section "Not Started"
			if (stories?.notStarted?.count ?? 0) > 0 {
				if indexPath.section == currentSection {
					headerView.title = String(key: "story.section.notStarted")
					headerView.count = stories?.notStarted?.count ?? 0
					return headerView
				}
				currentSection += 1
			}
			
			// Section "Finished"
			if (stories?.finished?.count ?? 0) > 0 {
				if indexPath.section == currentSection {
					headerView.title = String(key: "story.section.finished")
					return headerView
				}
			}
		}
		
		return UICollectionReusableView()
	}
}

// MARK: - UICollectionViewDelegate

extension LL_Story_Selection_ViewController: UICollectionViewDelegate {
	
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		UIApplication.feedBack(.On)
		LL_Audio.shared.play(.button)
		
		var story: LL_Game_Story.Story?
		var currentSection = 0
		
		// Section "Started"
		if (stories?.started?.count ?? 0) > 0 {
			if indexPath.section == currentSection {
				story = stories?.started?[indexPath.item]
			}
			currentSection += 1
		}
		
		// Section "Not Started"
		if (stories?.notStarted?.count ?? 0) > 0 {
			if indexPath.section == currentSection {
				story = stories?.notStarted?[indexPath.item]
			}
			currentSection += 1
		}
		
		// Section "Finished"
		if (stories?.finished?.count ?? 0) > 0 {
			if indexPath.section == currentSection {
				story = stories?.finished?[indexPath.item]
			}
		}
		
		let closure:(()->Void) = { [weak self] in
			
			let viewController = LL_Game_Story_ViewController()
			viewController.story = story?.current
			self?.navigationController?.pushViewController(viewController, animated: true)
		}
		
		if let story, story.current != nil {
			
			let alertController:LL_Alert_ViewController = .init()
			alertController.title = story.title
			alertController.add(story.subtitle)
			
			if story.current?.isFinished ?? false {
				
				alertController.addButton(title: String(key: "story.read.button.title")) { _ in
					
					alertController.close {
						
						var items:[LL_Tutorial_ViewController.Item] = .init()
						
						for i in 0..<(story.chapters?.count ?? 0) {
							
							if let chapter = story.chapters?[i] {
								
								items.append(.init(
									title: (chapter.title ?? "") + "\n\n" + String(key: "story.read.chapter") + " \(i+1)/\(story.chapters?.count ?? 0)",
									subtitle: chapter.subtitle?.joined(separator: "\n\n"),
									button: String(key: i == (story.chapters?.count ?? 0) - 1 ? "story.read.finish.button" : "story.read.continue.button"))
								)
							}
						}
						
						let viewController:LL_Tutorial_ViewController = .init()
						viewController.subtitleLabel.font = Fonts.Content.Text.Regular.withSize(Fonts.Size+2)
						viewController.items = items
						viewController.present()
					}
				}
			}
			else {
				
				let continueButton = alertController.addButton(title: String(key: "story.continue.button.title")) { _ in
					
					alertController.close(closure)
				}
				continueButton.subtitle = String(key: "story.continue.button.subtitle.chapter") + " \(story.current?.currentChapterIndex ?? 0)/\(story.current?.chapters?.count ?? 0) - " + String(key: "story.continue.button.subtitle.word") + " \(story.current?.currentWordIndex ?? 0)/\(story.current?.chapters?[story.current?.currentChapterIndex ?? 0].words?.count ?? 0)"
			}
			
			let startButton = alertController.addButton(title: String(key: "story.start.button")) { _ in
				
				story.save()
				
				alertController.close(closure)
			}
			startButton.type = .secondary
			alertController.addCancelButton()
			alertController.present()
		}
		else {
			
			story?.save()
			
			closure()
		}
	}
}

// MARK: - UICollectionViewDelegateFlowLayout

extension LL_Story_Selection_ViewController: UICollectionViewDelegateFlowLayout {
	
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let layout = collectionViewLayout as! UICollectionViewFlowLayout
		let totalSpacing = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing
		let width = (collectionView.frame.width - totalSpacing) / 2
		let height = width + UI.Margins
		
		return CGSize(width: width, height: height)
	}
}
