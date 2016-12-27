//
//  SecondViewController.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-22.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import UIKit

class SecondViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, UIPopoverPresentationControllerDelegate, RestaurantsDelegate, RestaurantsFilterDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var filterControl: UISegmentedControl!
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredRestaurants = Array<Restaurant>()
    var filter:Filter?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.filter = Filter.init(restaurants: self.restaurants.restaurants)
        self.filteredRestaurants = (filter?.filterRestaurants(searchText: nil))!
        self.resetTitlesForFilterControl()
        
        // Delegate and property setup
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self

        // Setup Searchbar Visuals
        self.searchController.searchBar.barTintColor = UIColor.init(colorLiteralRed: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1.0)
        self.searchController.searchBar.tintColor = .white
        self.searchController.searchBar.layer.borderWidth = 0
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        // Hack to get the background to be "lead" color
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView?.backgroundColor = UIColor.init(colorLiteralRed: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1.0)
    }
    
    // MARK: Filter control
    
    @IBAction func filterControlDidChange(sender: AnyObject) {
        presentPopover()
    }
    
    // MARK: Popover
    
    func presentPopover() {
        if let popController = (self.storyboard?.instantiateViewController(withIdentifier: "RestaurantFilter"))! as? RestaurantFilterViewController {
            // Setup data, filters, and delegates
            popController.filterSection = self.filterControl.titleForSegment(at: self.filterControl.selectedSegmentIndex)?.replacingOccurrences(of: " •", with: "")
            popController.filter = self.filter
            popController.delegate = self

            // Setup popover settings
            popController.modalPresentationStyle = UIModalPresentationStyle.popover
            popController.popoverPresentationController?.passthroughViews = [self.filterControl]
            popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
            popController.popoverPresentationController?.delegate = self
            popController.popoverPresentationController?.sourceView = self.filterControl
            
            // Offset source rect to the proper segment
            let x = self.filterControl.frame.size.width / CGFloat(self.filterControl.numberOfSegments) * CGFloat(self.filterControl.selectedSegmentIndex)
            let frame = CGRect(x: x, y: 0, width: self.filterControl.frame.size.width / CGFloat(self.filterControl.numberOfSegments), height: self.filterControl.bounds.size.height)
            popController.popoverPresentationController?.sourceRect = frame
            
            // Dismiss any current popovers and show this one
            self.dismiss(animated: false, completion: nil)
            self.present(popController, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.filterControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }

    // MARK: Tableview Datasoure and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "customCell") as UITableViewCell?

        let restaurant = self.filteredRestaurants[indexPath.row]
        if let titleLabel = (cell?.viewWithTag(2) as? UILabel) {
            titleLabel.text = restaurant.name
        }
        
        if let addressLabel = (cell?.viewWithTag(3) as? UILabel) {
            addressLabel.text = restaurant.address
        }
        
        if let metadataLabel = (cell?.viewWithTag(4) as? UILabel) {
            var opts = Array<String>()
            if restaurant.rating != nil {
                opts.append(NSNumber.init(value: restaurant.rating!).stringValue)
            }
            if restaurant.cost != nil {
                opts.append(restaurant.cost!)
            }
            metadataLabel.text = opts.joined(separator: "   ")
        }

        if let image = self.restaurants.imageForPicture(picture: (restaurant.pictures?[0])!) {
            if let imageView = (cell?.viewWithTag(1) as? UIImageView) {
                imageView.image = image
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restaurant = self.filteredRestaurants[indexPath.row]
        if self.searchController.isActive {
            self.dismiss(animated: false, completion: nil)
        }
        self.presentModal(restaurant: restaurant)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Restaurant Delegate

    func restaurantsDidFetch(sender: RestaurantsApi) {
        self.tableView.reloadData()
    }
    
    func restaurantsDidError(sender: RestaurantsApi, errorMessage: String) {
        self.presentError(message: errorMessage)
    }
    
    func restaurantFilterViewDidFilter(sender: RestaurantFilterViewController) {
        self.filteredRestaurants = (filter?.filterRestaurants(searchText: searchController.searchBar.text!))!
        self.resetTitlesForFilterControl()
        tableView.reloadData()
    }
    
    func resetTitlesForFilterControl() {
        for i in 0...self.filterControl.numberOfSegments - 1 {
            let title = self.filterControl.titleForSegment(at: i)
            let baseTitle = title!.replacingOccurrences(of: " •", with: "")
            let filtered = (self.filter?.isSectionFiltered(section: baseTitle))!
            if filtered && !(title?.contains("•"))! {
                self.filterControl.setTitle(title! + " •", forSegmentAt: i)
            } else if !filtered {
                self.filterControl.setTitle(baseTitle, forSegmentAt: i)
            }
        }
    }

    // MARK: Search Results

    public func updateSearchResults(for searchController: UISearchController) {
        self.filteredRestaurants = (filter?.filterRestaurants(searchText: searchController.searchBar.text!))!
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.filteredRestaurants = self.restaurants.restaurants
        tableView.reloadData()
    }

}

