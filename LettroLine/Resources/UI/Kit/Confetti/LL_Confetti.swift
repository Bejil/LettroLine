//
//  LL_Confetti.swift
//  LettroLine
//
//  Created by BLIN Michael on 14/02/2025.
//

import SPConfetti

public class LL_Confettis {
	
	public static func start() {
		
		SPConfettiConfiguration.particlesConfig.birthRate = 50
		
		var colors = [Colors.Primary,Colors.Secondary,Colors.Tertiary]
		colors.append(contentsOf: Colors.Letter.Colors.flatMap { [$0.0, $0.1] })
		
		SPConfettiConfiguration.particlesConfig.colors = colors
		SPConfetti.startAnimating(.fullWidthToDown, particles: [.arc])
	}
	
	public static func stop() {
		
		SPConfetti.stopAnimating()
	}
}
