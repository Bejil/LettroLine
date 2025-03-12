//
//  LL_Firebase.swift
//  LettroLine
//
//  Created by BLIN Michael on 07/03/2025.
//

import Firebase

public class LL_Firebase {
	
	public static let shared:LL_Firebase = .init()
	
	public func start() {
		
		FirebaseApp.configure()
	}
}
