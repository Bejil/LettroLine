//
//  LL_User_ImageView.swift
//  LettroLine
//
//  Created by BLIN Michael on 12/08/2025.
//

import UIKit

public class LL_User_ImageView : UIImageView {
	
	init() {
		
		super.init(frame: .zero)
		
		contentMode = .scaleAspectFill
		clipsToBounds = true
		layer.masksToBounds = true
		layer.borderWidth = 3
		layer.borderColor = UIColor.white.cgColor
		
		let height = 4*UI.Margins
		snp.makeConstraints { make in
			make.size.equalTo(height)
		}
		layer.cornerRadius = height/2
		
		loadAvatar()
	}
	
	public func loadAvatar() {
		
		if let name = UserDefaults.get(.userName) as? String ?? UserDefaults.get(.userId) as? String, !name.isEmpty {
			
			LL_BoringAvatar.get(for: name) { [weak self] image in
				
				DispatchQueue.main.async {
					
					if let image = image {
						
						self?.image = image
					}
				}
			}
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		loadAvatar()
	}
}
