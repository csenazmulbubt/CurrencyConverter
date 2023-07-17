//
//  CurrencyConvertViewModel.swift
//  CurrencyConverter
//
//  Created by Nazmul on 16/07/2023.
//

import Foundation
import Combine


enum CurrencyConvertError: Error {
    case error(_ messge: String)
    case success(_ value: Double)
}

class CurrencyConvertViewModel {
    
    private let currencyServices: CurrencyServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currencyConvertModelArray: [CurrencyConvertModel] = []
    @Published var status: ResoponseStatus<[CurrencyConvertModel]> = .loading("Loading")
    
    init(_ currencyServices: CurrencyServiceProtocol) {
        self.currencyServices = currencyServices
    }
    
    public func fetchLatestCurrencyRate(
        URLRequestBuilder: URLRequestBuilder,
        baseCurrency: String,
        amount: Double
    ) -> Void {
        
        self.currencyServices.getLatestCurrencyRates(
            URLRequestBuilder: URLRequestBuilder
        ).sink { complettion in
            switch complettion {
            case .failure(let message):
                self.status = .failure(message.localizedDescription)
            case .finished:
                debugPrint("Finished")
            }
        } receiveValue: { [weak self] result in
            guard let self = self else {
                self?.status = .failure("Something went wrong")
                return
            }
            self.currencyConvertModelArray.removeAll()
            let sortedCurrencyRatesKeyArray = result.rates.keys.sorted(by: < )
             _ = sortedCurrencyRatesKeyArray.map({ to in
                 try? self.convertCurrency(
                     from: baseCurrency,
                     to: to,
                     amount: amount,
                     currencyModel: result
                 )
             })
            self.status = .success(self.currencyConvertModelArray)
           
        }.store(in: &cancellables)
    }
    
    @discardableResult public func convertCurrency(
        from: String,
        to: String,
        amount: Double,
        currencyModel: CurrencyModel
    ) throws -> Double {
        
        guard let fromRate = currencyModel.rates[from] else {
            throw CurrencyConvertError.error("from rates not found")
        }
        
        guard var toRate = currencyModel.rates[to] else {
            throw CurrencyConvertError.error("to rates not found")
        }
        
        let value = (amount / fromRate) * toRate
        
        if from != currencyModel.base {
            toRate = (toRate / fromRate)
           
        }
        let currencyModel = CurrencyConvertModel (
            from: from,
            to: to,
            rate: toRate.roundToDecimal(3),
            result: value.roundToDecimal(3)
        )
        self.currencyConvertModelArray.append(currencyModel)
        return value
    }
}
