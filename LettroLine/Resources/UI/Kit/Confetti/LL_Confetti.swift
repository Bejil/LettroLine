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
		SPConfettiConfiguration.particlesConfig.colors = [Colors.Primary,Colors.Secondary,Colors.Tertiary]
		SPConfetti.startAnimating(.fullWidthToDown, particles: [.arc])
	}
	
	public static func stop() {
		
		SPConfetti.stopAnimating()
	}
}
