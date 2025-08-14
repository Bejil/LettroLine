//
//  UIColor_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 29/04/2024.
//

import Foundation
import UIKit

extension UIColor {
	
	public var hex:String? {
		
		guard let components = cgColor.components, components.count >= 3 else {
			
			return nil
		}
		
		let r = Float(components[0])
		let g = Float(components[1])
		let b = Float(components[2])
		
		return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
	}
}
