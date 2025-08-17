//
//  LL_User_Name_Alert_ViewController.swift
//  LettroLine
//
//  Created by BLIN Michael on 10/08/2025.
//

import UIKit

public class LL_User_Name_Alert_ViewController : LL_Alert_ViewController {
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = String(key: "user.name.alert.title")
		add(String(key: "user.name.alert.content"))
		
		let textField:UITextField = .init()
		textField.font = Fonts.Content.Text.Regular
		textField.textColor = Colors.Content.Text
		textField.text = UserDefaults.get(.userName) as? String
		textField.placeholder = String(key: "user.name.alert.textField.placeholder")
		
		let textFieldView:UIView = .init()
		textFieldView.backgroundColor = Colors.Background.View.Primary
		textFieldView.layer.cornerRadius = UI.CornerRadius
		textFieldView.addSubview(textField)
		textField.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview().inset(UI.Margins/2)
			make.left.right.equalToSuperview().inset(UI.Margins)
		}
		add(textFieldView)
		
		let button = addButton(title: String(key: "user.name.alert.button")) { [weak self] sender in
			
			UserDefaults.set(textField.text, .userName)
			NotificationCenter.post(.updateUserName)
			
			self?.close()
		}
		textField.addAction(.init(handler: { _ in
			
			button.isEnabled = textField.text?.count != 0
			
		}), for: .editingChanged)
		textField.sendActions(for: .editingChanged)
		
		addCancelButton()
	}
	
	@MainActor required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
