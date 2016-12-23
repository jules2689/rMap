//
//  FirstViewController.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-22.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import UIKit
import Mapbox

class FirstViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, RestaurantsDelegate {
    var locationManager: CLLocationManager!
    var mapView: MGLMapView!
    var hasLoadedLocation: Bool!
    var restaurants: Restaurants!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        restaurants = Restaurants.sharedInstance
        restaurants.delegates.add(self)

        hasLoadedLocation = false
        mapView = MGLMapView(frame: view.bounds)
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self;

        // Set the map’s center coordinate and zoom level.
        mapView.setCenter(CLLocationCoordinate2D(latitude: 40.69636800, longitude: -73.65382600), zoomLevel: 8, animated: false)
        view.addSubview(mapView)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if (!hasLoadedLocation) {
            let location = locations.last! as CLLocation
            mapView.setCenter(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), zoomLevel: 8, animated: false)
            hasLoadedLocation = true
        }
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if let customView:CustomCalloutView = UINib(nibName: "CustomCalloutView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? CustomCalloutView {
            
            if let customAnnotation = annotation as? CustomPointAnnotation {
                customView.setViewsWithAnnotation(customAnnotation: customAnnotation)
                customView.closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
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
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped
        return false
    }
    
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> UIView? {
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        // Optionally handle taps on the callout
        print("Tapped the callout for: \(annotation)")
        
        // Hide the callout
        mapView.deselectAnnotation(annotation, animated: true)
    }
    
    func restaurantsDidFinishFetch(sender restaurantsInstance: Restaurants) {
        for restaurant in restaurantsInstance.restaurants {
            if let restaurantDict = restaurant as? NSDictionary {
                if (restaurantDict.object(forKey: "Latitude") != nil && restaurantDict.object(forKey: "Longitude") != nil) {
                    let marker = CustomPointAnnotation()
                    marker.coordinate = CLLocationCoordinate2D(latitude: restaurantDict["Latitude"] as! Double, longitude: restaurantDict["Longitude"] as! Double)
                    marker.title = restaurantDict["Name"] as? String
                    marker.subtitle = restaurantDict["Address"] as? String
                    marker.restaurant = restaurantDict;
                    DispatchQueue.main.sync {
                        mapView.addAnnotation(marker)
                    }
                }
            }
            
        }
        
    }
}
