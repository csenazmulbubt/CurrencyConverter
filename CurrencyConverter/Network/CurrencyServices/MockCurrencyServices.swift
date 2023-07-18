//
//  MockCurrencyServices.swift
//  CurrencyConverter
//
//  Created by Nazmul on 18/07/2023.
//

import Foundation
import Combine

struct MockCurrencyServices: CurrencyServiceProtocol {
   
    
    var networkService: NetworkServiceProtocol
    
    init(_ networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getCurrenciesList(
        URLRequestBuilder: URLRequestBuilder
    ) -> AnyPublisher<[String: String], APIError> {
       
        return Just(
            [String : String]()
        ).setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }
    
    func getLatestCurrencyRates (
       URLRequestBuilder: URLRequestBuilder
       
    ) -> AnyPublisher<CurrencyModel, APIError> {
        
        guard  URLRequestBuilder.mockBaseUrl != nil else {
             return Fail(error: APIError.customErrorMessage(
                message: "MockURL Not Found")
           ).eraseToAnyPublisher()
        }
        return self.getLatestCurrencyRateLocalFile(URLRequestBuilder: URLRequestBuilder)
    }
    
    private func getLatestCurrencyRateLocalFile(
        URLRequestBuilder: URLRequestBuilder
    ) -> AnyPublisher<CurrencyModel, APIError> {
        
        guard let fileName = URLRequestBuilder.mockBaseUrl?.deletingPathExtension() else {
            return Fail(error: APIError.customErrorMessage(
               message: "MockURL Not Found")
          ).eraseToAnyPublisher()
        }
        do {
            let cachedResult = try CodableFiles.shared.load(
                fromBundle: Bundle.main,
                objectType: CurrencyModel.self,
                fileName: fileName.lastPathComponent
            )
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
