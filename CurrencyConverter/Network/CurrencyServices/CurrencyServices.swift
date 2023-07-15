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
}


struct CurrencyServices: CurrencyServiceProtocol {
    var networkService: NetworkServiceProtocol
    
    init(_ networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getLatestCurrencyRates(
       URLRequestBuilder: URLRequestBuilder
    ) -> AnyPublisher<CurrencyModel, APIError> {
        
        if !NetworkManager.isNetworkAvailable {
            return Fail(error: APIError.customErrorMessage(
                     message: "Internet Not Availbale!!!")
                ).eraseToAnyPublisher()
        }
        return self.networkService.sendGetRequest (
            URLReuquestBuilder: URLRequestBuilder,
            decodingType: CurrencyModel.self
        )
        .handleEvents(receiveOutput: {  response in
                print("Response",response.rates)
        })
        .eraseToAnyPublisher()
    }
}


