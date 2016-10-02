//
//  MenuSectionHeaderView.swift
//  UCLA Radio
//
//  Created by Christopher Laganiere on 10/1/16.
//  Copyright © 2016 ChrisLaganiere. All rights reserved.
//

import Foundation
import UIKit

class MenuSectionHeaderView: UITableViewHeaderFooterView {
    
    let imageView = UIImageView(image: UIImage(named: "radio_wide"))
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.clear
        
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints(preferredConstraints())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func preferredHeight() -> CGFloat {
        return 80
    }
    
    fileprivate func preferredConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[image]|", options: [], metrics: nil, views: ["image": imageView])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[image]-(padding)-|", options: [], metrics: ["padding": Constants.Floats.menuOffset], views: ["image": imageView])
        
        return constraints
    }
    
}
