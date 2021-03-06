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
    var cities: [String: Bool] = [:]
    
    var filteredRestaurants = Array<Restaurant>()
    
    static let sharedInstance : Filter = {
        let instance = Filter()
        return instance
    }()

    func setRestaurants(restaurants: Array<Restaurant>) {
        self.restaurants = restaurants
        let defaults = UserDefaults.standard

        let costs = filtered(filter: "Cost")
        for cost in costs {
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
        
        let cities = filtered(filter: "City")
        for city in cities {
            let key = "filter-city-" + city
            if defaults.object(forKey: key) != nil {
                self.cities[city] = defaults.bool(forKey: key)
            } else {
                // Start Cuisines off as true
                self.cities[city] = true
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
        
        self.filteredRestaurants = self.filterRestaurants(searchText: nil)
    }
    
    func filterRestaurants(searchText: String?) -> Array<Restaurant> {
        return self.restaurants.filter({
            var matches = true
            
            // Perform initial search
            if searchText != nil {
                if !(searchText?.isEmpty)! {
                    let name = $0.name
                    if let search = searchText {
                        matches = matches && (name?.lowercased().contains(search.lowercased()))!
                    }
                    if !matches { return false }
                }
            }
                
            // Match agaisnt cost
            // Cost is an OR operation since we want to match against any of them
            if $0.cost != nil {
                var matchesCost = false
                for (cost, isEnabled) in costs {
                    if isEnabled {
                        matchesCost = (matchesCost || cost == $0.cost)
                    }
                }
                matches = matches && matchesCost
                if !matches { return false }
            }
            
            // Match against cuisine
            // Cuisine is an OR operation to match against any, since most won't share cuisines
            if $0.cuisine != nil {
                var matchesCuisine = false
                for (cuisine, isEnabled) in cuisines {
                    if isEnabled {
                        matchesCuisine = (matchesCuisine || ($0.cuisine?.contains(cuisine))!)
                    }
                }
                matches = matches && matchesCuisine
                if !matches { return false }
            }
            
            // Match against city
            // City is an OR operation to match against any, since they won't share cities
            if $0.city != nil {
                var matchesCity = false
                for (city, isEnabled) in cities {
                    if isEnabled {
                        matchesCity = (matchesCity || $0.city == city)
                    }
                }
                matches = matches && matchesCity
                if !matches { return false }
            }
            // Match against diets
            // Diet is an AND operation since you want to match agaisnt all of them
            if $0.diet != nil {
                var matchesDiet = true
                for (diet, isEnabled) in diets {
                    if isEnabled {
                        matchesDiet = (matchesDiet && ($0.diet?.contains(diet))!)
                    }
                    if !matchesDiet { break }
                }
                matches = matches && matchesDiet
            }
            
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
        case "City":
            return self.cities[option]!
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
            case "City":
                self.cities[option] = !self.cities[option]!
                defaults.set(self.cities[option], forKey: "filter-city-" + option)
                break
            default:
                break
        }
    }

    func isSectionFiltered(section: String) -> Bool {
        switch section {
        case "Cost":
            return Array<Bool>(self.costs.values).contains(false)
        case "Cuisine":
            return Array<Bool>(self.cuisines.values).contains(false)
        case "Diet":
            return Array<Bool>(self.diets.values).contains(true)
        case "City":
            return Array<Bool>(self.cities.values).contains(false)
        default:
            return false
        }
    }

    private func filtered(filter: String) -> Array<String> {
        let filteredArray = self.restaurants.flatMap({ (restaurant) -> Array<String> in
            if let filteredOptions = ((restaurant as Restaurant).toJSON()["fields"] as! Dictionary<String, Any>)[filter] {
                if let filteredString = filteredOptions as? String {
                    return [filteredString]
                } else {
                    return filteredOptions as! Array<String>
                }
            }
            return []
        })
        return Array(Set(filteredArray)).sorted { $0 < $1 }
    }
}
