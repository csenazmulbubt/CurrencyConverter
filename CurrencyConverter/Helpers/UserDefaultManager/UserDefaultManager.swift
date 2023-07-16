//
//  UserDefaultManager.swift
//  CurrencyConverter
//
//  Created by Nazmul on 16/07/2023.
//

import Foundation


class UserDefaultManager {
    
    private static let userDefault = UserDefaults.standard
    
    class func getData(with Key: String) -> String? {
        if let data = userDefault.object(forKey: Key) as? String {
            return data
        }
        return nil
    }
    
    class func saveData(
        _ value: String,
        key: String
    ) -> Void {
        userDefault.set(value, forKey: key)
        userDefault.synchronize()
    }
}
