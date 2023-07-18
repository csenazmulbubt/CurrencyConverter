//
//  CurrencyConvertView.swift
//  CurrencyConverter
//
//  Created by Nazmul on 16/07/2023.
//

import UIKit
import Foundation

protocol CurrencConvertViewDelegate: AnyObject {
    func didReciveConvertAmount(_ amount: Double)
}

class CurrencyConvertView: UIView {
    
    @IBOutlet weak var currencyInputContainerView: UIView!
    @IBOutlet weak var currencyInputTextField: UITextField!
    @IBOutlet weak var selectCurrencyCV: UIView!
    @IBOutlet weak var selectCurrencyLabel: UILabel!
    @IBOutlet weak var currencyPickerView: UIPickerView!
    @IBOutlet weak var currencyPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatiorView: UIActivityIndicatorView!
    @IBOutlet weak var currencyInfoTableView: UITableView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    weak var delegate: CurrencConvertViewDelegate? = nil
    static let nibName = "CurrencyConvertView"
    
    private var isShowPicker: Bool = false
    private let cellHeight: CGFloat = 120.0
    private var selectedAmount: Double = 0.0
    private let debounce = Debounce(timeInterval: 0.3, queue: .global(qos: .userInitiated))
    private var currencyConvertModelArray: [CurrencyConvertModel] = []
    public var currencyList = [String : String]()
    
    
    public var selectedBaseCurrency = "USD"
    
    public var currencyListKeySorted = [String]() {
        didSet {
            self.reloadCurrencyList()
        }
    }
    
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
        self.currencyInputTextField.delegate = self
        self.currencyInputContainerView.layer.cornerRadius = 6
        self.selectCurrencyCV.layer.cornerRadius = 6
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapGesture)
        )
        self.addGestureRecognizer(tap)
        self.registerKeyboardNotification()
        self.currencyInfoTableView.layer.cornerRadius = 6
        self.currencyPickerView.layer.cornerRadius = 6
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
                                                               bottom: 50,
                                                               right: 0)
    }
    
    func reloadCurrencyResult(_ convertedArray: [CurrencyConvertModel]) -> Void {
        self.currencyInfoTableView.isHidden = false
        self.errorMessageLabel.isHidden = true
        self.currencyConvertModelArray = convertedArray
        self.currencyInfoTableView.reloadData()
    }
    
    private func reloadCurrencyList() -> Void {
        self.activityIndicatiorView.stopAnimating()
        self.currencyPickerView.reloadAllComponents()
    }
    
    private func callForConvertCurrency() -> Void {
        debounce.dispatch { [weak self] in
            guard let self = self else { return }
            var amount: Double = 0.0
            DispatchQueue.main.async {
                if let amt = self.currencyInputTextField.text?.toDouble() {
                    amount = amt
                }
                self.delegate?.didReciveConvertAmount(amount)
            }
        }
    }
    
    func showErrorMessage(message: String) -> Void {
        self.currencyInfoTableView.isHidden = true
        self.errorMessageLabel.isHidden = false
        self.errorMessageLabel.text = message
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
        
        return self.currencyListKeySorted.count
    }
}

//MARK: - UIPickerViewDelegate
extension CurrencyConvertView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = currencyListKeySorted[row]
        if let value = self.currencyList[title] {
            title = value + "(\(title))"
        }
        let myTitle = NSAttributedString (
            string: title,
            attributes:[NSAttributedString.Key.foregroundColor: UIColor.black]
        )
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedBaseCurrency =  currencyListKeySorted[row]
        self.selectCurrencyLabel.text =  currencyListKeySorted[row]
        self.callForConvertCurrency()
    }
}

//MARK: - UITableViewDataSource UITableViewDelegate
extension CurrencyConvertView: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        return currencyConvertModelArray.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CurrencyTableViewCell.cellIdentifier,
            for: indexPath
        ) as? CurrencyTableViewCell else { return UITableViewCell() }
        
        cell.setValue(
            from: currencyConvertModelArray[indexPath.item].from,
            to:currencyConvertModelArray[indexPath.item].to ,
            rate: currencyConvertModelArray[indexPath.item].rate,
            result: currencyConvertModelArray[indexPath.item].result
        )
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

//MARK: - UITextFieldDelegate
extension CurrencyConvertView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.callForConvertCurrency()
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
}
