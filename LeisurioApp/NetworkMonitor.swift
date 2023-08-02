//
//  NetworkMonitor.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 01.08.2023.
//

import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private var queue = DispatchQueue.global()
    private var monitor: NWPathMonitor
    
    public private(set) var isConnected: Bool = true
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
            print(self?.isConnected ?? "")
        }
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
}
