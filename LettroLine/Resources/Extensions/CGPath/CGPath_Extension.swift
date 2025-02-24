//
//  CGPath_Extension.swift
//  LettroLine
//
//  Created by BLIN Michael on 13/02/2025.
//

import UIKit

extension CGPath {
	
	private class ClosureWrapper {
		
		let closure: (CGPathElement) -> Void
		
		init(_ closure: @escaping (CGPathElement) -> Void) {
			
			self.closure = closure
		}
	}
		
	public func forEach(body: @escaping (CGPathElement) -> Void) {
		
		let wrapper = ClosureWrapper(body)
		let unsafeBody = Unmanaged.passUnretained(wrapper).toOpaque()
		
		func callback(info: UnsafeMutableRawPointer?, element: UnsafePointer<CGPathElement>) {
				
			let wrapper = Unmanaged<ClosureWrapper>.fromOpaque(info!).takeUnretainedValue()
			wrapper.closure(element.pointee)
		}
		
		self.apply(info: unsafeBody, function: callback)
	}
}
