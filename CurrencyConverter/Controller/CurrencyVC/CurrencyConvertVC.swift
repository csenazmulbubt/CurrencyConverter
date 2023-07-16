//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Nazmul on 14/07/2023.
//

import UIKit
import Combine

struct User: Codable {
    let name: String
    let age: String
    let fatherName: String
}

class CurrencyConvertVC: UIViewController {
    
    @IBOutlet weak var currencyConvertView: CurrencyConvertView!
   
    let model = CurrencyConvertViewModel(CurrencyServices(NetworkService()))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Date",(Double(1689501601).dateFormatted)?.intervalSince(isMoreThan: 30))
        _ = currencyConvertView.$tappedOnListCurrencyButton.sink { [weak self] isTapped in
            if isTapped {
                print("Tapped On Currency Button")
            }
        }
      
        let query = ["app_id": "83dd119769df4f25b57515e894149776"]
        let URLRequestBuilder = URLRequestBuilder(
            httpMethod: .get,
            host: .openExchangeRates,
            scheme: .https,
            endPath: OpenExchangeRequestPath.latest.path,
            queryParams: query
        )
       // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
            self.model.fetchLatestCurrencyRate(URLRequestBuilder: URLRequestBuilder)
        //})
    }
}

