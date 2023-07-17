//
//  Extensions.swift
//  CurrencyConverter
//
//  Created by Nazmul on 15/07/2023.
//

import Foundation
import UIKit
import Combine

extension UIView {
    
    func loadViewFromNib (nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName,
                        bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil
        ).first as? UIView
    }
    
    func roundCorners(
        corners: UIRectCorner,
        radius: CGFloat
    ) -> Void {
        let path = UIBezierPath (
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius,
                         height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension Date {
    static var currentTimeStamp: Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    func intervalSince(isMoreThan minutes: Int) -> Bool {
       return Date() > self.advanced(by: Double(minutes) * 60.0)
    }
}

extension Double {
    var dateFormatted : Date? {
        let date = Date(timeIntervalSince1970: self)
        return date
    }
    
    // returns the date formatted according to the format string provided.
    func dateFormatted(withFormat format : String) -> String{
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

extension Publisher {
    func flatMapLatest<P: Publisher>(_ transform: @escaping (Output) -> P) -> Publishers.SwitchToLatest<P, Publishers.Map<Self, P>> {
        map(transform).switchToLatest()
    }
}

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

