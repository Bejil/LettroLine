//
//  LL_Network.swift
//  LettroLine
//
//  Created by BLIN Michael on 14/03/2025.
//

import Network

public class LL_Network {
	
	static let shared = LL_Network()
	private let monitor = NWPathMonitor()
	private let queue = DispatchQueue.global(qos: .background)
	
	var isConnected: Bool = false
	
	private init() {
		
		monitor.pathUpdateHandler = { [weak self] path in
			
			self?.isConnected = path.status == .satisfied
		}
		
		monitor.start(queue: queue)
	}
}
