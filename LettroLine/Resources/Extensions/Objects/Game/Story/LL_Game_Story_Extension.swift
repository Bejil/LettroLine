//
//  LL_Game_Story_Extension.swift
//  LettroLine
//
//  Created by BLIN Michael on 03/09/2025.
//

extension LL_Game_Story.Story {
	
	public var isStarted:Bool {
		
		return current != nil
	}
	public var isFinished:Bool {
		
		return isStarted && (current?.currentChapterIndex ?? 0) == (chapters?.count ?? 0) && (current?.currentWordIndex ?? 0) == (current?.chapters?[(current?.currentChapterIndex ?? 0) - 1].words?.count ?? 0)
	}
}

extension [LL_Game_Story.Story] {
	
	public var notStarted:[LL_Game_Story.Story]? {
		
		return filter({ !$0.isStarted })
	}
	public var started:[LL_Game_Story.Story]? {
		
		return filter({ $0.isStarted && !$0.isFinished })
	}
	public var finished:[LL_Game_Story.Story]? {
		
		return filter({ $0.isFinished })
	}
}
