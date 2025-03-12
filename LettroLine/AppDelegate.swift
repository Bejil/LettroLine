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
		
		LL_Firebase.shared.start()
		UserDefaults.set(UserDefaults.get(.userId) as? String ?? UUID().uuidString, .userId)
		UserDefaults.delete(.timeTrialBestScore)
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.backgroundColor = Colors.Background.Application
		window?.rootViewController = LL_Menu_ViewController()
		window?.makeKeyAndVisible()
		
		LL_Audio.shared.playMusic()
		
		let splashscreenViewController:LL_Splashscreen_ViewController = .init()
		splashscreenViewController.completion = {
			
			if UserDefaults.get(.onboarding) == nil {
				
				UserDefaults.set(true, .onboarding)
				
				let viewController:LL_Onboarding_ViewController = .init()
				viewController.completion = {
					
					LL_Notifications.shared.check(withCapping: false)
				}
				UI.MainController.present(LL_Onboarding_ViewController(), animated: false)
			}
			else {
				
				LL_Ads.shared.presentAppOpening {
					
					LL_Notifications.shared.check(withCapping: true)
				}
			}
		}
		UI.MainController.present(splashscreenViewController, animated: false)
		
		return true
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		
		LL_Notifications.shared.apnsToken = deviceToken
	}
}

