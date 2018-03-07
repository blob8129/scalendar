
//
//  CalendarControl.swift
//  CalendarControl
//
//  Created by Andrey Volobuev on 2/9/18.
//  Copyright © 2018 Andrey Volobuev. All rights reserved.
//

import UIKit


struct CalendarColors {
    static let background = UIColor.white
    static let dark = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
    static let red = UIColor(red: 255/255, green: 97/255, blue: 129/255, alpha: 1.0)
}

extension Double {
    func noZeroFormat() -> String {
        let format: String
        if self.rounded(.down) == self  {
            format = "%.0f"
        } else if (self * 10).rounded(.down) == self * 10  {
            format = "%.1f"
        } else {
            format = "%.2f"
        }
        return format
    }
}

public protocol CalendarControlDelegate: MonthCalendarDelegate {
    func didChanged(month: [[Date]])
    func didChanged(startDate: Date, endDate: Date)
    
    func info(for date: Date) -> DayInfo?
}

public protocol MonthCalendarDelegate: class {
    func didSelected(date: Date)
}

//protocol Rotatable {
//    func rotate(from oldState: CalendarState, to newState: CalendarState)
//}
//
//extension UIButton: Rotatable {}

//extension Rotatable where Self: UIButton {
//
//    func swap() {
//        let image = self.image(for: .normal)
//        let selectedImage = self.image(for: .selected)
//        self.setImage(image, for: .selected)
//        self.setImage(selectedImage, for: .normal)
//    }
//
//    func rotate(from oldState: CalendarState, to newState: CalendarState) {
//        let angle: CGFloat
//
//        switch (oldState, newState) {
//        case (.expanded, .collapsed):
//            swap()
//            angle = -CGFloat.pi + 0.01
//        case (.collapsed, .expanded):
//            swap()
//            angle = -CGFloat.pi
//        default:
//            angle = 0
//        }
//
//        UIView.animate(withDuration: 0.4) {
//            self.transform = CGAffineTransform(rotationAngle: angle)
//        }
//
//        self.transform = CGAffineTransform.identity
//    }
//}

struct MonthCalendar {
    let month: Int
    let weeks: [[Date]]
}

@IBDesignable
public class CalendarControl: UIView {
    
    public weak var delegate: CalendarControlDelegate?
    private let calendarBundle = Bundle(for: CalendarControl.self)
    
    let textFont = UIFont(name: "Helvetica", size: 13)
    
    @IBInspectable
    var heightExpanded: CGFloat = 300
    
    @IBInspectable
    var isExpanded: Bool = true
    
    @IBInspectable
    var titleColor: UIColor = UIColor.black {
        didSet {
            titleLabel.textColor = titleColor
        }
    }
    
    private var state: State = State(state: .collapsed, currentDate: Date(), displayDate: Date()) {
        didSet {
            print("ℹ️ [INFO] 🗓 \(type(of: self)) \(#function) changed form:\n \(oldValue) to \(state) delegate \(delegate)")
            render(state: state)
            if oldValue.currentDate != state.currentDate {
                delegate?.didSelected(date: state.currentDate)
            }
            
         //   if oldValue.displayDate != state.displayDate {
                
                let month = calendarManager.monthCalendar(for: state.displayDate)
                delegate?.didChanged(month: month.weeks)
        //    }
          //  expandButton.rotate(from: oldValue.state, to: state.state)
        }
    }
    
    func unpdate() {
        collectionView.reloadData()
    }
    
    private func render(state: State) {
        animateStateChange(to: state)

        switch state.state {
        case .expanded(let animaned):
            scroll(to: state.displayDate, animaned: animaned)
            dateFormatter.dateFormat = expandedTitleDateFormat
        case .collapsed:
            dateFormatter.dateFormat = collapsedTitleDateFormat
        }
        titleLabel.text = dateFormatter.string(from: state.displayDate)
    }
    
    private let collapsedTitleDateFormat = "E dd MMMM"
    private let expandedTitleDateFormat = "MMMM yyyy"
    private let dayFormat = "dd"
    
