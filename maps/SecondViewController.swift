//
//  SecondViewController.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-22.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RestaurantsDelegate {
    var restaurants: Restaurants!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        restaurants = Restaurants.sharedInstance
        restaurants.delegates.add(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.restaurants.count
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
        if let customView:CustomCalloutView = UINib(nibName: "CustomCalloutView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? CustomCalloutView {
            
            if let restaurant = self.restaurants.restaurants[indexPath.row] as? NSDictionary {
                let name = restaurant["Name"] as! String
                customView.setViewsWithAnnotation(restaurant: restaurant, image: restaurants.imageForRestaurant(name: name))
                customView.closeButton.target = self
                customView.closeButton.action = #selector(closeButtonPressed)
            }
            
            customView.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.x + 100, width: self.view.frame.size.width, height: self.view.frame.size.height - 100)
            
            let modalViewController = UIViewController()
            modalViewController.view = customView
            modalViewController.modalPresentationStyle = .overCurrentContext
            self.present(modalViewController, animated: true, completion: nil)
        }
    }
    
    func closeButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    

    func restaurantsDidFinishFetch(sender: Restaurants) {
        self.tableView.reloadData()
    }

}

