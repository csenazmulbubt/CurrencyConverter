//
//  NetworkService.swift
//  SampleShopAppMVVM
//
//  Created by Nazmul on 02/06/2023.
//

import Foundation
import Combine


class NetworkService: NSObject{
    override init() {
        
    }
}

//MARK: - NetworkServiceProtcol
extension NetworkService:  NetworkServiceProtocol {
    
    func sendGetRequest<T: Decodable> (
        URLReuquestBuilder: URLRequestBuilder,
        decodingType: T.Type
        
       ) -> AnyPublisher<T, APIError> {
        
        guard let urlRequest = URLReuquestBuilder.urlRequest else {
            return Fail(error: APIError.customErrorMessage(message: "oops url not found"))
                .eraseToAnyPublisher()
        }
        
        return self.sendRequestToServer(urlRequest: urlRequest,
                                 decodingType: decodingType)
    }
    
    private func sendRequestToServer<T: Decodable> (
        urlRequest: URLRequest,
        decodingType: T.Type
        
    ) -> AnyPublisher<T, APIError> {
        
        let JSONDecoder = JSONDecoder()
        JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw APIError.responseUnsuccessful
                }
                guard 200..<300 ~= response.statusCode else {
                    throw APIServiceError.getNetworError(statusCode: response.statusCode)
                }
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder)
            .mapError { error in
                // return error if json decoding fails
                APIError.jsonConversionFailure
            }
            .eraseToAnyPublisher()
    }
}

private extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
