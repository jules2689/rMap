//
//  SecondViewController.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-22.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import UIKit

class SecondViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, RestaurantsDelegate {

    @IBOutlet var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    var filteredRestaurants: NSArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.filteredRestaurants = self.restaurants.restaurants
        
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        self.searchController.searchBar.scopeButtonTitles = ["Name", "Diet", "Cuisine", "Cost"]
        self.searchController.searchBar.delegate = self
        self.tableView.tableHeaderView = self.searchController.searchBar
    }

    // MARK: Tableview Datasoure and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "customCell"
        let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as UITableViewCell?

        let restaurant = self.filteredRestaurants[indexPath.row]
        if let restaurantDict = restaurant as? NSDictionary {
            let name = restaurantDict["Name"] as! String?
            if let titleLabel = (cell?.viewWithTag(2) as? UILabel) {
                titleLabel.text = name
            }
            
            if let addressLabel = (cell?.viewWithTag(3) as? UILabel) {
                let address = restaurantDict["Address"] as! String?
                addressLabel.text = address
            }

            if let image = self.restaurants.imageForRestaurant(name: name!) {
                if let imageView = (cell?.viewWithTag(1) as? UIImageView) {
                    imageView.image = image
                }
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let restaurant = self.filteredRestaurants[indexPath.row] as? NSDictionary {
            if self.searchController.isActive {
                self.dismiss(animated: false, completion: nil)
            }
            self.presentModal(restaurant: restaurant)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Restaurant Delegate

    func restaurantsDidFinishFetch(sender: Restaurants) {
        self.tableView.reloadData()
    }
    
    // MARK: Search Results

    public func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.isEmpty {
            self.filteredRestaurants = self.restaurants.restaurants
        } else {
            let searchText = searchController.searchBar.text!.lowercased()
            let filtered = self.restaurants.restaurants.filter({
                if let dict = $0 as? NSDictionary {
                    let key = searchController.searchBar.scopeButtonTitles?[searchController.searchBar.selectedScopeButtonIndex]
                    if let val = dict[key! as String] as? String {
                        return val.lowercased().contains(searchText)
                    } else if let arrayVal = dict[key! as String] as? NSArray {
                        for val in arrayVal {
                            if (val as! String).lowercased().contains(searchText) {
                                return true
                            }
                        }
                    }
                }
                return false
            })
            self.filteredRestaurants = filtered as NSArray
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.filteredRestaurants = self.restaurants.restaurants
        tableView.reloadData()
    }

}

