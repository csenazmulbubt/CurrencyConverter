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
        setUpResult()
        self.currencyConvertView.delegate = self
        self.currencyConvertViewModel.fetchLatestCurrencyRate(URLRequestBuilder: self.getRequestBuilder(), baseCurrency: "BDT", amount: 0)
    }
    
    private func setUpResult() -> Void {
        self.currencyConvertViewModel.$status.sink { completion in
            
        } receiveValue: { status in
            switch status {
            case .loading(_):
                break
            case .success(let currencyConvertModelArray):
                //
                self.currencyConvertView.reloadCurrencyResult(currencyConvertModelArray)
                print("CuurencyConv",currencyConvertModelArray.count)
            case .failure(let message):
                print("Errror",message)
            }
        }.store(in: &cancellables)
        
    }
    
    
    private func getRequestBuilder() -> URLRequestBuilder {
        let query = ["app_id": "83dd119769df4f25b57515e894149776",
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
