//
//  CurrencyConverterViewModelTests.swift
//  CurrencyConverterTests
//
//  Created by Nazmul on 18/07/2023.
//

import XCTest
import Combine
@testable import CurrencyConverter

typealias CompletionHandler = (_ success: ResoponseStatus<[CurrencyConvertModel]>) -> Void

class CurrencyConverterViewModelTests: XCTestCase {
    
    let currencyConvertViewModel = CurrencyConvertViewModel(
        MockCurrencyServices (NetworkService()))
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchResultFromLocalFiles() throws {
        //Here is the test of CurrencyConvertModel and fetch result from local file
        var expectedModels = [CurrencyConvertModel]()
        currencyConvertViewModel.fetchLatestCurrencyRate(URLRequestBuilder: self.getRequestBuilder(fileName: "JPY"), baseCurrency: "JPY", amount: 10)
        let expectation = expectation(description: "expect models to get loaded")
        
        self.fetchResult { success in
            switch success {
            case .failure(_):
                break
            case .success(let models):
                expectedModels = models
                XCTAssertEqual(expectedModels.count, 7)
                expectation.fulfill()
                break
            case .loading(_):
                break
            }
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testCurrencyConvert() -> Void {
        //Test Currency Convert Result
        let expectation = expectation(description: "expected result are matches")
        let amount: Double = 10.0
        
        let keyForUSD = "USD" //Rate 0.0072 value from localFiles JPY.json
        let keyForAUD = "AUD" //Rate  0.011
        let keyForBDT = "BDT" // Rate 0.79
        
        let rateForUSD: Double = 0.0072
        let rateForAUD: Double = 0.011
        let rateForBDT: Double = 0.79
        
        let expectedResultForUSD = (rateForUSD * amount).roundToDecimal(3) //
        let expectedResultForAUD = (rateForAUD * amount).roundToDecimal(3)
        let expectedResultForBDT = (rateForBDT * amount).roundToDecimal(3)
        
        currencyConvertViewModel.fetchLatestCurrencyRate(
            URLRequestBuilder: self.getRequestBuilder(fileName: "JPY"),
            baseCurrency: "JPY",
            amount: amount )
        
        self.fetchResult { success in
            switch success {
            case .failure(_):
                break
            case .success(let currencyConvertModels):
                _ = currencyConvertModels.map { convertModel in
                    switch convertModel.to {
                    case keyForUSD:
                        XCTAssertEqual(convertModel.result, expectedResultForUSD)
                    case keyForAUD:
                        XCTAssertEqual(convertModel.result, expectedResultForAUD)
                    case keyForBDT:
                        XCTAssertEqual(convertModel.result, expectedResultForBDT)
                    default:
                        break
                    }
                }
                expectation.fulfill()
                break
            case .loading(_):
                break
            }
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testConvertedResultFromDifferntBaseCurrency() -> Void {
        //Test Currency Convert rate Result and all value from caluclated local files
        let expectation = expectation(description: "expected rate are matches")
        let amount: Double = 15.0
       
        let keyForUSD = "USD" //Rate 0.0072 value from localFiles JPY.json
        let keyForAUD = "AUD" //Rate  0.011
        let keyForBDT = "BDT" // Rate 0.79
        
        let bdtRate: Double = 0.79 //value get from local files
       
        let rateForUSD: Double = (0.0072 / bdtRate).roundToDecimal(3)
        let rateForAUD: Double = (0.011 / bdtRate).roundToDecimal(3)
        let rateForBDT: Double = (bdtRate / bdtRate).roundToDecimal(3)
        
        let expectedResultForUSD = (rateForUSD * amount).roundToDecimal(3) //
        let expectedResultForAUD = (rateForAUD * amount).roundToDecimal(3)
        let expectedResultForBDT = (rateForBDT * amount).roundToDecimal(3)
        
        currencyConvertViewModel.fetchLatestCurrencyRate(
            URLRequestBuilder: self.getRequestBuilder(fileName: "JPY"),
            baseCurrency: "BDT",
            amount: amount)
        
        self.fetchResult { success in
            switch success {
            case .failure(_):
                break
            case .success(let currencyConvertModels):
                _ = currencyConvertModels.map { convertModel in
                    switch convertModel.to {
                    case keyForUSD:
                        XCTAssertEqual(convertModel.rate, rateForUSD)
                        XCTAssertEqual(convertModel.result, expectedResultForUSD, accuracy: 0.95)
                    case keyForAUD:
                        XCTAssertEqual(convertModel.rate, rateForAUD)
                        XCTAssertEqual(convertModel.result, expectedResultForAUD, accuracy: 0.95)
                    case keyForBDT:
                        XCTAssertEqual(convertModel.rate, rateForBDT)
                        XCTAssertEqual(convertModel.result, expectedResultForBDT, accuracy: 0.95)
                    default:
                        break
                    }
                }
                expectation.fulfill()
                break
            case .loading(_):
                break
            }
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testFetchResultErrorCase() -> Void {
        //File name error show
        let expectation = expectation(description: "expected file not found")
        let error: ResoponseStatus<[CurrencyConvertModel]> = .failure("File Not Found")
        
        currencyConvertViewModel.fetchLatestCurrencyRate(
            URLRequestBuilder: self.getRequestBuilder(fileName: "XYZ"),
            baseCurrency: "BDT",
            amount: 20.0 )
        
        self.fetchResult { success in
            if success == error {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1.0)
        
    }
    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

extension CurrencyConverterViewModelTests {
    func getRequestBuilder(fileName: String) -> URLRequestBuilder {
        let pathURL = Bundle.main.url(forResource: fileName, withExtension: "json")
        
        return URLRequestBuilder(
            httpMethod: .get,
            host: .openExchangeRates,
            scheme: .https,
            mockBaseUrl: pathURL
        )
    }
    
    private func fetchResult(completion: @escaping CompletionHandler) -> Void {
        currencyConvertViewModel.$status.sink { status in
            completion(status)
       }.store(in: &cancellables)
    }

}
