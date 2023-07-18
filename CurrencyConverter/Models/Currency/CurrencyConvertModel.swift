//
//  CurrencyConvertModel.swift
//  CurrencyConverter
//
//  Created by Nazmul on 16/07/2023.
//

import Foundation

struct CurrencyConvertModel: Equatable {
    let from: String
    let to: String
    let rate: Double
    let result: Double
}
