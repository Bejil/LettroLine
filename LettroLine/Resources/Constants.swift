//
//  Constants.swift
//  LettroLine
//
//  Created by BLIN Michael on 11/02/2025.
//

import UIKit

public struct Game {
	
	public static let BonusRate:Double = 0.2
	public static let TimeTrialDuration:TimeInterval = 60
	public static let firstPointsLevel: Double = 5.0
	public static let pointsLevelMultiplier: Double = 2.3333
}

public struct UI {
	
	static var MainController :UIViewController {
		
		return UIApplication.shared.topMostViewController()!
	}
	
	public static let Margins:CGFloat = 15.0
	public static let CornerRadius:CGFloat = 15.0
}

public struct Colors {
	
	public static let Primary:UIColor = UIColor(named: "Primary")!
	public static let Secondary:UIColor = UIColor(named: "Secondary")!
	public static let Tertiary:UIColor = UIColor(named: "Tertiary")!
	
	public struct Background {
		
		public static let Application:UIColor = UIColor(named: "ApplicationBackground")!
		
		public struct View {
			
			public static let Primary:UIColor = UIColor(named: "ViewBackgroundPrimary")!
			public static let Secondary:UIColor = UIColor(named: "ViewBackgroundSecondary")!
		}
	}
	
	public struct Navigation {
		
		public static let Title:UIColor = UIColor(named: "NavigationTitle")!
		public static let Button:UIColor = UIColor(named: "NavigationButton")!
	}
	
	public struct Content {
		
		public static let Title:UIColor = UIColor(named: "ContentTitle")!
		public static let Text:UIColor = UIColor(named: "ContentText")!
	}
	
	public struct Button {
		
		public static let Badge:UIColor = UIColor(named: "ButtonBadge")!
		
		public struct Primary {
			
			public static let Background:UIColor = UIColor(named: "ButtonPrimaryBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonPrimaryContent")!
		}
		
		public struct Secondary {
			
			public static let Background:UIColor = UIColor(named: "ButtonSecondaryBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonSecondaryContent")!
		}
		
		public struct Tertiary {
			
			public static let Background:UIColor = UIColor(named: "ButtonTertiaryBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonTertiaryContent")!
		}
		
		public struct Delete {
			
			public static let Background:UIColor = UIColor(named: "ButtonDeleteBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonDeleteContent")!
		}
		
		public struct Navigation {
			
			public static let Background:UIColor = UIColor(named: "ButtonTextBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonTextContent")!
		}
	}
	
	public struct Letter {
			
		public static let Selected:UIColor = UIColor(named: "LetterSelected")!
	}
}

public struct Fonts {
	
	private struct Name {
		
		static let Regular:String = "TTInterphasesProTrl-Rg"
		static let Bold:String = "TTInterphasesProTrl-Bd"
		static let Black:String = "GROBOLD"
		static let Letter:String = "Fredoka-Bold"
	}
	
	public static let Size:CGFloat = 13
	
	public static let Letter:UIFont = UIFont(name: Name.Letter, size: Fonts.Size+25)!
	
	public struct Navigation {
		
		public struct Title {
			
			public static let Large:UIFont = UIFont(name: Name.Black, size: Fonts.Size+25)!
			public static let Small:UIFont = UIFont(name: Name.Black, size: Fonts.Size+12)!
		}
		
		public static let Button:UIFont = UIFont(name: Name.Black, size: Fonts.Size)!
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

public struct InAppPurchase {
	
	static let AlertCapping:Int = 5
	static let Identifiers:[String] = [RemoveAds]
	static let RemoveAds:String = "com.michaelblin.LettroLine.removeAds"
}

public struct Ads {
	
	public struct FullScreen {
		
		static let AppOpening:String = "ca-app-pub-9540216894729209/6324961115"
		static let GameStart:String = "ca-app-pub-9540216894729209/2969670465"
		static let GameLose:String = "ca-app-pub-9540216894729209/3530813793"
		static let GameChance:String = "ca-app-pub-9540216894729209/6669242328"
		static let GameBonus:String = "ca-app-pub-9540216894729209/9020073495"
	}
	
	public struct Banner {
		
		static let Menu:String = "ca-app-pub-9540216894729209/6355236657"
		static let Game:String = "ca-app-pub-9540216894729209/9604433403"
	}
}
