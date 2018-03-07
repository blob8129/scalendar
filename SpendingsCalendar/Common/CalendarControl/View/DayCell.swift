//
//  DayCell.swift
//  CalendarControl
//
//  Created by Andrey Volobuev on 2/9/18.
//  Copyright © 2018 Andrey Volobuev. All rights reserved.
//

import UIKit

@IBDesignable
class DayCell: UICollectionViewCell {
    
    let boldFont = UIFont.systemFont(ofSize: 13, weight: .bold)
    let regulardFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    
    lazy var label: UILabel = { lbl in
        lbl.font = UIFont(name: "Helvetica", size: 13)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = CalendarColors.dark
        lbl.textAlignment = .center
        return lbl
    }(UILabel())
    
    lazy var infoLabel: UILabel = { lbl in
        lbl.font = UIFont(name: "Helvetica", size: 12)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        return lbl
    }(UILabel())
    
    lazy var leftView: UIView = { view in
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gray
        return view
    }(UIView())
    
    lazy var rightView: UIView = { view in
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gray
        return view
    }(UIView())
    
    lazy var dotImageView: UIImageView = { imageView in
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "SmallDot")
        return imageView
    }(UIImageView())

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUI()
    }
    
    func configureUI() {
        backgroundColor = UIColor.white
        let containerView = UIView()
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        addSubview(leftView)
        addSubview(rightView)
        addSubview(dotImageView)
        
        containerView.addSubview(label)
        containerView.addSubview(infoLabel)
        label.setContentHuggingPriority(UILayoutPriority(250), for: .vertical)
        infoLabel.setContentHuggingPriority(UILayoutPriority(251), for: .vertical)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),

            containerView.leftAnchor.constraint(equalTo: leftAnchor),
            containerView.rightAnchor.constraint(equalTo: rightAnchor),
            
            leftView.leftAnchor.constraint(greaterThanOrEqualTo: containerView.leftAnchor),
            leftView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            leftView.heightAnchor.constraint(equalToConstant: 2.0),
            leftView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: 1.0),
             
            rightView.rightAnchor.constraint(greaterThanOrEqualTo: containerView.rightAnchor),
            rightView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            rightView.heightAnchor.constraint(equalToConstant: 2.0),
            rightView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: 1.0),
             
            dotImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dotImageView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor),
            
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0),
            label.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0),
            
            infoLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 0),
            infoLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0),
            infoLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8)
        ])
    }
    
    func configure(for viewModel: DateViewModel) {
        label.font = viewModel.isInTargetMonth ? boldFont : regulardFont
        label.textColor = viewModel.isInTargetMonth ? CalendarColors.dark : UIColor.gray
        label.text = viewModel.date
        infoLabel.text = ""

        guard let info = viewModel.info else { return }

        switch info.position {
        case .first:
            leftView.isHidden = true
            dotImageView.isHidden = false
            rightView.isHidden = false
        case .firstAndLast:
            leftView.isHidden = true
            dotImageView.isHidden = false
            rightView.isHidden = true
        case .middle:
            leftView.isHidden = false
            dotImageView.isHidden = true
            rightView.isHidden = false
        case .last:
            leftView.isHidden = false
            dotImageView.isHidden = false
            rightView.isHidden = true
        case .none:
            leftView.isHidden = true
            dotImageView.isHidden = true
            rightView.isHidden = true
        }
        
        switch info.type {
        case .positive:
            set(color: Colors.positiveColor)
        case .negative:
            set(color: Colors.negativeColor)

        }
       
        infoLabel.text = info.info
    }
    
    private func set(color: UIColor) {
        leftView.backgroundColor = color
        dotImageView.tintColor = color
        rightView.backgroundColor = color
        infoLabel.textColor = color
    }
    
}
