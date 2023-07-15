//
//  ResponseState.swift
//
//
//  Created by Nazmul on 15/07/2023.
//

import Foundation

public enum ResoponseStatus<T> {
    case loading(_ message: String)
    case success(_ value: T)
    case failure(_ errorMessage: String)
}
