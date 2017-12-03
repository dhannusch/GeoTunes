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
import Firebase
import FirebaseDatabase

extension Date {
    /*
    func offsetFrom(date: Date) -> String {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);
        
        let seconds = "\(difference.second ?? 0)s"
        let minutes = "\(difference.minute ?? 0)m" + " " + seconds
        let hours = "\(difference.hour ?? 0)h" + " " + minutes
        let days = "\(difference.day ?? 0)d" + " " + hours
        
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        if let second = difference.second, second > 0 { return seconds }
        return ""
    }
    */
    
    func offsetFrom(date: Date, duration: Int) -> Bool {
        
        let Seconds: Set<Calendar.Component> = [.second]
        let difference = NSCalendar.current.dateComponents(Seconds, from: date, to: self);
        
        //let seconds = difference.second ?? 0
        if let second = difference.second, second > duration { return false }
        //if let second = difference.second, second > 0 { return seconds }
        return (true)
    }
}


struct PinStruct{
    let pinID : String!
    let longitude: Double!
    let latitude: Double!
    let song : String!
    let songURI : String!
    let albumCover: String!
    let message : String!
    let color : String!
    let time : Date!
    var dur : Double!
    
}

class GeoTuneAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var imageURL: String?
    var songURI: String?
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.subtitle = nil
        self.imageURL = nil
        self.songURI = nil
    }
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    
    let locManager = CLLocationManager()
    
    let annotation = MKPointAnnotation()
    
    var Pins = [PinStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        locManager.distanceFilter = 10.0
    }
    
    var color = ""
    
    
    ///func loadpins() -> [PinStruct] {
    func loadpins( p: [PinStruct]){
        var P = p
        let databaseRef  = Database.database().reference()
        databaseRef.child("Pins").queryOrderedByKey().observe(.childAdded, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as? NSDictionary
            let pinID = snapshot.key
            let longitude = snapshotValue?["longitude"] as? Double
            let latitude = snapshotValue?["latitude"] as? Double
            let song = snapshotValue?["song"] as? String
            let songURI = snapshotValue?["songURI"] as? String
            let albumCover = snapshotValue?["image"] as? String
            let message = snapshotValue?["message"] as? String
            self.color = (snapshotValue?["color"] as? String)!
            let time = snapshotValue?["time"] as? Double
            let newTime = Date(timeIntervalSince1970: time!)
            let dur = snapshotValue?["duration"] as? Double
            
            //let Seconds: Set<Calendar.Component> = [.second]
            let date = Date()
            let diff = date.timeIntervalSince(newTime)
            //let difference = NSCalendar.current.dateComponents(Seconds, from: newTime, to: date)
            //if let second = difference.second, second > dur!
            if diff>dur! && dur! != -1.0
            {
                // delete pin
                print("delete pin")
                databaseRef.child("Pins").child(pinID).removeValue()
                
            }
            else{
                // add pin to PinStruct
                print("adding to pin struct")
                
                self.Pins.append(PinStruct(pinID: pinID, longitude: longitude, latitude: latitude, song: song, songURI: songURI, albumCover: albumCover, message: message, color: self.color, time: newTime, dur: dur))
                P.append(PinStruct(pinID: pinID, longitude: longitude, latitude: latitude, song: song, songURI: songURI,albumCover: albumCover, message: message, color: self.color, time: newTime, dur: dur))
                //print("P.count:", P.count)
                //print("P[index]", P[0])
                
                //let newPin = MKPointAnnotation()
                let newPin = GeoTuneAnnotation()
                let newLocation = CLLocationCoordinate2DMake(latitude!,longitude!)
                newPin.coordinate = newLocation
                newPin.title = song
                newPin.subtitle = message
                newPin.imageURL = albumCover
                newPin.songURI = songURI
                let annotationView = self.mapView(self.mapView, viewFor: newPin)
                self.mapView.addAnnotation((annotationView?.annotation)!)
            }
            //self.mapView.reloadInputViews()
    
        })
    }
    /*
    func dropPins(PinList: [PinStruct]){
        print("pins.count:", PinList.count)
        
        for index in 0..<PinList.count{
            
            print("Pins[index].message:", PinList[index].message)
            //annotation.title = "Pin"
            //annotation.subtitle = "Play this song"
            //print(mapView)
            //print(annotation)
            //mapView.addAnnotation(annotation)
            
            let newPin = MKPointAnnotation()
            let newLocation = CLLocationCoordinate2DMake(PinList[index].latitude, PinList[index].longitude)
            newPin.coordinate = newLocation
            newPin.title = PinList[index].song
            newPin.subtitle = PinList[index].message
            let annotationView = self.mapView(self.mapView, viewFor: newPin)
            self.mapView.addAnnotation((annotationView?.annotation)!)
        }
        
    }
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadpins(p: Pins)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        self.myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        mapView.setRegion(region, animated: true)
        
        self.mapView.showsUserLocation = true
    }
    /*
    @IBAction func pinButton(_ sender: Any) {
        annotation.coordinate = self.myLocation
        //annotation.title = "Pin"
        //annotation.subtitle = "Play this song"
        //print(mapView)
        //print(annotation)
        //mapView.addAnnotation(annotation)
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "pinView")
        self.present(vc, animated: true, completion: nil)
         */
    }
 */
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
    
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin") as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
            
            if self.color == "Yellow"{
                annotationView?.markerTintColor = UIColor.yellow
            }
            else if self.color == "Black"{
                annotationView?.markerTintColor = UIColor.black
            }
            else if self.color == "White"{
                annotationView?.markerTintColor = UIColor.white
            }
            else if self.color == "Blue"{
                annotationView?.markerTintColor = UIColor.blue
            }
            else if self.color == "Red"{
                annotationView?.markerTintColor = UIColor.red
            }
            else if self.color == "Green"{
                annotationView?.markerTintColor = UIColor.green
            }
            else if self.color == "Purple"{
                annotationView?.markerTintColor = UIColor.magenta
            }
 
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    var thePin = GeoTuneAnnotation()
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        thePin = view.annotation as! GeoTuneAnnotation
        self.performSegue(withIdentifier: "detailView", sender: self)
    
    }
    /*
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
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "pinView"{
            let vc = segue.destination as! PinViewController
            vc.myLongitude = self.myLocation.longitude
            vc.myLatitude = self.myLocation.latitude
        }
        else{
            let vc = segue.destination as! AudioPlayerViewController
            vc.mainSongTitle = self.thePin.title!
            vc.imageURL = self.thePin.imageURL!
            vc.trackURL = self.thePin.songURI!
        }
    }
 
}
