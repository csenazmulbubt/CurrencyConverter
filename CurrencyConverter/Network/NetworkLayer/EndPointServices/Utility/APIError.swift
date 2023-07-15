//
//  APIError.swift
//  SampleShopAppMVVM
//
//  Created by Nazmul on 02/06/2023.
//

import Foundation

enum APIError: Error {
    case invalidData
    case requestFailed
    case jsonConversionFailure
    case jsonParsingFailure
    case responseUnsuccessful
    case customErrorMessage(message: String)
    
    var localizedDescription: String {
        switch self {
        case .invalidData:
            return "Invalid Data"
        case .requestFailed:
            return "Request Failed"
        case .jsonConversionFailure:
            return "JSON Conversion Failure"
        case .jsonParsingFailure:
            return "JSON Parsing Failure"
        case .responseUnsuccessful:
            return "Response Unsuccessful"
        case .customErrorMessage(message: let message):
            return message
        }
    }
}

struct APIServiceError {
    
    static func getNetworError(statusCode: Int) -> APIError {
        switch statusCode {
        case 400:
            return APIError.customErrorMessage(message: "invalid_base!!, please select valid response")
        case 401:
            return APIError.customErrorMessage(message: "invalid_app_id !! please try again.")
        case 403:
            return APIError.customErrorMessage(message: "access_restricted !! please try again")
        case 404:
            return APIError.customErrorMessage(message: "not_found !! please try again")
        case 429:
            return APIError.customErrorMessage(message: "not_allowed !! please try again")
        case 503:
            return APIError.customErrorMessage(message: "Service unavailable")
        default:
            return APIError.customErrorMessage(message: "Something went wrong! please try again")
        }
    }
}
