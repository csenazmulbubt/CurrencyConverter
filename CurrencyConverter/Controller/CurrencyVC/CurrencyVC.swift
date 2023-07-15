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

class CurrencyVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func tappedOnButton(_ sender: UIButton) {
        let user = User(name: "Nazmul",
                        age: "DSDS",
                        fatherName: "Nazmul")
        
        let savePath = try? CodableFiles.shared.save(object: user, withFilename: "userModel")
        
        print("Save Path",savePath)
        
    }
    

}

