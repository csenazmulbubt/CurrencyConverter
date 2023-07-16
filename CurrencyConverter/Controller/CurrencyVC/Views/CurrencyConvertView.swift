//
//  CurrencyConvertView.swift
//  CurrencyConverter
//
//  Created by Nazmul on 16/07/2023.
//

import UIKit

class CurrencyConvertView: UIView {

    @IBOutlet weak var currencyInputContainerView: UIView!
    @IBOutlet weak var currencyInputTextField: UITextField!
    @IBOutlet weak var selectCurrencyCV: UIView!
    @IBOutlet weak var selectCurrencyLabel: UILabel!
    @IBOutlet weak var currencyPickerView: UIPickerView!
    @IBOutlet weak var currencyPickerViewBottomConstraint: NSLayoutConstraint!
    
    static let nibName = "CurrencyConvertView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    private func configureView() -> Void {
        guard let view = self.loadViewFromNib(
            nibName: CurrencyConvertView.nibName
        ) else { return }
        view.frame = self.bounds
        self.addSubview(view)
        self.initialSetup()
    }
    
    private func initialSetup() -> Void {
        self.currencyInputContainerView.layer.cornerRadius = 6
        self.selectCurrencyCV.layer.cornerRadius = 6
    }
    
    
    @IBAction func tappedOnListCurrencyButton(_ sender: UIButton) {
    }
    
    
    @IBAction func tappedOnPickerViewDoneButton(_ sender: UIButton) {
    }
    
}
