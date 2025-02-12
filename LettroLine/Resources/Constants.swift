//
//  Constants.swift
//  LettroLine
//
//  Created by BLIN Michael on 11/02/2025.
//

import UIKit

public struct UI {
	
	public static let Margins:CGFloat = 15.0
	public static let CornerRadius:CGFloat = 25.0
}

public struct Colors {
	
	public static let Primary:UIColor = UIColor(named: "Primary")!
	
	public struct Background {
		
		public static let Application:UIColor = UIColor(named: "ApplicationBackground")!
		public static let View:UIColor = UIColor(named: "ViewBackground")!
	}
	
	public struct Navigation {
		
		public static let Title:UIColor = UIColor(named: "NavigationTitle")!
		public static let Button:UIColor = UIColor(named: "NavigationButton")!
	}
	
	public struct Content {
		
		public static let Title:UIColor = UIColor(named: "ContentTitle")!
		public static let Text:UIColor = UIColor(named: "ContentText")!
	}
}

public struct Fonts {
	
	private struct Name {
		
		static let Regular:String = "TTInterphasesProTrl-Rg"
		static let Bold:String = "TTInterphasesProTrl-Bd"
		static let Black:String = "GROBOLD"
	}
	
	public static let Size:CGFloat = 13
	
	public struct Navigation {
		
		public struct Title {
			
			public static let Large:UIFont = UIFont(name: Name.Black, size: Fonts.Size+25)!
			public static let Small:UIFont = UIFont(name: Name.Black, size: Fonts.Size+12)!
		}
		
		public static let Button:UIFont = UIFont(name: Name.Regular, size: Fonts.Size-2)!
	}
	
	public struct Content {
		
		public struct Text {
			
			public static let Regular:UIFont = UIFont(name: Name.Regular, size: Fonts.Size)!
			public static let Bold:UIFont = UIFont(name: Name.Bold, size: Fonts.Size)!
		}
		
		public struct Button {
			
			public static let Title:UIFont = UIFont(name: Name.Black, size: Fonts.Size+4)!
			public static let Subtitle:UIFont = UIFont(name: Name.Regular, size: Fonts.Size)!
		}
		
		public struct Title {
			
			public static let H1:UIFont = UIFont(name: Name.Black, size: Fonts.Size+15)!
			public static let H2:UIFont = UIFont(name: Name.Black, size: Fonts.Size+11)!
			public static let H3:UIFont = UIFont(name: Name.Black, size: Fonts.Size+8)!
			public static let H4:UIFont = UIFont(name: Name.Black, size: Fonts.Size+5)!
		}
	}
}
