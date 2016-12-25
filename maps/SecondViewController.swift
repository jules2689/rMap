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
        self.filteredRestaurants = self.restaurants.restaurants
        self.filter = Filter.init(restaurants: self.restaurants.restaurants)
        
        // Delegate and property setup
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self

        // Setup Searchbar Visuals
        self.searchController.searchBar.barTintColor = UIColor.init(colorLiteralRed: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1.0)
        self.searchController.searchBar.layer.borderWidth = 0
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        // Hack to get the background to be "lead" color
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView?.backgroundColor = UIColor.init(colorLiteralRed: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1.0)
    }
    
    // MARK: Filter control
    
    @IBAction func filterControlDidChange(sender: AnyObject) {
        let selectedSegment = self.filterControl.titleForSegment(at: self.filterControl.selectedSegmentIndex)
        switch selectedSegment! {
        case "Cuisine":
            presentPopover()
            break
        case "Cost":
            presentPopover()
            break
        case "Diet":
            presentPopover()
            break
        default:
            presentPopover()
            break
        }
    }
    
    // MARK: Popover
    
    func presentPopover() {
        if let popController = (self.storyboard?.instantiateViewController(withIdentifier: "RestaurantFilter"))! as? RestaurantFilterViewController {
            // Setup data, filters, and delegates
            popController.filterSection = self.filterControl.titleForSegment(at: self.filterControl.selectedSegmentIndex)
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
        let reuseIdentifier = "customCell"
        let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as UITableViewCell?

        let restaurant = self.filteredRestaurants[indexPath.row]
        if let titleLabel = (cell?.viewWithTag(2) as? UILabel) {
            titleLabel.text = restaurant.name
        }
        
        if let addressLabel = (cell?.viewWithTag(3) as? UILabel) {
            addressLabel.text = restaurant.address
        }
        
        if let metadataLabel = (cell?.viewWithTag(4) as? UILabel) {
            var opts = Array<String>()
            if restaurant.cost != nil {
                opts.append(restaurant.cost!)
            }
            if restaurant.rating != nil {
                opts.append(NSNumber.init(value: restaurant.rating!).stringValue)
            }
            metadataLabel.text = opts.joined(separator: "   ")
        }

        if let image = self.restaurants.imageForRestaurant(name: restaurant.name) {
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

    func restaurantsDidFinishFetch(sender: RestaurantsApi) {
        self.tableView.reloadData()
    }
    
    func restaurantFilterViewDidFilter(sender: RestaurantFilterViewController) {
        self.filteredRestaurants = (filter?.filterRestaurants(searchText: searchController.searchBar.text!))!
        tableView.reloadData()
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

