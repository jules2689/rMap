//
//  Filter.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-25.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import Foundation

class Filter {
    var restaurants = Array<Restaurant>()
    var costs: [String: Bool] = [:]
    var cuisines: [String: Bool] = [:]
    var diets: [String: Bool] = [:]

    init(restaurants: Array<Restaurant>) {
        self.restaurants = restaurants
        let defaults = UserDefaults.standard

        for cost in ["$", "$$", "$$$"] {
            let key = "filter-cost-" + cost
            if defaults.object(forKey: key) != nil {
                self.costs[cost] = defaults.bool(forKey: key)
            } else {
                // Start Costs off as true
                self.costs[cost] = true
                defaults.set(true, forKey: key)
            }
        }
        
        let cuisines = filtered(filter: "Cuisine")
        for cuisine in cuisines {
            let key = "filter-cuisine-" + cuisine
            if defaults.object(forKey: key) != nil {
                self.cuisines[cuisine] = defaults.bool(forKey: key)
            } else {
                // Start Cuisines off as true
                self.cuisines[cuisine] = true
                defaults.set(true, forKey: key)
            }
        }

        let diets = filtered(filter: "Diet")
        for diet in diets {
            let key = "filter-diet-" + diet
            if defaults.object(forKey: key) != nil {
                self.diets[diet] = defaults.bool(forKey: key)
            } else {
                // Start Diets off as false
                self.diets[diet] = false
                defaults.set(false, forKey: key)
            }
        }
    }
    
    func filterRestaurants(searchText: String?) -> Array<Restaurant> {
        return self.restaurants.filter({
            var matches = true
            
            // Perform initial search
            if !(searchText?.isEmpty)! {
                let name = $0.name
                if let search = searchText {
                    matches = matches && (name?.lowercased().contains(search.lowercased()))!
                }
                if !matches { return false }
            }
            
            // Match agaisnt cost
            // Cost is an OR operation since we want to match against any of them
            var matchesCost = false
            for (cost, isEnabled) in costs {
                if isEnabled {
                    matchesCost = (matchesCost || cost == $0.cost)
                }
            }
            matches = matches && matchesCost
            if !matches { return false }
            
            // Match against cuisine
            // Cuisine is an OR operation to match against any, since most won't share cuisines
            var matchesCuisine = false
            for (cuisine, isEnabled) in cuisines {
                if isEnabled {
                    matchesCuisine = (matchesCuisine || ($0.cuisine?.contains(cuisine))!)
                }
            }
            matches = matches && matchesCuisine
            if !matches { return false }
            
            // Match against diets
            // Diet is an AND operation since you want to match agaisnt all of them
            var matchesDiet = true
            for (diet, isEnabled) in diets {
                if isEnabled {
                    matchesDiet = (matchesDiet && ($0.diet?.contains(diet))!)
                }
                if !matchesDiet { break }
            }
            matches = matches && matchesDiet
            
            return matches
        })
    }
    
    func isEnabled(section: String, option: String) -> Bool {
        switch section {
        case "Cost":
            return self.costs[option]!
        case "Cuisine":
            return self.cuisines[option]!
        case "Diet":
            return self.diets[option]!
        default:
            return false
        }
    }
    
    func toggle(section: String, option: String) {
        let defaults = UserDefaults.standard
        switch section {
            case "Cost":
                self.costs[option] = !self.costs[option]!
                defaults.set(self.costs[option], forKey: "filter-cost-" + option)
                break
            case "Cuisine":
                self.cuisines[option] = !self.cuisines[option]!
                defaults.set(self.cuisines[option], forKey: "filter-cuisine-" + option)
                break
            case "Diet":
                self.diets[option] = !self.diets[option]!
                defaults.set(self.diets[option], forKey: "filter-diet-" + option)
                break
            default:
                break
        }
    }

    private func filtered(filter: String) -> Array<String> {
        let filteredArray = self.restaurants.flatMap({ (restaurant) -> Array<String> in
            if let diets = ((restaurant as Restaurant).toJSON()["fields"] as! Dictionary<String, Any>)[filter] {
                return diets as! Array<String>
            }
            return []
        })
        return Array(Set(filteredArray)).sorted { $0 < $1 }
    }
}
