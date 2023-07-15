//
//  NetworkServiceProtocol.swift
//  CurrencyConverter
//
//  Created by Nazmul on 15/07/2023.
//

import Foundation
import Combine

protocol NetworkServiceProtocol: AnyObject {
    
    func sendGetRequest<T: Decodable> (
        URLReuquestBuilder: URLRequestBuilder,
        decodingType: T.Type
        
    ) -> AnyPublisher<T, APIError>
    
    //TODO: Later Implement POST,PUT,DELTE Request
}
