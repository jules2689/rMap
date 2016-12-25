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

class BaseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var restaurants: RestaurantsApi!
    var selectedRestaurant:Restaurant? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restaurants = RestaurantsApi.sharedInstance
    }
    
    func presentModal(restaurant: Restaurant) {
        if let customView:CustomCalloutView = UINib(nibName: "CustomCalloutView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? CustomCalloutView {
            let name = restaurant.name
            customView.setViewsWith(restaurant: restaurant, image: self.restaurants.imageForRestaurant(name: name!))
            selectedRestaurant = restaurant

            // Setup Button Targets
            customView.closeButton.target = self
            customView.closeButton.action = #selector(closeButtonPressed)
            
            customView.directionsButton.target = self
            customView.directionsButton.action = #selector(directionsPressed)
            
            customView.yelpButton.target = self
            customView.yelpButton.action = #selector(viewOnYelpPressed)
            
            // Collection View Delegate/Datasource
            customView.collectionView.delegate = self
            customView.collectionView.dataSource = self
            customView.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
            customView.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader.self, withReuseIdentifier: "headerCell")
            customView.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter.self, withReuseIdentifier: "footerCell")
            
            // Frames and Presenteance
            customView.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.x + 100, width: self.view.frame.size.width, height: self.view.frame.size.height - 100)
            let modalViewController = UIViewController()
            modalViewController.view = customView
            modalViewController.modalPresentationStyle = .overCurrentContext
            self.present(modalViewController, animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Collection View Delegate/Datasource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as UICollectionViewCell? {
            // Setup Cell
            cell.contentView.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 122/255.0, blue: 255/255.0, alpha: 1.0)
            cell.layer.cornerRadius = 5
            cell.clipsToBounds = true
            
            // Setup Label
            let label = UILabel()
            if indexPath.section == 0 && ((self.selectedRestaurant?.cuisine) != nil) && !(self.selectedRestaurant?.cuisine?.isEmpty)! {
                label.text = self.selectedRestaurant?.cuisine?[indexPath.row]
            } else {
                label.text = self.selectedRestaurant?.diet?[indexPath.row]
            }
            label.textAlignment = .center
            label.textColor = .white
            label.frame = CGRect.init(x: 5, y: 0, width: cell.frame.size.width - 10, height: cell.frame.size.height)
            label.font = label.font.withSize(12)
            cell.contentView.addSubview(label)
            
            return cell
        }
        return UICollectionViewCell.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // First section will always be cuisine if not nil/empty, otherwise it will be diet
        if section == 0 {
            if ((self.selectedRestaurant?.cuisine) != nil) && !(self.selectedRestaurant?.cuisine?.isEmpty)! {
                return (self.selectedRestaurant?.cuisine?.count)!
            }
        }
        return (self.selectedRestaurant?.diet?.count)!
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        var sections = 0
        if ((self.selectedRestaurant?.cuisine) != nil) && !(self.selectedRestaurant?.cuisine?.isEmpty)! {
            sections += 1
        }
        if ((self.selectedRestaurant?.diet) != nil) && !(self.selectedRestaurant?.diet?.isEmpty)! {
            sections += 1
        }
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let reusableview:UICollectionReusableView? = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath)
            let label = UILabel()
            label.text = indexPath.section == 0 ? "Cuisines" : "Diets"
            label.textAlignment = .left
            label.textColor = .darkGray
            label.font = label.font.withSize(12)
            label.sizeToFit()
            reusableview?.addSubview(label)
            return reusableview!
        } else {
            let reusableview:UICollectionReusableView? = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerCell", for: indexPath)
            return reusableview!
        }
        
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

