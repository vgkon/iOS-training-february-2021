//
//  HeaderCollectionReusableView.swift
//  iOSMovieApp
//
//  Created by Δημητρα Παπουλια on 3/6/21.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {

    static let identifier = "HeaderCollectionReusableView"
    
    var label: UILabel = {
        let label = UILabel()
        label.textColor = .systemYellow
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    public func configure(){
        addSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds

    }
    
}
