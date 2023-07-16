//
//  CurrencyConvertView.swift
//  CurrencyConverter
//
//  Created by Nazmul on 16/07/2023.
//

import UIKit
import Foundation

class CurrencyConvertView: UIView {

    @IBOutlet weak var currencyInputContainerView: UIView!
    @IBOutlet weak var currencyInputTextField: UITextField!
    @IBOutlet weak var selectCurrencyCV: UIView!
    @IBOutlet weak var selectCurrencyLabel: UILabel!
    @IBOutlet weak var currencyPickerView: UIPickerView!
    @IBOutlet weak var currencyPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatiorView: UIActivityIndicatorView!
    @IBOutlet weak var currencyInfoTableView: UITableView!
    
   
    static let nibName = "CurrencyConvertView"
    @Published var tappedOnListCurrencyButton: Bool = false
    private var isShowPicker: Bool = false
    private var productArray = ["USD","BDT","YYY","ZD"]
    private let cellHeight: CGFloat = 90.0
   
    
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
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapGesture)
        )
        self.addGestureRecognizer(tap)
        self.registerKeyboardNotification()
        self.setupTableView()
    }
    
    
    @IBAction func tappedOnListCurrencyButton(_ sender: UIButton) {
        self.isShowPicker = !isShowPicker
        self.showHidePickerView(isShow: isShowPicker)
    }
    
    @IBAction func tappedOnPickerViewDoneButton(_ sender: UIButton) {
        self.isShowPicker = !isShowPicker
        self.showHidePickerView(isShow: isShowPicker)
    }
    
    private func showHidePickerView(isShow: Bool) -> Void {
        
        var value = -(currencyPickerView.bounds.size.height * 2)
        if isShow {
            value = 0
            self.endEditing(true)
        }
        UIView.animate(withDuration: 0.5) {
            self.currencyPickerViewBottomConstraint.constant = value
            self.layoutIfNeeded()
        }
    }
    
    @objc private func handleTapGesture() {
        self.endEditing(true)
    }
    
    private func setupTableView() -> Void {
        
        self.currencyInfoTableView.register(
            UINib(
                nibName: CurrencyTableViewCell.cellIdentifier,
                bundle: nil
            ),
            forCellReuseIdentifier: CurrencyTableViewCell.cellIdentifier
        )
        self.currencyInfoTableView.contentInset = UIEdgeInsets(top: 12,
                                                               left: 0,
                                                               bottom: 20,
                                                               right: 0)

    }
}

//MARK: - keyboard notification
extension CurrencyConvertView {
    private func registerKeyboardNotification() -> Void {
        NotificationCenter.default.addObserver (
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver (
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.isShowPicker = false
        self.showHidePickerView(isShow: isShowPicker)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        
    }
}

//MARK: - UIPickerViewDataSource
extension CurrencyConvertView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return productArray.count
    }
}

//MARK: - CurrencyConvertView
extension CurrencyConvertView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {

        let myTitle = NSAttributedString (
            string: self.productArray[row],
            attributes:[NSAttributedString.Key.foregroundColor: UIColor.black]
        )
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectCurrencyLabel.text = self.productArray[row]
    }
}

//MARK: - UITableViewDataSource UITableViewDelegate
extension CurrencyConvertView: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
      
       return 200
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CurrencyTableViewCell.cellIdentifier,
            for: indexPath
        ) as? CurrencyTableViewCell else { return UITableViewCell() }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
    }
}
