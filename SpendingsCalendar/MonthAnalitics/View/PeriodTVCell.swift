//
//  PeriodTVCell.swift
//  SpendingsCalendar
//
//  Created by Andrey Volobuev on 3/5/18.
//  Copyright © 2018 blob8129. All rights reserved.
//

import UIKit

class PeriodTVCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    func configure(for viewModel: PeriodViewModel) {
        typeLabel.text = viewModel.type
        periodLabel.text = viewModel.period
        amountLabel.text = viewModel.amount
        amountLabel.textColor = viewModel.isPositive == true ? Colors.positiveColor : Colors.negativeColor
    }
}
