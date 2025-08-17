//
//  AppDelegate.swift
//  LettroLine
//
//  Created by BLIN Michael on 11/02/2025.
//

import UIKit
import UserMessagingPlatform

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		_ = LL_Network.shared
		LL_Firebase.shared.start()
		LL_Ads.shared.start()
		UserDefaults.set(UserDefaults.get(.userId) as? String ?? UUID().uuidString, .userId)
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.backgroundColor = Colors.Background.Application
		
		let navigationController:LL_NavigationController = .init(rootViewController: LL_Menu_ViewController())
		navigationController.navigationBar.prefersLargeTitles = false
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
		
		LL_Audio.shared.playMusic()
		
		if UserDefaults.get(.onboarding) == nil {
			
			UserDefaults.set(true, .onboarding)
			
			let viewController:LL_Onboarding_ViewController = .init()
			viewController.completion = {
				
				LL_Notifications.shared.check(withCapping: false)
			}
			UI.MainController.present(LL_Onboarding_ViewController(), animated: false)
		}
		else {
			
			let parameters = UMPRequestParameters()
			parameters.tagForUnderAgeOfConsent = false
			
			UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { [weak self] _ in
				
				UMPConsentForm.load { [weak self] form, _ in
					
					if UMPConsentInformation.sharedInstance.consentStatus == .required {
						
						form?.present(from: UI.MainController)
					}
					else if UMPConsentInformation.sharedInstance.consentStatus == .obtained {
						
						self?.afterLaunch()
						NotificationCenter.post(.updateAds)
					}
				}
			}
		}
		
		return true
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		
		afterLaunch()
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		
		LL_Notifications.shared.apnsToken = deviceToken
	}
	
	private func presentAdAppOpening() {
		
		LL_Ads.shared.presentAppOpening {
			
			LL_Notifications.shared.check(withCapping: true) { _ in
				
				let name = UserDefaults.get(.userName) as? String
				
				if name == nil || name?.count == 0 {
						
					LL_User_Name_Alert_ViewController().present()
				}
			}
		}
	}
	
	private func afterLaunch() {
		
		presentAdAppOpening()
		LL_Rewards.shared.updateLastConnexionDate()
	}
}

