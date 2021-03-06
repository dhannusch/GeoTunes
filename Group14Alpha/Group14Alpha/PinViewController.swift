//
//  PinViewController.swift
//  Group14Alpha
//
//  Created by Dennis Hannusch on 11/19/17.
//  Copyright © 2017 Group 14. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AVFoundation
import Firebase
import FirebaseDatabase
import MapKit


var player = AVAudioPlayer()

struct post {
    let mainImage : UIImage!
    let imageURL : String!
    let name : String!
    let uri : String!
}

class PinViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var spotSearchBar: UISearchBar!
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let keywords = searchBar.text
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "+")
        
        searchURL = "https://api.spotify.com/v1/search?q=\(finalKeywords!)&type=track"
        
        print(searchURL)
        
        callAlamo(url: searchURL)
        self.view.endEditing(true)
    }

    
    var auth = SPTAuth.defaultInstance()!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    var userDefaults: UserDefaults!
    
    @IBOutlet weak var spotTableView: UITableView!
    var searchURL = String()
    typealias JSONStandard = [String : AnyObject]
    var posts = [post]()
    
    @IBOutlet weak var pinColorPicker: UIPickerView!
    var colorData: [String] = [String]()
    
    @IBOutlet weak var durationPicker: UIPickerView!
    var durationData: [String] = [String]()
    
    @IBOutlet weak var pinMessage: UITextView!
    
    @IBOutlet weak var pinItButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinMessage.delegate = self
        pinColorPicker.delegate = self
        pinColorPicker.dataSource = self
        self.colorData = ["Red","Green","Blue","Yellow","Orange","Purple","Black","White"]
        self.durationData = ["30 Seconds", "1 Hour", "1 Day", "1 Week", "Forever"]
        pinMessage.delegate = self
        callAlamo(url: searchURL)
        
        pinItButton.setTitleColor(UIColor.gray, for: .disabled)
        pinItButton.isEnabled = false
    }
    
    func callAlamo(url: String){
        Alamofire.request(searchURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+auth.session.accessToken]).responseJSON {
            response in
            print(response);
            self.parseData(JSONData: response.data!)
        }
    }
    
    func parseData(JSONData: Data){
        do {
            self.posts.removeAll()
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let tracks = readableJSON["tracks"] as? JSONStandard{
                if let items = tracks ["items"] as? [JSONStandard] {
                    for i in 0..<items.count{
                        let item = items[i]
                        
                        let name = item["name"] as! String
                        let uri = item["uri"] as! String
                        
                        //var track = item["external_urls"] as? JSONStandard
                        //let uri = track!["spotify"] as! String
                        //var uri = ""
                        //if item["preview_url"] as? String != nil{
                        //   uri = item["preview_url"] as! String
                        //}
                        //print("uri: \(uri)")
                        // 30 second preview of song
                        //let previewURL = item["preview_url"] as! String
                        if let album = item["album"] as? JSONStandard{
                            if let images = album["images"] as? [JSONStandard]{
                                let imageData = images[0]
                                let mainImageURLString = imageData["url"] as! String
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                
                                let mainImage = UIImage(data: mainImageData as! Data)
                                
                                //posts.append(post.init(mainImage: mainImage, name: name, previewURL: previewURL))
                                posts.append(post.init(mainImage: mainImage, imageURL: mainImageURLString, name: name, uri: uri))
                                self.spotTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        catch{
            print(error)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        
        mainImageView.image = posts[indexPath.row].mainImage
        
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        
        mainLabel.text = posts[indexPath.row].name
        return cell!
    }
    
    var songSelectionURL = String()
    var imageChosen = UIImage()
    var imageURL = String()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pinItButton.isEnabled = true
        
        self.songSelectionURL = posts[indexPath.row].name
        self.imageChosen = posts[indexPath.row].mainImage
        self.imageURL = posts[indexPath.row].imageURL
        self.songURI = posts[indexPath.row].uri
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1{
            return self.colorData.count
        }
        else{
            return self.durationData.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1{
            let str: String = self.colorData[row]
            return str
        }
        else{
            let str: String = self.durationData[row]
            return str
        }
    }
    
    var pinColor = String()
    var duration = String()
    
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        
        if pickerView.tag == 1{
            print("Row: \(row)")
            print("Value: \(self.colorData[row])")
            pinColor = self.colorData[row]
        }
        else{
            print("Row: \(row)")
            print("Value: \(self.durationData[row])")
            self.duration = self.durationData[row]
        }
    }
    var message = ""
    func textViewDidEndEditing(_ textView: UITextView) {
        self.message = pinMessage.text
    }
    
    @IBAction func pinItButton(_ sender: Any) {
        addPin()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 'First Responder' is the same as 'input focus'.
        // We are removing input focus from the text field.
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    var myLongitude : Double!
    var myLatitude: Double!
    var songURI: String!
    
    func addPin(){
        let longitude = self.myLongitude
        let latitude = self.myLatitude
        let song = self.songSelectionURL
        let songURI = self.songURI
        let image = self.imageURL
        let message = self.pinMessage.text
        let color = self.pinColor
        let email = Auth.auth().currentUser?.email!
        let displayName = Auth.auth().currentUser?.displayName!
        //let time = Date()
        let time = Date().timeIntervalSince1970 as Double!
        var dur = 0.0
        // dur is in seconds
        if self.duration == "Forever"{
            dur = -1
        }
        else if self.duration == "1 Hour"{
            dur = 3600.0
        }
        else if self.duration == "1 Day"{
            dur = 86400.0
        }
        else if self.duration == "1 Week"{
            dur = 604800.0
        }
        else{
            dur = 30.0
        }
        
        let databaseRef  = Database.database().reference()
        
        let pinID = databaseRef.child("Pins").childByAutoId().key
        let pinIDref = databaseRef.child("Pins").childByAutoId()
        
        let pin : [String: AnyObject] = ["pinID": pinID as AnyObject, "email": email as AnyObject, "longitude": longitude as AnyObject, "latitude": latitude as AnyObject, "song": song as AnyObject, "songURI": songURI as AnyObject, "image": image as AnyObject, "message": message! as AnyObject, "color": color as AnyObject, "time": time as AnyObject, "duration": dur as AnyObject, "displayName": displayName as AnyObject]
        
        pinIDref.setValue(pin)
        
    }
}
