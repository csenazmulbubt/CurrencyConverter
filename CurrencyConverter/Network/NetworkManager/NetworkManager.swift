//
//  NetworkManager.swift
//  GadgetGlobal
//
//  Created by Nazmul on 05/06/2023.
//

import Foundation

struct NetworkManager {
    static var isNetworkAvailable: Bool {
        NetworkMonitor.shared.isConnected
    }
}
