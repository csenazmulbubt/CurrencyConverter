//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Nazmul on 14/07/2023.
//

import UIKit

struct User: Codable {
    let name: String
    let age: String
    let fatherName: String
}

class CurrencyConvertVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Date",(Double(1689501601).dateFormatted)?.intervalSince(isMoreThan: 30))
    }
}