    private var containerHeightConstraint: NSLayoutConstraint?
    private lazy var dateFormatter: DateFormatter = { formatter in
        return formatter
    }(DateFormatter())
    
    private let calendar = Calendar.current
    
    private let cellWithReuseIdentifier = "MonthCell"
    
    lazy var titleLabel: UILabel = { label in
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = textFont
        label.textAlignment = .center
        return label
    }(UILabel())
    
    private let containerView: UIView =  { view in
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.red
        return view
    }(UIView())
    
    private let (collectionView, layout): (UICollectionView, UICollectionViewFlowLayout)  = {
        let layout = UICollectionViewFlowLayout()
        var cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = CalendarColors.background
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        return (cv, layout)
    }()
    
    private let weekDaysView = UIView()
    
    private lazy var calendarManager: CalendarManager = {
        let today = Date()
        let startDate = calendar.date(byAdding: .year, value: -5, to: today) ?? today
        let endDate = calendar.date(byAdding: .year, value: 5, to: today) ?? today
        return CalendarManager(startDate: startDate, endDate: endDate)
    }()
    
    private lazy var setInitialDateOnce: Void = {
        let index = calendarManager.months(to: state.currentDate)
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }()
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let (width, height) = (containerView.frame.size.width, containerView.frame.size.height)
        weekDaysView.layoutIfNeeded()
        layout.itemSize = CGSize(width: width, height: height - weekDaysView.frame.height)
        
