//
//  CustomCalloutView.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-22.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomCalloutView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var notes: UITextView!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var directionsButton: UIBarButtonItem!
    @IBOutlet weak var yelpButton: UIBarButtonItem!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        UIView.animate(withDuration: 0.65) {
            self.scrollView.backgroundColor = self.scrollView.backgroundColor?.withAlphaComponent(0.4)
        }
    }
    
    func setViewsWith(restaurant: Restaurant, image: UIImage?) {
        self.titleLabel.text = restaurant.name
        self.addressLabel.text = restaurant.address
        if var cost = restaurant.cost {
            let blueColor = UIColor.init(colorLiteralRed: 21.0/255, green: 126.0/255, blue: 251.0/255, alpha: 1.0) as UIColor
            let paragraphStyle = NSMutableParagraphStyle.init();
            paragraphStyle.alignment = .center;
            let attributedCost = NSMutableAttributedString(string: "$$$$", attributes: [ NSForegroundColorAttributeName: UIColor.lightGray, NSParagraphStyleAttributeName: paragraphStyle ])
            attributedCost.addAttribute(NSForegroundColorAttributeName, value:blueColor, range: NSRange.init(location: 0, length: cost.characters.count))
            
            self.costLabel.attributedText = attributedCost
        }
        if let rating = restaurant.rating {
            self.ratingLabel.text = NSNumber.init(value: rating).stringValue
        }

        if let notes = restaurant.notes {
            self.notes.text = notes
            self.notes.sizeToFit()
        }
    }
}
