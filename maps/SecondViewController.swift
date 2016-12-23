//
//  SecondViewController.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-22.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import UIKit

class SecondViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, RestaurantsDelegate {
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: Tableview Datasoure and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurants.restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "cell"
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as UITableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        }

        let restaurant = self.restaurants.restaurants[indexPath.row]
        if let restaurantDict = restaurant as? NSDictionary {
            let name = restaurantDict["Name"] as! String?
            cell?.textLabel?.text = name
            
            if let image = restaurants.imageForRestaurant(name: name!) {
                let itemSize = CGSize(width: 50.0, height: (cell?.frame.size.height)!)
                UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
                let imageRect = CGRect(x: 0.0, y: 0.0, width: itemSize.width, height: itemSize.height)
                cell?.imageView?.image = image
                cell?.imageView?.image!.draw(in: imageRect)
                cell?.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext();
            }

        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let restaurant = self.restaurants.restaurants[indexPath.row] as? NSDictionary {
            self.presentModal(restaurant: restaurant)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Restaurant Delegate

    func restaurantsDidFinishFetch(sender: Restaurants) {
        self.tableView.reloadData()
    }

}

