//
//  CurrencyServices.swift
//  CurrencyConverter
//
//  Created by Nazmul on 16/07/2023.
//

import Foundation
import Combine


protocol CurrencyServiceProtocol {
    var networkService: NetworkServiceProtocol { get }
    
    /// Method to perform get latest currency rates
    func getLatestCurrencyRates(
        URLRequestBuilder: URLRequestBuilder
       ) -> AnyPublisher<CurrencyModel, APIError>
    
    /// Method to perform get latest currency list
    func getCurrenciesList(
        URLRequestBuilder: URLRequestBuilder
    ) -> AnyPublisher<[String: String], APIError>
}

struct CurrencyServices: CurrencyServiceProtocol {
   
    
    var networkService: NetworkServiceProtocol
    
    init(_ networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getCurrenciesList(
        URLRequestBuilder: URLRequestBuilder
    ) -> AnyPublisher<[String: String], APIError> {
       
        guard !isNeedToCallAPI(Constants.lastApiCallForCurrencyListKey) else {
            return self.getCurrenciesListFromServer(URLRequestBuilder: URLRequestBuilder)
        }
        return getCachedResult(
            decodingType: [String: String].self,
            fileName: Constants.currencyListFileName
        )
    }
    
    func getLatestCurrencyRates (
       URLRequestBuilder: URLRequestBuilder
       
    ) -> AnyPublisher<CurrencyModel, APIError> {
        
        guard !isNeedToCallAPI(Constants.lastApiCallForCurrencyRatesKey) else {
            return self.getLatestCurrencyRateFormServer(URLRequestBuilder: URLRequestBuilder)
        }
        return getCachedResult(
            decodingType: CurrencyModel.self,
            fileName: Constants.currencyRatesFileName
        )
    }
    
    private func getLatestCurrencyRateFormServer(
        URLRequestBuilder: URLRequestBuilder
    ) -> AnyPublisher<CurrencyModel, APIError> {
       
        if !NetworkManager.isNetworkAvailable {
            return Fail(error: APIError.customErrorMessage(
                     message: "Internet Not Available!!!")
                ).eraseToAnyPublisher()
        }
        return self.networkService.sendGetRequest (
            URLReuquestBuilder: URLRequestBuilder,
            decodingType: CurrencyModel.self
        )
        .handleEvents(receiveOutput: {  response in
            let _ = try? CodableFiles.shared.save(
                object: response,
                withFilename: Constants.currencyRatesFileName
            )
            UserDefaultManager.saveData (
                "\(response.timestamp)",
                key: Constants.lastApiCallForCurrencyRatesKey
            )
        })
        .eraseToAnyPublisher()
    }
    
    private func getCurrenciesListFromServer(
        URLRequestBuilder: URLRequestBuilder
    ) -> AnyPublisher<[String: String], APIError> {
        if !NetworkManager.isNetworkAvailable {
            return Fail(error: APIError.customErrorMessage(
                     message: "Internet Not Available!!!")
                ).eraseToAnyPublisher()
        }
        return self.networkService.sendGetRequest (
            URLReuquestBuilder: URLRequestBuilder,
            decodingType: [String: String].self
        )
        .handleEvents(receiveOutput: {  response in
            let _ = try? CodableFiles.shared.save(
                object: response,
                withFilename: Constants.currencyListFileName
            )
            let date = Date().timeIntervalSince1970
            UserDefaultManager.saveData (
                "\(date)",
                key: Constants.lastApiCallForCurrencyListKey
            )
        })
        .eraseToAnyPublisher()
    }
}


extension CurrencyServices {
    private func isNeedToCallAPI(_ key: String) -> Bool {
        guard let data = UserDefaultManager.getData(
            with: key
        ),
        let timeStamp = Double(data),
        let date = timeStamp.dateFormatted,
        !date.intervalSince(isMoreThan: 30) else { return true }
        return false
    }
    
    private func getCachedResult<T: Decodable>(
        decodingType: T.Type,
        fileName: String
    ) -> AnyPublisher<T, APIError>{
        do {
            let cachedResult = try CodableFiles.shared.load(objectType: T.self, withFilename: fileName, atDirectory: nil)
            return Just(
                cachedResult
            ).setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
            
        } catch let error {
            return Fail(
                error: APIError.customErrorMessage(message: error.localizedDescription)
            ).eraseToAnyPublisher()
        }
    }
}
