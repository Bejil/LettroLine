//
//  LL_InAppPurchase.swift
//  LettroLine
//
//  Created by BLIN Michael on 10/03/2025.
//

import StoreKit
import SwiftUI

@MainActor
final class LL_InAppPurchase: ObservableObject {
	
	static let shared = LL_InAppPurchase()
	
	public func fetchProducts() async -> [Product] {
		
		do {
			
			let storeProducts = try await Product.products(for: InAppPurchase.Identifiers)
			return storeProducts
		}
		catch {
			
			return []
		}
	}
	
	public func purchase(product: Product) async -> Bool {
		
		do {
			
			let result = try await product.purchase()
			
			switch result {
				
				case .success(_):
					return true
				case .userCancelled, .pending:
					return false
				@unknown default:
					return false
			}
		}
		catch {
			
			return false
		}
	}
	
	public func restorePurchases() async -> [String] {
		
		var restoredProductIDs: [String] = []
		
		do {
			
			for await result in Transaction.currentEntitlements {
				
				let transaction = try checkVerified(result)
				restoredProductIDs.append(transaction.productID)
			}
			
			return restoredProductIDs
		}
		catch {
			
			return []
		}
	}
	
	private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
		
		switch result {
			
			case .verified(let signedType):
				return signedType
			case .unverified(_, let error):
				throw error
		}
	}
	
	public func promptInAppPurchaseAlert(withCapping capping:Bool? = nil) {
		
		if capping ?? false {
			
			var capping = UserDefaults.get(.inAppPurchaseAlertCapping) as? Int ?? 0
			capping += 1
			
			if capping == InAppPurchase.AlertCapping {
				
				capping = 0
				
				LL_InAppPurchase.shared.promptInAppPurchaseAlert(withCapping: false)
			}
			
			UserDefaults.set(capping, .inAppPurchaseAlertCapping)
		}
		else {
			
			LL_Alert_ViewController.presentLoading { alertController in
				
				Task {
					
					let products = await LL_InAppPurchase.shared.fetchProducts()
					
					alertController?.close {
						
						if let product = products.first(where: { $0.id == InAppPurchase.RemoveAds }) {
							
							let alertController:LL_Alert_ViewController = .init()
							alertController.title = product.displayName
							alertController.add(product.description)
							
							let buyButton = alertController.addButton(title: String(key: "inAppPurchase.purchase.alert.buy.button")) { button in
								
								Task {
									
									await MainActor.run {
										
										button?.isLoading = true
									}
									
									let success = await LL_InAppPurchase.shared.purchase(product: product)
									
									alertController.close {
										
										Task { @MainActor in
											
											if success {
												
												UserDefaults.set(false, .shouldDisplayAds)
												NotificationCenter.post(.updateAds)
												
												let alertController = LL_Alert_ViewController()
												alertController.title = String(key: "inAppPurchase.purchase.success.alert.title")
												alertController.add(String(key: "inAppPurchase.purchase.success.alert.content"))
												alertController.addDismissButton()
												alertController.dismissHandler = {
													
													LL_Confettis.stop()
												}
												alertController.present {
													
													LL_Confettis.start()
												}
											}
											else {
												
												LL_Alert_ViewController.present(LL_Error(String(key: "inAppPurchase.purchase.error.alert.content")))
											}
										}
									}
									
								}
							}
							buyButton.subtitle = product.displayPrice
							
							let restoreButton = alertController.addButton(title: String(key: "inAppPurchase.purchase.alert.restore.button.title")) { button in
								
								Task {
									
									await MainActor.run {
										
										button?.isLoading = true
									}
									
									let restored = await LL_InAppPurchase.shared.restorePurchases()
									
									alertController.close {
										
										Task { @MainActor in
											
											if restored.contains(InAppPurchase.RemoveAds) {
												
												UserDefaults.set(false, .shouldDisplayAds)
												NotificationCenter.post(.updateAds)
												
												let alertController = LL_Alert_ViewController()
												alertController.title = String(key: "inAppPurchase.restore.success.alert.title")
												alertController.add(String(key: "inAppPurchase.restore.success.alert.content"))
												alertController.addDismissButton()
												alertController.dismissHandler = {
													
													LL_Confettis.stop()
												}
												alertController.present {
													
													LL_Confettis.start()
												}
											}
											else {
												
												LL_Alert_ViewController.present(LL_Error(String(key: "inAppPurchase.restore.error.content")))
											}
										}
									}
								}
							}
							restoreButton.subtitle = String(key: "inAppPurchase.purchase.alert.restore.button.subtitle")
							restoreButton.style = .tinted
							
							alertController.addCancelButton()
							alertController.present()
						}
					}
				}
			}
		}
	}
}
