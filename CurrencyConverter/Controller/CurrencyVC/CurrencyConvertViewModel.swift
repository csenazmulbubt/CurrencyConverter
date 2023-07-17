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
    private var currencyList: [String: String] = [:]
    public var currencyListKeySorted: [String] = []
    @Published var status: ResoponseStatus<[CurrencyConvertModel]> = .loading("Loading")
    @Published var currencyListStatus: ResoponseStatus<[String :String]> = .loading("Loading")
    
    init(_ currencyServices: CurrencyServiceProtocol) {
        self.currencyServices = currencyServices
    }
    
    public func fetchCurrenciesList(URLRequestBuilder: URLRequestBuilder) -> Void {
        self.currencyServices.getCurrenciesList(
            URLRequestBuilder: URLRequestBuilder
        ).sink { completion in
            switch completion {
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
            self.currencyList = result
            self.currencyListKeySorted = result.keys.sorted(by: < )
            self.currencyListStatus = .success(result)
        }.store(in: &cancellables)
    }
    
    public func fetchLatestCurrencyRate(
        URLRequestBuilder: URLRequestBuilder,
        baseCurrency: String,
        amount: Double
    ) -> Void {
        
        self.currencyServices.getLatestCurrencyRates(
            URLRequestBuilder: URLRequestBuilder
        ).sink { completion in
            switch completion {
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
            print("Model",result.rates)
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
            from: self.getFullFormOfCurrency(key: from),
            to: self.getFullFormOfCurrency(key: to),
            rate: toRate.roundToDecimal(3),
            result: value.roundToDecimal(3)
        )
        self.currencyConvertModelArray.append(currencyModel)
        return value
    }
    
    private func getFullFormOfCurrency(key: String) -> String {
        if let value = self.currencyList[key] {
            return value + "(\(key))"
        }
        return key
    }
}
