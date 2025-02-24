//
//  UIBezierPath_Extension.swift
//  LettroLine
//
//  Created by BLIN Michael on 13/02/2025.
//

import UIKit

extension UIBezierPath {
	
	public func quadraticBezier(t: CGFloat, start: CGPoint, control: CGPoint, end: CGPoint) -> CGPoint {
		
		let mt = 1 - t
		let x = mt * mt * start.x + 2 * mt * t * control.x + t * t * end.x
		let y = mt * mt * start.y + 2 * mt * t * control.y + t * t * end.y
		
		return CGPoint(x: x, y: y)
	}
	
	public func cubicBezier(t: CGFloat, start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint) -> CGPoint {
		
		let mt = 1 - t
		let x = mt * mt * mt * start.x +
		3 * mt * mt * t * control1.x +
		3 * mt * t * t * control2.x +
		t * t * t * end.x
		let y = mt * mt * mt * start.y +
		3 * mt * mt * t * control1.y +
		3 * mt * t * t * control2.y +
		t * t * t * end.y
		return CGPoint(x: x, y: y)
	}
	
	public  var flattenedPoints: [CGPoint] {
		
		var points = [CGPoint]()
		var currentPoint = CGPoint.zero
		let sampleStep: CGFloat = 0.05
		
		self.cgPath.forEach { element in
			
			switch element.type {
				
			case .moveToPoint:
				
				currentPoint = element.points[0]
				points.append(currentPoint)
				
			case .addLineToPoint:
				
				currentPoint = element.points[0]
				points.append(currentPoint)
				
			case .addQuadCurveToPoint:
				
				let control = element.points[0]
				let end = element.points[1]
				
				for t in stride(from: sampleStep, to: 1.0, by: sampleStep) {
					
					let pt = self.quadraticBezier(t: t, start: currentPoint, control: control, end: end)
					points.append(pt)
				}
				
				currentPoint = end
				points.append(currentPoint)
				
			case .addCurveToPoint:
				
				let control1 = element.points[0]
				let control2 = element.points[1]
				let end = element.points[2]
				
				for t in stride(from: sampleStep, to: 1.0, by: sampleStep) {
					
					let pt = self.cubicBezier(t: t, start: currentPoint, control1: control1, control2: control2, end: end)
					points.append(pt)
				}
				
				currentPoint = end
				points.append(currentPoint)
				
			case .closeSubpath:
				
				if let first = points.first {
					
					points.append(first)
					currentPoint = first
				}
				
			@unknown default:
				
				break
			}
		}
		
		return points
	}
}
