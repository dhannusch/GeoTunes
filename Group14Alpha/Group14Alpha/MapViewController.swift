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
import CoreData

//sdfasdfaskdfjlaskdfl;kasdf
extension MKPinAnnotationView {
    class func bluePinColor() -> UIColor {
        return UIColor.blue
    }
    
    class func redPinColor() -> UIColor {
        return UIColor.red
    }
    
    class func yellowPinColor() -> UIColor {
        return UIColor.yellow
    }
    
    class func pinkPinColor() -> UIColor {
        return UIColor.magenta
    }
    
    class func blackPinColor() -> UIColor {
        return UIColor.black
    }
    
    class func whitePinColor() -> UIColor {
        return UIColor.white
    }
    
    class func orangePinColor() -> UIColor {
        return UIColor.orange
    }
    
    class func greenPinColor() -> UIColor {
        return UIColor.green
    }
    
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    
    let locManager = CLLocationManager()
    
    let annotation = MKPointAnnotation()
    
    var pins = [NSManagedObject]()
    var song = ""
    var pinColor = ""
    var pinMessage = ""
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        self.myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        mapView.setRegion(region, animated: true)
        
        self.mapView.showsUserLocation = true
        
        //mapView.addAnnotation(annotation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //spotifyManager.authorize()
        mapView.delegate = self
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        /*
        //print(mapView)
        print(pinMessage)
        print(pinColor)
        print(song)
        annotation.coordinate = self.myLocation
        annotation.title = self.song
        annotation.subtitle = self.pinMessage
        mapView.addAnnotation(annotation)
        //print(annotation)
        print("Adding Pin!")
 */
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Pin")
        
        //
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = managedContext.fetch(fetchRequest) as? [NSManagedObject]
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        if let results = fetchedResults {
            pins = results
        } else {
            print("Could not fetch")
        }
        
        annotation.coordinate = self.myLocation
        annotation.title = song
        annotation.subtitle = pinMessage
        
        //if self.pinColor == "Yellow"{
            //MKPinAnnotationView.yellowPinColor()
        //}
        
        mapView.addAnnotation(annotation)
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pinButton(_ sender: Any) {
        annotation.coordinate = self.myLocation
        //annotation.title = "Pin"
        //annotation.subtitle = "Play this song"
        //print(mapView)
        //print(annotation)
        //mapView.addAnnotation(annotation)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "pinView")
        self.present(vc, animated: true, completion: nil)
         
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
            if self.pinColor == "Yellow"{
                annotationView?.pinTintColor = UIColor.yellow
            }
            else if self.pinColor == "Black"{
                annotationView?.pinTintColor = UIColor.black
            }
            else if self.pinColor == "White"{
                annotationView?.pinTintColor = UIColor.white
            }
            else if self.pinColor == "Blue"{
                annotationView?.pinTintColor = UIColor.blue
            }
            else if self.pinColor == "Red"{
                annotationView?.pinTintColor = UIColor.red
            }
            else if self.pinColor == "Green"{
                annotationView?.pinTintColor = UIColor.green
            }
            else if self.pinColor == "Purple"{
                annotationView?.pinTintColor = UIColor.magenta
            }
        } else {
            annotationView?.annotation = annotation
        }
        
        //self.mapView.addAnnotation(annotation)
        
        return annotationView
    }
    
    func savePin(_ song: String, pinMessage: String, pinColor: String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        // Create the entity we want to save
        let entity =  NSEntityDescription.entity(forEntityName: "Pin", in: managedContext)
        
        let pin = NSManagedObject(entity: entity!, insertInto:managedContext)
        
        // Set the attribute values
        pin.setValue(song, forKey: "song")
        pin.setValue(pinMessage, forKey: "pinMessage")
        pin.setValue(pinColor, forKey: "pinColor")
        
        
        // Commit the changes.
        do {
            try managedContext.save()
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        // Add the new entity to our array of managed objects
        pins.append(pin)
    }
    /*
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier("", sender: view)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? SecondViewController, let annotationView = sender as? MKPinAnnotationView {
            destination.annotation = annotationView.annotation as? MKPointAnnotation
        }
    }
    */
}
