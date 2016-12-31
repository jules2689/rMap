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

class BaseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, RestaurantsDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    var restaurants: RestaurantsApi!
    var selectedRestaurant:Restaurant? = nil
    var customView:CustomCalloutView? = nil
    var filter:Filter?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restaurants = RestaurantsApi.sharedInstance
        self.filter = Filter.sharedInstance
        
        // Delegate and property setup
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
        
        // Setup Searchbar Visuals
        self.searchController.searchBar.barTintColor = UIColor.init(colorLiteralRed: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1.0)
        self.searchController.searchBar.tintColor = .white
        self.searchController.searchBar.layer.borderWidth = 0
    }
    
    func presentModal(restaurant: Restaurant) {
        if let customView:CustomCalloutView = UINib(nibName: "CustomCalloutView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? CustomCalloutView {
            customView.setViewsWith(restaurant: restaurant, image: self.restaurants.imageForPicture(picture: (restaurant.pictures?[0])!))
            selectedRestaurant = restaurant

            // Setup Button Targets
            customView.closeButton.target = self
            customView.closeButton.action = #selector(closeButtonPressed)
            
            customView.directionsButton.target = self
            customView.directionsButton.action = #selector(directionsPressed)
            
            customView.yelpButton.target = self
            customView.yelpButton.action = #selector(viewOnYelpPressed)
            
            // Image Collection View
            customView.imageCollectionView.delegate = self
            customView.imageCollectionView.dataSource = self
            customView.imageCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionImageCell")
            customView.pageControl.numberOfPages = (selectedRestaurant?.pictures?.count)!
            customView.imageCollectionView.isScrollEnabled = customView.pageControl.numberOfPages > 1
            
            // Collection View Delegate/Datasource
            customView.collectionView.delegate = self
            customView.collectionView.dataSource = self
            customView.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
            customView.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader.self, withReuseIdentifier: "headerCell")
            customView.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter.self, withReuseIdentifier: "footerCell")
            
            var scrollEnabled = false
            if selectedRestaurant?.cuisine != nil {
                scrollEnabled = scrollEnabled || (selectedRestaurant?.cuisine?.count)! > 3
            }
            if selectedRestaurant?.diet != nil {
                scrollEnabled = scrollEnabled || (selectedRestaurant?.diet?.count)! > 3
            }
            customView.collectionView.isScrollEnabled = scrollEnabled
            
            // Frames and Presenteance
            customView.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.x + 100, width: self.view.frame.size.width, height: self.view.frame.size.height - 100)
            let modalViewController = UIViewController()
            modalViewController.view = customView
            modalViewController.modalPresentationStyle = .overCurrentContext
            
            customView.scrollView.delegate = self
            self.customView = customView
            self.present(modalViewController, animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func presentError(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        alert.modalPresentationStyle = .overCurrentContext
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.sync {
                UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Search Results
    
    public func updateSearchResults(for searchController: UISearchController) {
        self.filter?.filteredRestaurants = (filter?.filterRestaurants(searchText: searchController.searchBar.text!))!
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.filter?.filteredRestaurants = self.restaurants.restaurants
    }
    
    // MARK: Collection View Delegate/Datasource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 11 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionImageCell", for: indexPath) as UICollectionViewCell? {
                // Setup imageView
                let imageView = UIImageView()
                imageView.image = self.restaurants.imageForPicture(picture: (self.selectedRestaurant?.pictures?[indexPath.row])!)
                imageView.contentMode = UIViewContentMode.scaleAspectFill
                imageView.frame = cell.contentView.frame
                cell.contentView.clipsToBounds = true
                cell.contentView.addSubview(imageView)
                
                return cell
            }
        } else {
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
        }
        return UICollectionViewCell.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 11 {
            return (self.selectedRestaurant?.pictures?.count)!
        } else {
            // First section will always be cuisine if not nil/empty, otherwise it will be diet
            if section == 0 {
                if ((self.selectedRestaurant?.cuisine) != nil) && !(self.selectedRestaurant?.cuisine?.isEmpty)! {
                    return (self.selectedRestaurant?.cuisine?.count)!
                }
            }
            return (self.selectedRestaurant?.diet?.count)!
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == 11 {
            return 1
        } else {
            var sections = 0
            if ((self.selectedRestaurant?.cuisine) != nil) && !(self.selectedRestaurant?.cuisine?.isEmpty)! {
                sections += 1
            }
            if ((self.selectedRestaurant?.diet) != nil) && !(self.selectedRestaurant?.diet?.isEmpty)! {
                sections += 1
            }
            return sections
        }
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
    
    // MARK: Scroll View Delegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == customView?.imageCollectionView {
            let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
            self.customView?.pageControl.currentPage = Int(pageNumber)
            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width * pageNumber, y: 0)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == customView?.scrollView {
            if (scrollView.contentOffset.y < -120) {
                closeButtonPressed()
            }
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
                    self.presentError(message: "There was an error opening maps, could not construct url")
                }
            }
        }
    }
    
    func viewOnYelpPressed(sender: UIBarButtonItem) {
        if let urlPath = self.selectedRestaurant?.yelpUrl {
            if let url = NSURL(string: urlPath) {
                UIApplication.shared.openURL(url as URL)
            } else {
                self.presentError(message: "There was an error opening Yelp, could not construct url")
            }
        }
    }
    
    // MARK : Restaurants
    
    func restaurantsDidFetch(sender: RestaurantsApi) {
        self.filter?.setRestaurants(restaurants: sender.restaurants)
    }
    
    func restaurantsDidError(sender: RestaurantsApi, errorMessage: String) {
        self.presentError(message: errorMessage)
    }
}

