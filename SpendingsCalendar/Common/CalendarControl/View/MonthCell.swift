//
//  MonthCell.swift
//  CalendarControl
//
//  Created by Andrey Volobuev on 2/9/18.
//  Copyright © 2018 Andrey Volobuev. All rights reserved.
//

import UIKit


class MonthCell: UICollectionViewCell {
    
    weak var delegate: MonthCalendarDelegate?
    
    var leftPadding: CGFloat = 8
    var rightPadding: CGFloat = 8
    var topPadding: CGFloat = 8
    var bottomPadding: CGFloat = 8
    
    let cellWithReuseIdentifier = "DayCell"

    var dates = [DateViewModel]()
    var results = [Date]()
    
    let (collectionView, layout) = { () -> (UICollectionView, UICollectionViewFlowLayout) in
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = CGFloat.leastNormalMagnitude
        layout.minimumInteritemSpacing = CGFloat.leastNormalMagnitude
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = CalendarColors.background
        return (cv, layout)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let conatinerSize = frame.size
        let width = (conatinerSize.width - (leftPadding + rightPadding)) / 7.0
        let height = (conatinerSize.height - (topPadding + bottomPadding)) / 6.0
        let size = CGSize(width: width, height: height)
        layout.itemSize = size
    }
    
    func configureUI() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(DayCell.self, forCellWithReuseIdentifier: cellWithReuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: topAnchor, constant: topPadding).isActive = true
        collectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: leftPadding).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomPadding).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -rightPadding).isActive = true
    }
}

extension MonthCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelected(date: results[indexPath.row])
    }
}

extension MonthCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellWithReuseIdentifier, for: indexPath) as? DayCell
        let dateViewModel = dates[indexPath.row]
        cell?.configure(for: dateViewModel)
        return cell!
    }
}
