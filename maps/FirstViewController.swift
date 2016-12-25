//
//  FirstViewController.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-22.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import UIKit
import Mapbox

class FirstViewController: BaseViewController, MGLMapViewDelegate, CLLocationManagerDelegate, RestaurantsDelegate {
    var locationManager: CLLocationManager!
    var mapView: MGLMapView!
    var hasLoadedLocation: Bool!

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
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.tintColor = .darkGray
        mapView.delegate = self;

        // Set the map’s center coordinate and zoom level.
        mapView.setCenter(CLLocationCoordinate2D(latitude: 40.69636800, longitude: -73.65382600), zoomLevel: 8, animated: false)
        view.addSubview(mapView)
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

    // MARK: Restaurant Delegates
    
    func restaurantsDidFinishFetch(sender restaurantsInstance: RestaurantsApi) {
        for restaurant in restaurantsInstance.restaurants {
            if (restaurant.latitude != nil && restaurant.longitude != nil) {
                let marker = CustomPointAnnotation()
                marker.coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude!, longitude: restaurant.longitude!)
                marker.title = restaurant.name
                marker.subtitle = restaurant.address
                marker.restaurant = restaurant;
                DispatchQueue.main.sync {
                    mapView.addAnnotation(marker)
                }
            }
        }
    }
}
