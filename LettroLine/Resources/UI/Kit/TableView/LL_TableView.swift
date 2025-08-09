//
//  LL_TableView.swift
//  LettroLine
//
//  Created by BLIN Michael on 08/08/2025.
//

import UIKit

public class LL_TableView: UITableView {
	
	public var isHeightDynamic:Bool = false
	public override var contentSize: CGSize {
		
		didSet {
			
			isScrollEnabled = !isHeightDynamic
			
			if isHeightDynamic {
				
				self.invalidateIntrinsicContentSize()
			}
		}
	}
	public override var intrinsicContentSize: CGSize {
		
		if isHeightDynamic {
			
			return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
		}
		
		return super.intrinsicContentSize
	}
	public var headerView:UIView? {
		
		didSet {
			
			tableHeaderView = headerView
			
			if let headerView = headerView {
				
				tableHeaderView?.snp.makeConstraints { make in
					make.edges.width.equalToSuperview()
				}
				headerView.layoutIfNeeded()
			}
			
			tableHeaderView?.layoutIfNeeded()
		}
	}
	
	public override init(frame: CGRect, style: UITableView.Style) {
		
		super.init(frame: frame, style: style)
		
		backgroundColor = .clear
		separatorInset = .zero
		contentInset = .init(top: 0, left: 0, bottom: 3*UI.Margins, right: 0)
		register(LL_TableViewCell.self, forCellReuseIdentifier: LL_TableViewCell.identifier)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func reloadData() {
		
		super.reloadData()
		
		if isHeightDynamic {
			
			invalidateIntrinsicContentSize()
			layoutIfNeeded()
		}
	}
}
