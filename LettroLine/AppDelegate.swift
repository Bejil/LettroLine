//
//  AppDelegate.swift
//  LettroLine
//
//  Created by BLIN Michael on 11/02/2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.backgroundColor = Colors.Background.Application
		window?.rootViewController = LL_Menu_ViewController()
		window?.makeKeyAndVisible()
		
		LL_Audio.shared.playMusic()
		
		if UserDefaults.get(.onboarding) == nil {
		
			UserDefaults.set(true, .onboarding)
			
			UI.MainController.present(LL_Onboarding_ViewController(), animated: false)
		}
		
		return true
	}
}

