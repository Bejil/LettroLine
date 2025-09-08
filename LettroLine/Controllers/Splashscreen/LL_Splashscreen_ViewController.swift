//
//  LL_Splashscreen_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 04/03/2025.
//

import UIKit

public class LL_Splashscreen_ViewController : LL_ViewController {
	
	public var completion:(()->Void)?
	private lazy var stackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = 2*UI.Margins
		$0.alignment = .center
		
		let firstStackView:LL_Word_StackView = .init()
		firstStackView.spacing = UI.Margins/5
		firstStackView.word = String(key: "splashscreen.0")
		firstStackView.snp.remakeConstraints { make in
			make.height.equalTo(UI.Margins * 3)
		}
		$0.addArrangedSubview(firstStackView)
		
		let lastStackView:LL_Word_StackView = .init()
		lastStackView.spacing = UI.Margins/5
		lastStackView.word = String(key: "splashscreen.1")
		lastStackView.snp.remakeConstraints { make in
			make.height.equalTo(UI.Margins * 3)
		}
		$0.addArrangedSubview(lastStackView)
		
		return $0
		
	}(UIStackView())
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		modalTransitionStyle = .crossDissolve
	}
	
	required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		
		super.loadView()
		
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.left.right.equalToSuperview().inset(2*UI.Margins)
			make.centerY.equalToSuperview()
		}
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		stackView.animate()
		
		UIApplication.wait(2.5) { [weak self] in
			
			LL_Alert_ViewController.presentLoading { [weak self] alertController in
				
				LL_Words.shared.getAll {
					
					alertController?.close {
						
						self?.dismiss(self?.completion)
					}
				}
			}
		}
	}
}
