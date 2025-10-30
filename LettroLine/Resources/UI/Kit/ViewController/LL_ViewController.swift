//
//  LL_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 11/02/2025.
//

import Foundation
import UIKit

public class LL_ViewController : UIViewController {
	
	public var isModal:Bool = false {
		
		didSet {
			
			if navigationController?.viewControllers.count ?? 0 < 2 {
				
				navigationItem.leftBarButtonItem = .init(image: UIImage(systemName: "xmark"), primaryAction: .init(handler: { [weak self] _ in
					
					UIApplication.feedBack(.Off)
					LL_Audio.shared.playSound(.Button)
					
					self?.close()
				}))
			}
		}
	}
	private lazy var gradientBackgroundLayer:CAGradientLayer = {
		
		let initialColorTop = Colors.Background.View.Secondary.cgColor
		let initialColorBottom = Colors.Background.View.Primary.cgColor
		let finalColorTop = Colors.Background.View.Primary.cgColor
		let finalColorBottom = Colors.Background.View.Secondary.cgColor
		
		$0.colors = [initialColorTop, initialColorBottom]
		$0.startPoint = CGPoint(x: 0.0, y: 0.0)
		$0.endPoint = CGPoint(x: 1.0, y: 1.0)
		
		let animation = CABasicAnimation(keyPath: "colors")
		animation.repeatCount = .infinity
		animation.autoreverses = true
		animation.duration = 5.0
		animation.toValue = [finalColorTop, finalColorBottom]
		animation.fillMode = .forwards
		animation.isRemovedOnCompletion = false
		$0.add(animation, forKey: "animateGradient")
		
		return $0
		
	}(CAGradientLayer())
	private lazy var particulesView:LL_Particules_View = {
		
		$0.isFade = false
		$0.scale = 0.75
		return $0
		
	}(LL_Particules_View())
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		modalPresentationStyle = .fullScreen
		modalTransitionStyle = .coverVertical
	}
	
	required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		
		super.loadView()
		
		view.backgroundColor = Colors.Background.View.Primary
		view.layer.addSublayer(gradientBackgroundLayer)
		view.layer.addSublayer(particulesView.layer)
		
		let tapGestureRecognizer:UITapGestureRecognizer = .init { [weak self] sender in
			
			if let weakSelf = self {
				
				let touchLocation = sender.location(in: weakSelf.view)
				
				let view:UIView = .init()
				view.isUserInteractionEnabled = false
				weakSelf.view.addSubview(view)
				view.snp.makeConstraints { make in
					make.centerX.equalTo(touchLocation.x)
					make.centerY.equalTo(touchLocation.y)
					make.size.equalTo(2*UI.Margins)
				}
				view.pulse(Colors.Primary) {
					
					view.removeFromSuperview()
				}
			}
		}
		tapGestureRecognizer.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGestureRecognizer)
		
		let width = view.bounds.width
		let height = view.bounds.height
		let comets = [Comet(startPoint: CGPoint(x: 100, y: 0),
							endPoint: CGPoint(x: 0, y: 100),
							lineColor: UIColor.white.withAlphaComponent(0.2),
							cometColor: UIColor.white),
					  Comet(startPoint: CGPoint(x: 0.4 * width, y: 0),
							endPoint: CGPoint(x: width, y: 0.8 * width),
							lineColor: UIColor.white.withAlphaComponent(0.2),
							cometColor: UIColor.white),
					  Comet(startPoint: CGPoint(x: 0.8 * width, y: 0),
							endPoint: CGPoint(x: width, y: 0.2 * width),
							lineColor: UIColor.white.withAlphaComponent(0.2),
							cometColor: UIColor.white),
					  Comet(startPoint: CGPoint(x: width, y: 0.2 * height),
							endPoint: CGPoint(x: 0, y: 0.25 * height),
							lineColor: UIColor.white.withAlphaComponent(0.2),
							cometColor: UIColor.white),
					  Comet(startPoint: CGPoint(x: 0, y: height - 0.8 * width),
							endPoint: CGPoint(x: 0.6 * width, y: height),
							lineColor: UIColor.white.withAlphaComponent(0.2),
							cometColor: UIColor.white),
					  Comet(startPoint: CGPoint(x: width - 100, y: height),
							endPoint: CGPoint(x: width, y: height - 100),
							lineColor: UIColor.white.withAlphaComponent(0.2),
							cometColor: UIColor.white),
					  Comet(startPoint: CGPoint(x: 0, y: 0.8 * height),
							endPoint: CGPoint(x: width, y: 0.75 * height),
							lineColor: UIColor.white.withAlphaComponent(0.2),
							cometColor: UIColor.white)]
		
			// draw track and animate
		for comet in comets {
			view.layer.addSublayer(comet.drawLine())
			view.layer.addSublayer(comet.animate())
		}
	}
	
	public override func viewDidLayoutSubviews() {
		
		super.viewDidLayoutSubviews()
		
		gradientBackgroundLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
		particulesView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
	}
	
	public func close() {
		
		dismiss()
	}
	
	public func dismiss(_ completion:(()->Void)? = nil) {
		
		dismiss(animated: true, completion: completion)
	}
}
