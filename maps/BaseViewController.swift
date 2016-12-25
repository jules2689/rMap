//
//  BaseViewController.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-23.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import Foundation

import UIKit
import CoreLocation

class BaseViewController: UIViewController {
    var restaurants: Restaurants!
    var selectedRestaurant:Restaurant? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restaurants = Restaurants.sharedInstance
    }
    
    func presentModal(restaurant: Restaurant) {
        if let customView:CustomCalloutView = UINib(nibName: "CustomCalloutView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? CustomCalloutView {
            let name = restaurant.name
            if let image = self.restaurants.imageForRestaurant(name: name!) {
                customView.setViewsWith(restaurant: restaurant, image: image)
            }
            customView.closeButton.target = self
            customView.closeButton.action = #selector(closeButtonPressed)
            
            customView.directionsButton.target = self
            customView.directionsButton.action = #selector(directionsPressed)
            
            customView.yelpButton.target = self
            customView.yelpButton.action = #selector(viewOnYelpPressed)
            
            selectedRestaurant = restaurant
            
            customView.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.x + 100, width: self.view.frame.size.width, height: self.view.frame.size.height - 100)
            
            let modalViewController = UIViewController()
            modalViewController.view = customView
            modalViewController.modalPresentationStyle = .overCurrentContext
            self.present(modalViewController, animated: true, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.selectedRestaurant != nil
    }
    
    // MARK: Button Actions
    
    func closeButtonPressed() {
        self.selectedRestaurant = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    func directionsPressed(sender: UIBarButtonItem) {
        if let latitude = self.selectedRestaurant?.latitude {
            if let longitude = self.selectedRestaurant?.longitude {
                var query = "?ll=\(latitude),\(longitude)"
                if let address = self.selectedRestaurant?.address {
                    let encodedName = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    query = "&q=" + encodedName!

                }
                let path = "http://maps.apple.com/" + query
                if let url = NSURL(string: path) {
                    UIApplication.shared.openURL(url as URL)
                } else {
                    // Could not construct url. Handle error.
                }
            }
        }
    }
    
    func viewOnYelpPressed(sender: UIBarButtonItem) {
        if let urlPath = self.selectedRestaurant?.yelpUrl {
            if let url = NSURL(string: urlPath) {
                UIApplication.shared.openURL(url as URL)
            } else {
                // Could not construct url. Handle error.
            }
        }
    }
}

