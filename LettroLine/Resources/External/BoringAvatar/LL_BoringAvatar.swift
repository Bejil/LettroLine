//
//  LL_BoringAvatar.swift
//  LettroLine
//
//  Created by BLIN Michael on 29/04/2024.
//

import Foundation
import Alamofire
import SVGKit

public class LL_BoringAvatar {
	
	public static func get(for name:String?, _ completion:((UIImage?)->Void)?) {
		
		let urlString = "https://api.dicebear.com/9.x/thumbs/svg?seed=\(name ?? "")&backgroundColor=\(Colors.Primary.hex ?? "")&shapeColor=\(Colors.Secondary.hex ?? "")"
		
		if let url = URL(string: urlString) {
			
			AF.request(url).validate().responseData(completionHandler: { response in
				
				DispatchQueue.main.async {
					
					if let data = response.data, response.error == nil {
						
						if let receivedImage: SVGKImage = SVGKImage(data: data) {
							
							completion?(receivedImage.uiImage)
						}
						else {
							
							completion?(nil)
						}
					}
				}
			})
		}
		else {
			
			completion?(nil)
		}
	}
}
