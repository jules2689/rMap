//
//  SecondViewController.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-22.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import UIKit

protocol RestaurantsFilterDelegate: class {
    func restaurantFilterViewDidFilter(sender: RestaurantFilterViewController)
}

class RestaurantFilterViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    var filterSection: String? = nil
    var delegate:RestaurantsFilterDelegate?
    
    // MARK: Tableview Datasoure and Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var height = self.rows().count * Int(self.tableView.rowHeight) + 28
        
        let heightCutOff = Int(UIScreen.main.bounds.size.height * 0.67)
        if height > heightCutOff {
            height = heightCutOff
            self.tableView.isScrollEnabled = true
            self.tableView.showsVerticalScrollIndicator = true
        } else {
            self.tableView.isScrollEnabled = false
            self.tableView.showsVerticalScrollIndicator = false
        }

        self.preferredContentSize = CGSize(width: 300, height: height)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filterSection == "Diet" {
            return "Match all of:"
        }
        return "Match any of:"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "cell"
        let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as UITableViewCell?
        cell?.selectionStyle = .none
        cell?.textLabel?.text = rows()[indexPath.row]
        cell?.accessoryType = (filter?.isEnabled(section: filterSection!, option: self.rows()[indexPath.row]))! ? .checkmark : .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filter?.toggle(section: filterSection!, option: self.rows()[indexPath.row])
        self.tableView.reloadRows(at: [indexPath], with: .none)
        self.delegate?.restaurantFilterViewDidFilter(sender: self)
    }
    
    // MARK: Helpers
    
    func rows() -> Array<String> {
        if let fil = filter {
            if let filtered = self.filterSection {
                switch filtered {
                case "Cost":
                    return fil.costs.keys.elements.sorted { $0 < $1 }
                case "Cuisine":
                    return fil.cuisines.keys.elements.sorted { $0 < $1 }
                case "Diet":
                    return fil.diets.keys.elements.sorted { $0 < $1 }
                case "City":
                    return fil.cities.keys.elements.sorted { $0 < $1 }
                default:
                    return []
                }
            }
        }
        return []
    }
    
}

