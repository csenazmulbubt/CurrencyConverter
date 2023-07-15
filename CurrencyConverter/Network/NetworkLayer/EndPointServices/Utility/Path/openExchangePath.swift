//
//  OpenExchangeRequestPath.swift
//  SampleShopAppMVVM
//
//  Created by Nazmul on 15/07/2023.
//

import Foundation

public enum OpenExchangeRequestPath {
    case latest

    fileprivate var basePath: String {
        return "/api"
    }
    
    var path: String {
        basePath + endPath
    }
    
    private var endPath: String {
        switch self {
        case .latest:
            return "/latest.json"
        }
    }
}
