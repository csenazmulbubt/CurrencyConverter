//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Nazmul on 14/07/2023.
//

import UIKit
import Combine


class CurrencyConvertVC: UIViewController {
    
    @IBOutlet weak var currencyConvertView: CurrencyConvertView!
   
    private var cancellables = Set<AnyCancellable>()
    private let currencyConvertViewModel = CurrencyConvertViewModel(
        CurrencyServices(NetworkService())
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setppCurrencyConvertResultBinding()
        self.currencyConvertView.delegate = self
        self.currencyConvertViewModel.fetchLatestCurrencyRate(URLRequestBuilder: self.getRequestBuilder(), baseCurrency: "USD", amount: 0.0)
    }
    
    private func setppCurrencyConvertResultBinding() -> Void {
        self.currencyConvertViewModel
            .$status
            .sink {  [weak self] status in
            guard let self = self else { return }
            switch status {
            case .loading(_):
                break
            case .success(let currencyConvertModelArray):
                self.currencyConvertView.reloadCurrencyResult(currencyConvertModelArray)
            case .failure(let message):
                self.currencyConvertView.showErrorMessage(message: message)
            }
        }.store(in: &cancellables)
    }
    
    private func getRequestBuilder() -> URLRequestBuilder {
        let query = ["app_id": Constants.appIDForOpenExchangeRates,
                     "base": "USD"]
        let URLRequestBuilder = URLRequestBuilder(
            httpMethod: .get,
            host: .openExchangeRates,
            scheme: .https,
            endPath: OpenExchangeRequestPath.latest.path,
            queryParams: query
        )
        return URLRequestBuilder
    }
}

//MARK: - CurrencConvertViewDelegate
extension CurrencyConvertVC: CurrencConvertViewDelegate {
    func didReciveConvertAmount(_ amount: Double) {
        
        self.currencyConvertViewModel.fetchLatestCurrencyRate(
            URLRequestBuilder: self.getRequestBuilder(),
            baseCurrency: currencyConvertView.selectedBaseCurrency,
            amount: amount
        )
    }
}
