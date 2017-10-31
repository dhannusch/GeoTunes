//
//  MapViewController.swift
//  Group14Alpha
//
//  Created by Dennis Hannusch on 10/30/17.
//  Copyright © 2017 Group 14. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    
    let locManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        self.myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        mapView.setRegion(region, animated: true)
        
        self.mapView.showsUserLocation = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pinButton(_ sender: Any) {
        let myPin = MKPointAnnotation()
        myPin.coordinate = self.myLocation
        myPin.title = "My Pin"
        myPin.subtitle = "Play this song"
        mapView.addAnnotation(myPin)
        var pin:MKAnnotationView = MKAnnotationView()
        pin.annotation = myPin
        pin.canShowCallout = true
        pin.isEnabled = true
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
