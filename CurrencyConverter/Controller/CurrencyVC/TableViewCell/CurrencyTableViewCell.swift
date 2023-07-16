//
//  CurrencyTableViewCell.swift
//  CurrencyConverter
//
//  Created by Nazmul on 16/07/2023.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var fromCurrencyLabelValue: UILabel!
    @IBOutlet weak var toCurrencyLabelValue: UILabel!
    @IBOutlet weak var rateLabelValue: UILabel!
    @IBOutlet weak var resultLabelValue: UILabel!
    
    static let cellIdentifier = "CurrencyTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setValue(
        from: String,
        to: String,
        rate: Double,
        result: Double
    ) -> Void {
        self.fromCurrencyLabelValue.text = from
        self.toCurrencyLabelValue.text = to
        self.rateLabelValue.text = "\(rate)"
        self.resultLabelValue.text = "\(result)"
    }
}
