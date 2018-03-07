//
//  ViewController.swift
//  SpendingsCalendar
//
//  Created by Andrey Volobuev on 2/23/18.
//  Copyright © 2018 blob8129. All rights reserved.
//

import UIKit
import SbankenClient


class ViewController: UIViewController {
    
    private lazy var calendar = Calendar(identifier: .gregorian)
    private let today = Date()
    private lazy var transactionsService = TransactionsService()
    private let periodsHeader = "PeriodsHeader"
    
    @IBOutlet weak var maxWeekDayLabel: UILabel!
    @IBOutlet weak var minWeekDayLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendarControl: CalendarControl!
    
    private lazy var dateFormatter: DateFormatter = { dateFormatter in
        dateFormatter.dateFormat = "dd"
        return dateFormatter
    }(DateFormatter())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maxWeekDayLabel.isHidden = true
        minWeekDayLabel.isHidden = true 
        
        calendarControl.delegate = self
        calendarControl.setInitialState()
        tableView.dataSource = self
        tableView.delegate = self 
        transactionsService.delegate = self 
        
        let nib = UINib(nibName: periodsHeader, bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: periodsHeader)
    }

    private func setMaxDayOfTheWeek() {
        if let maxSavings = transactionsService.maxSpendingsWeekDay {
            maxWeekDayLabel.isHidden = maxSavings.amount >= 0.0
            let maxAmount = String(format: maxSavings.amount.noZeroFormat(), abs(maxSavings.amount))
            maxWeekDayLabel.text = "Max spending \(maxAmount) on \(maxSavings.weekDay)s"
        }
        if let maxSavings = transactionsService.maxSavingsWeekDay {
            minWeekDayLabel.isHidden = maxSavings.amount <= 0.0
            let maxAmount = String(format: maxSavings.amount.noZeroFormat(), abs(maxSavings.amount))
            minWeekDayLabel.text = "Max gains \(maxAmount) on \(maxSavings.weekDay)s"
        }
    }
}

extension ViewController: TransactionsServiceDelegate {
    func didLoadedTransactions() {
        calendarControl.unpdate()
        tableView.reloadData()
        setMaxDayOfTheWeek()
    }
}

extension ViewController: CalendarControlDelegate {
    
    func info(for date: Date) -> DayInfo? {
        let amount = transactionsService.getAmount(for: date)
        let position = transactionsService.getPosition(for: date)
        return DayInfo(amount: amount, position: position)
    }
    
    func didChanged(month: [[Date]]) {
        print("ℹ️ [INFO] 🗓 \(type(of: self)) \(#function) ")
        let filtredMonth = month.flatMap { $0 }.filter { date in
            let result = calendar.compare(date, to: today, toGranularity: .day)
            return result == .orderedAscending || result == .orderedSame
        }
        
        if let startDate = filtredMonth.first, let endDate = filtredMonth.last {
            transactionsService.getTransactionsForAllAcoounts(from: startDate, to: endDate)
        }
        
    }
    
    func didChanged(startDate: Date, endDate: Date) {
        
    }
    
    func didSelected(date: Date) {
        let transactions = transactionsService.getTransactions(for: date)
        guard transactions.isEmpty == false else { return }
        if let dayDetailsVC = insatantiateDetails() {
            dayDetailsVC.transactions = transactions
            dayDetailsVC.date = date 
            present(dayDetailsVC, animated: true, completion: nil)
        }
    }
    
    private func insatantiateDetails() -> DayDetailsVC? {
        return  UIStoryboard(name: "DayDetails", bundle: nil)
            .instantiateViewController(withIdentifier: "DayDetailsVC") as? DayDetailsVC
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionsService.periods.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionsService.periods[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodCell", for: indexPath) as? PeriodTVCell
        let period = transactionsService.periods[indexPath.section][indexPath.row]
    
        cell?.configure(for: period.toViewModel(using: dateFormatter))
        return cell!
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: periodsHeader) as? PeriodsHeaderView
        header?.headerLabel.text = section == 0 ? "Longest periods" : "All periods"
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
}

