//
//  CurrencyConvertViewModel.swift
//  CurrencyConverter
//
//  Created by Nazmul on 16/07/2023.
//

import Foundation
import Combine


typealias ResultBlock<T> = (Result <T, APIError>) -> Void

class CurrencyConvertViewModel: ObservableObject {
    
    private let currencyServices: CurrencyServiceProtocol
    @Published var status: ResoponseStatus<CurrencyModel> = .loading("Loading")
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ currencyServices: CurrencyServiceProtocol) {
        self.currencyServices = currencyServices
    }
    
    func fetchLatestCurrencyRate(URLRequestBuilder: URLRequestBuilder) -> Void {
        self.currencyServices.getLatestCurrencyRates(
            URLRequestBuilder: URLRequestBuilder
        ).sink { completion in
            switch completion {
            case .failure(let error):
                print("Some thing went wrong",error.localizedDescription)
            case .finished:
                print("Finished")
            }
        } receiveValue: { result in
            print("Result",result)
        }.store(in: &cancellables)
    }
}
