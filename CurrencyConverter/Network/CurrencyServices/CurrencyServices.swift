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
        
        guard let data = UserDefaultManager.getData(with: Constants.lastApiCallTimeKey),
              let timeStamp = Double(data),
              let date = timeStamp.dateFormatted,
              !date.intervalSince(isMoreThan: 30) else {
            return self.getLatestCurrencyRateFormServer(URLRequestBuilder: URLRequestBuilder)
        }
        
        do {
            let cachedResult = try CodableFiles.shared.load(objectType: CurrencyModel.self, withFilename: Constants.jsonFileName, atDirectory: nil)
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
                withFilename: Constants.jsonFileName
            )
            UserDefaultManager.saveData (
                "\(response.timestamp)",
                key: Constants.lastApiCallTimeKey
            )
        })
        .eraseToAnyPublisher()
    }
}


