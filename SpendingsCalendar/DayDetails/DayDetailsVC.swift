//
//  DayDetailsVC.swift
//  SpendingsCalendar
//
//  Created by Andrey Volobuev on 3/7/18.
//  Copyright © 2018 blob8129. All rights reserved.
//

import UIKit

class DayDetailsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var transactionsByAccount = [String: [Transaction]]()
    private var accounts = [String]()
    private let periodsHeader = "PeriodsHeader"
    private lazy var dateFormatter: DateFormatter = { dateFormatter in
        dateFormatter.dateFormat = "E, d MMM yyyy"
        return dateFormatter
    }(DateFormatter())
    
    var date: Date?
    var transactions = [Transaction]() {
        didSet {
            transactionsByAccount =  Dictionary(grouping: transactions) { transaction in
                transaction.accountNumber
            }
            accounts = Array(transactionsByAccount.keys)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = date.flatMap { dateFormatter.string(from: $0) } ?? ""
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let nib = UINib(nibName: periodsHeader, bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: periodsHeader)
    }
    
    
    @IBAction func doneAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension DayDetailsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = accounts[section]
        return transactionsByAccount[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        let key = accounts[indexPath.section]
        if let transaction = transactionsByAccount[key]?[indexPath.row] {
            let amount = transaction.amount
            cell.textLabel?.textColor = amount > 0 ? Colors.positiveColor : Colors.negativeColor
            cell.textLabel?.text = String(format: amount.noZeroFormat(), amount)
            cell.detailTextLabel?.text = transaction.type
        }
        return cell
    }
}

extension DayDetailsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: periodsHeader) as? PeriodsHeaderView
        let account = accounts[section]
        let replaceRange = account.index(after: account.startIndex)..<account.index(account.endIndex, offsetBy: -2)
       // let stars = String((0..<account.count - 3).map { _ in "✱" })
        header?.headerLabel.text = account.replacingCharacters(in: replaceRange, with: account)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
}