     //   expandButton.layer.cornerRadius = expandButton.frame.width / 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUI()
    }
    
    func setInitialState() {
        
        let initialCalendarState: CalendarState = isExpanded == true ? .expanded(animated: false) : .collapsed
        state = State(state: initialCalendarState, currentDate: Date(), displayDate: Date())
    }
    
    func configureUI() {
      
        titleLabel.textColor = titleColor
        collectionView.backgroundColor = CalendarColors.background
        collectionView.delegate = self
        collectionView.dataSource = self
       
        collectionView.register(MonthCell.self, forCellWithReuseIdentifier: cellWithReuseIdentifier)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let leftButton = UIButton(type: .system)
        leftButton.contentHorizontalAlignment = .left
        let leftButtonImage = UIImage(named: "ChevronLeft", in: calendarBundle, compatibleWith: nil)
        let rightButtonImage = UIImage(named: "ChevronRight", in: calendarBundle, compatibleWith: nil)
        
        
        leftButton.setImage(leftButtonImage, for: .normal)
        leftButton.tintColor = CalendarColors.dark
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.addTarget(self, action: #selector(previousAction), for: .touchUpInside)
        
        let rightButton = UIButton(type: .system)
        rightButton.contentHorizontalAlignment = .right
        rightButton.setImage(rightButtonImage, for: .normal)
        rightButton.tintColor = CalendarColors.dark
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        let panelView = UIView()
        panelView.backgroundColor = CalendarColors.background
        panelView.translatesAutoresizingMaskIntoConstraints = false

        weekDaysView.backgroundColor = CalendarColors.background
        weekDaysView.translatesAutoresizingMaskIntoConstraints = false

        let weekDaysStackView = UIStackView()
        weekDaysStackView.distribution = .fillEqually
        weekDaysStackView.alignment = .center
        weekDaysStackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(panelView)
        
        panelView.addSubview(leftButton)
        panelView.addSubview(titleLabel)
        panelView.addSubview(rightButton)
        
        addSubview(containerView)
        containerView.addSubview(weekDaysView)
        weekDaysView.addSubview(weekDaysStackView)
        
        ["Søn", "Man", "Tirs", "Ons", "Tor",  "Fre", "Lør"].map { weekDay -> UILabel in
                let label = UILabel()
                label.font = textFont
                label.textColor = CalendarColors.dark
                label.text = weekDay
                label.textAlignment = .center
                return label
            }.forEach { label in
                weekDaysStackView.addArrangedSubview(label)
        }
        
        containerView.addSubview(collectionView)

        panelView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        panelView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        panelView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        panelView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        
        leftButton.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)
        leftButton.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 0).isActive = true
        leftButton.leftAnchor.constraint(equalTo: panelView.leftAnchor, constant: 16).isActive = true
        leftButton.bottomAnchor.constraint(equalTo: panelView.bottomAnchor, constant: 0).isActive = true

        titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        titleLabel.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 0).isActive = true
        
        titleLabel.trailingAnchor.constraint(equalTo: rightButton.leadingAnchor, constant: 0).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: panelView.centerXAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: 0).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: panelView.bottomAnchor, constant: 0).isActive = true
        
        rightButton.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)
        rightButton.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 0).isActive = true
        rightButton.rightAnchor.constraint(equalTo: panelView.rightAnchor, constant: -16).isActive = true
        rightButton.bottomAnchor.constraint(equalTo: panelView.bottomAnchor, constant: 0).isActive = true

        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 0)

        containerView.topAnchor.constraint(equalTo: panelView.bottomAnchor, constant: 0).isActive = true
        containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        weekDaysView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        weekDaysView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        weekDaysView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        
        weekDaysStackView.topAnchor.constraint(equalTo: weekDaysView.topAnchor, constant: 0).isActive = true
        weekDaysStackView.leftAnchor.constraint(equalTo: weekDaysView.leftAnchor, constant: 8).isActive = true
        weekDaysStackView.rightAnchor.constraint(equalTo: weekDaysView.rightAnchor, constant: -8).isActive = true
        weekDaysStackView.bottomAnchor.constraint(equalTo: weekDaysView.bottomAnchor, constant: 0).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: weekDaysView.bottomAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        collectionView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
    }
    
    @objc func nextAction(_ sender: UIButton) {
        if let newState = state.advance(by: 1) {
            state = newState
        }
    }
    
    @objc func previousAction(_ sender: UIButton) {
        if let newState = state.advance(by: -1) {
            state = newState
        }
    }
    
    private func scroll(to date: Date, animaned: Bool = true) {
        let index = calendarManager.months(to: date)
        let indexPath = IndexPath(row: index, section: 0)
        print("ℹ️ [INFO] 🗓 \(type(of: self)) \(#function) will scroll to date: \(date) at index: \(index)")
        collectionView.scrollToItem(at: indexPath, at: .left, animated: animaned)
    }
    
    func animateStateChange(to newState: State) {
        switch newState.state {
        case .collapsed:
            containerHeightConstraint?.constant = 0
        case .expanded:
            containerHeightConstraint?.constant = heightExpanded
        }
        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        }
    }
    
    @objc func expandAction(_ sender: UIButton) {
        state = state.toggled()
    }

    func viewModels(for monthCalendar: MonthCalendar) -> [DateViewModel] {
        print("ℹ️ [INFO] 🗓 \(type(of: self)) \(#function)")
        
        return monthCalendar.weeks.flatMap { $0 }.map { date in
            dateFormatter.dateFormat = dayFormat
            let dateMonth = calendar.dateComponents([.month], from: date).month
            let info = self.delegate?.info(for: date)
            return DateViewModel(
                date: dateFormatter.string(from: date),
                isInTargetMonth: dateMonth == monthCalendar.month, info: info)
        }
    }
}

extension CalendarControl: UICollectionViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index =  collectionView.bounds.origin.x / collectionView.bounds.width
        if let date = calendarManager.dateByAddingToStartDate(numOfMonth: Int(index)) {
            state = State(state: state.state, currentDate: state.currentDate, displayDate: date)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        _ = setInitialDateOnce
    }
}

extension CalendarControl: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarManager.nuberOfMounths
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellWithReuseIdentifier, for: indexPath) as? MonthCell
        let dates = calendarManager.monthCalendar(at: indexPath.row)
        cell?.results = dates.weeks.flatMap { $0 }
        cell?.dates = viewModels(for: dates)
        cell?.delegate = self
        cell?.collectionView.reloadData()
        
        return cell!
    }
}

extension CalendarControl: MonthCalendarDelegate {
    
    public func didSelected(date: Date) {
        delegate?.didSelected(date: date)
    }
}
