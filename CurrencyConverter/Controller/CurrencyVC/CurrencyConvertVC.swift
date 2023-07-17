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
        self.setupCurrencyConvertResultBinding()
        self.setupCurrencyListResultBinding()
        self.currencyConvertView.delegate = self
        self.currencyConvertViewModel.fetchCurrenciesList(URLRequestBuilder: self.getRequestBuilder(path: OpenExchangeRequestPath.currencies.path))
    }
    
    private func setupCurrencyConvertResultBinding() -> Void {
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
    
    private func setupCurrencyListResultBinding() -> Void {
        self.currencyConvertViewModel.$currencyListStatus.sink { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .loading(_):
                break
            case .success(let currencyList):
                self.currencyConvertView.currencyList = currencyList
                self.currencyConvertView.currencyListKeySorted = self.currencyConvertViewModel.currencyListKeySorted
            case .failure(let message):
                self.currencyConvertView.showErrorMessage(message: message)
            }
        }.store(in: &cancellables)
    }
    
    private func getRequestBuilder(
        query: [String: String] = [:],
        path: String
    ) -> URLRequestBuilder {
        let URLRequestBuilder = URLRequestBuilder(
            httpMethod: .get,
            host: .openExchangeRates,
            scheme: .https,
            endPath: path,
            queryParams: query
        )
        return URLRequestBuilder
    }
}

//MARK: - CurrencConvertViewDelegate
extension CurrencyConvertVC: CurrencConvertViewDelegate {
    func didReciveConvertAmount(_ amount: Double) {
        let query = ["app_id": Constants.appIDForOpenExchangeRates,
                     "base": "USD"]
        self.currencyConvertViewModel.fetchLatestCurrencyRate(
            URLRequestBuilder: self.getRequestBuilder(
                query: query,
                path: OpenExchangeRequestPath.latest.path
            ),
            baseCurrency: currencyConvertView.selectedBaseCurrency,
            amount: amount
        )
    }
}
