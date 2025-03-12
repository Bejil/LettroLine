//
//  LL_Notifications.swift
//  LettroLine
//
//  Created by BLIN Michael on 24/06/2022.
//

import Foundation
import UIKit
import UserNotifications
import FirebaseMessaging

public class LL_Notifications : NSObject {
	
	static let shared:LL_Notifications = .init()
	private var notificationCenter:UNUserNotificationCenter = .current()
	public var apnsToken:Data? {
		
		didSet {
			
			Messaging.messaging().apnsToken = apnsToken
		}
	}
	
	public override init() {
		
		super.init()
		
		notificationCenter.delegate = self
	}
	
	public func check(withCapping capping:Bool = false, andCompletion completion:((Error?)->Void)? = nil) {
		
		if capping {
			
			if let date = UserDefaults.get(.notifications) as? Date {
				
				let calendar = Calendar.current
				let date1 = calendar.startOfDay(for: date)
				let date2 = calendar.startOfDay(for: Date())
				
				let components = calendar.dateComponents([.day], from: date1, to: date2)
				
				if let day = components.day, day > 2  {
					
					check(withCapping:false, andCompletion:completion)
				}
			}
			else{
				
				check(withCapping:false, andCompletion:completion)
			}
			
			UserDefaults.set(Date(), .notifications)
		}
		else{
			
			func promptDeniedAlert() {
				
				let alertController:LL_Alert_ViewController = .init()
				alertController.title = String(key: "authorizations.denied.alert.title")
				alertController.add(String(key: "authorizations.ask.alert.notifications"))
				alertController.add(String(key: "authorizations.denied.alert.content"))
				
				if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
					
					alertController.addButton(title: String(key: "authorizations.denied.alert.button")) { _ in
						
						alertController.close() {
							
							UIApplication.shared.open(url)
						}
					}
				}
				alertController.addCancelButton()
				alertController.present()
			}
			
			UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
				
				DispatchQueue.main.async { [weak self] in
					
					if settings.authorizationStatus == .authorized {
						
						completion?(nil)
					}
					else if settings.authorizationStatus == .denied {
						
						promptDeniedAlert()
						completion?(nil)
					}
					else{
						
						let alertController:LL_Alert_ViewController = .init()
						alertController.title = String(key: "authorizations.ask.alert.title")
						alertController.add(String(key: "authorizations.ask.alert.notifications"))
						alertController.addButton(title: String(key: "authorizations.ask.alert.button")) { [weak self] _ in
							
							alertController.close() { [weak self] in
								
								self?.requestAuthorization { status in
									
									if !status {
										
										promptDeniedAlert()
									}
									
									completion?(nil)
								}
							}
						}
						alertController.addCancelButton()
						alertController.backgroundView.isUserInteractionEnabled = false
						alertController.present()
					}
				}
			}
		}
	}
	
	public func requestAuthorization(_ completion:((Bool)->Void)?) {
		
		notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
			
			DispatchQueue.main.async {
				
				let status = granted && error == nil
				
				UIApplication.shared.registerForRemoteNotifications()
				
				completion?(status)
			}
		}
	}
}

extension LL_Notifications : UNUserNotificationCenterDelegate {
	
	public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		
		let userInfo = notification.request.content.userInfo
		Messaging.messaging().appDidReceiveMessage(userInfo)
		
		completionHandler([.banner, .list, .sound, .badge])
	}
	
	public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		
		let userInfo = response.notification.request.content.userInfo
		Messaging.messaging().appDidReceiveMessage(userInfo)
		
		completionHandler()
	}
}
