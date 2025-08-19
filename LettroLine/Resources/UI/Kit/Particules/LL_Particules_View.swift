//
//  LL_Particules_View.swift
//  LettroLine
//
//  Created by BLIN Michael on 23/08/2023.
//

import Foundation
import SpriteKit

public class LL_Particules_View : SKView {
	
	private class RadialGradientLayer: CALayer {
		
		override func draw(in ctx: CGContext) {
			
			ctx.saveGState()
			defer { ctx.restoreGState() }
			
			let colors = [UIColor.black.cgColor, UIColor.clear.cgColor] as CFArray
			let locations: [CGFloat] = [0.5, 1.0]
			
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) else { return }
			
			let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
			let radius = bounds.width / 2
			
			ctx.drawRadialGradient(
				gradient,
				startCenter: center, startRadius: 0,
				endCenter: center, endRadius: radius,
				options: .drawsAfterEndLocation
			)
		}
	}
	
	public var scale:CGFloat = 1.0 {
		
		didSet {
			
			layoutSubviews()
		}
	}
	public var isFade:Bool = true {
		
		didSet {
			
			layoutSubviews()
		}
	}
	private lazy var particulesScene:SKScene = {
		
		$0.backgroundColor = .clear
		$0.scaleMode = .resizeFill
		$0.addChild(particulesEmitterNode)
		return $0
		
	}(SKScene())
	public lazy var particulesEmitterNode:SKEmitterNode = {
		
		$0.particleColorSequence = nil
		$0.particleColor = Colors.Primary.withAlphaComponent(0.1)
		return $0
		
	}(SKEmitterNode(fileNamed: "LL_Particules.sks")!)
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		backgroundColor = .clear
		contentMode = .scaleAspectFit
		presentScene(particulesScene)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		particulesScene.size = .init(width: frame.size.width*scale, height: frame.size.height*scale)
		particulesEmitterNode.position = CGPoint(x: particulesScene.size.width/2, y: particulesScene.size.height/2)
		
		if isFade {
			
			configureRadialGradientMask()
		}
	}
	
	private func configureRadialGradientMask() {
		
		let radialGradientLayer = RadialGradientLayer()
		radialGradientLayer.frame = bounds
		radialGradientLayer.setNeedsDisplay()
		layer.mask = radialGradientLayer
	}
}
