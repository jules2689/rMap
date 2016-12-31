//
//  FirstViewController.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-22.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import UIKit
import Mapbox

class FirstViewController: BaseViewController, MGLMapViewDelegate, CLLocationManagerDelegate, RestaurantsFilterDelegate, UIPopoverPresentationControllerDelegate {
    var locationManager: CLLocationManager!
    var mapView: MGLMapView!
    @IBOutlet var mapContainerView: UIView!
    @IBOutlet var searchContainerView: UIView!
    var hasLoadedLocation: Bool!
    @IBOutlet var filterControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.restaurants.delegates.append(self)

        hasLoadedLocation = false
        mapView = MGLMapView(frame: self.view.bounds, styleURL:  MGLStyle.darkStyleURL(withVersion: 9))
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        mapView = MGLMapView(frame: self.view.bounds, styleURL:  MGLStyle.darkStyleURL(withVersion: 9))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.tintColor = .darkGray
        mapView.delegate = self;

        // Set the map’s center coordinate and zoom level.
        mapView.setCenter(CLLocationCoordinate2D(latitude: 40.69636800, longitude: -73.65382600), zoomLevel: 8, animated: false)
        self.mapContainerView.addSubview(mapView)
        self.searchContainerView.addSubview(self.searchController.searchBar)
        self.searchController.searchBar.sizeToFit()
        
        self.resetTitlesForFilterControl()
    }
    
    // MARK: Location Manager Delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if (!hasLoadedLocation) {
            let location = locations.last! as CLLocation
            mapView.setCenter(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), zoomLevel: 8, animated: false)
            
            hasLoadedLocation = true
        }
    }
    
    // MARK: MapView Delegates
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if let customAnnotation = annotation as? CustomPointAnnotation {
            self.presentModal(restaurant: customAnnotation.restaurant!)
        }
    }

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
    
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> UIView? {
        return nil
    }
    
    // MARK: Search Bar
    
    override public func updateSearchResults(for searchController: UISearchController) {
        super.updateSearchResults(for: searchController)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        resetMapMarkers()
    }
    
    override func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        super.searchBarCancelButtonClicked(searchBar)
        resetMapMarkers()
    }

    // MARK: Restaurant Delegates
    
    override func restaurantsDidFetch(sender: RestaurantsApi) {
        super.restaurantsDidFetch(sender: sender)
        resetMapMarkers()
    }

    // MARK: Map Markers
    
    func resetMapMarkers() {
        if self.mapView.annotations != nil {
            self.mapView.removeAnnotations(self.mapView.annotations!)
        }

        for restaurant in (self.filter?.filteredRestaurants)! {
            if (restaurant.latitude != nil && restaurant.longitude != nil) {
                let marker = CustomPointAnnotation()
                marker.coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude!, longitude: restaurant.longitude!)
                marker.title = restaurant.name
                marker.subtitle = restaurant.address
                marker.restaurant = restaurant;
                mapView.addAnnotation(marker)
            }
        }
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
    
    @objc(adaptivePresentationStyleForPresentationController:) func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.filterControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    func restaurantFilterViewDidFilter(sender: RestaurantFilterViewController) {
        self.filter?.filteredRestaurants = (filter?.filterRestaurants(searchText: self.searchController.searchBar.text))!
        resetMapMarkers()
    }
    
    @IBAction func filterControlDidChange(sender: AnyObject) {
        presentPopover()
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
}
