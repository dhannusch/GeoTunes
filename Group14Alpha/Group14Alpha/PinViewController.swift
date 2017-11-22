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

var player = AVAudioPlayer()

struct post {
    let mainImage : UIImage!
    let name : String!
    let href : String!
    //let previewURL : String!
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
    //var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    var userDefaults: UserDefaults!
    
    @IBOutlet weak var spotTableView: UITableView!
    var searchURL = String()
    typealias JSONStandard = [String : AnyObject]
    var posts = [post]()
    
    @IBOutlet weak var pinColorPicker: UIPickerView!
    var colorData: [String] = [String]()
    @IBOutlet weak var pinMessage: UITextView!
    
    var newPin = NSManagedObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        self.newPin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context)

        
        pinMessage.delegate = self
        pinColorPicker.delegate = self
        pinColorPicker.dataSource = self
        self.colorData = ["Red","Green","Blue","Pink","Yellow","Orange","Purple","Black","White"]
        pinMessage.delegate = self
        callAlamo(url: searchURL)

        // Do any additional setup after loading the view.
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
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let tracks = readableJSON["tracks"] as? JSONStandard{
                if let items = tracks ["items"] as? [JSONStandard] {
                    for i in 0..<items.count{
                        let item = items[i]
                        
                        let name = item["name"] as! String
                        let href = item["href"] as! String
                        // 30 second preview of song
                        //let previewURL = item["preview_url"] as! String
                        if let album = item["album"] as? JSONStandard{
                            if let images = album["images"] as? [JSONStandard]{
                                let imageData = images[0]
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                
                                let mainImage = UIImage(data: mainImageData as! Data)
                                
                                //posts.append(post.init(mainImage: mainImage, name: name, previewURL: previewURL))
                                posts.append(post.init(mainImage: mainImage, name: name, href: href))
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        songSelectionURL = posts[indexPath.row].href
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.colorData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let str: String = self.colorData[row]
        return str
    }
    
    var pinColor = String()
    
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        print("Row: \(row)")
        print("Value: \(self.colorData[row])")
        pinColor = self.colorData[row]
    }
    var message = ""
    func textViewDidEndEditing(_ textView: UITextView) {
        self.message = pinMessage.text
    }
    
    @IBAction func pinItButton(_ sender: Any) {
        self.newPin.setValue(self.songSelectionURL, forKey: "song")
        self.newPin.setValue(self.message, forKey: "pinMessage")
        self.newPin.setValue(self.pinColor, forKey: "pinColor")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "mapViewController")
        self.present(vc, animated: true, completion: nil)
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
    
   
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.spotTableView.indexPathForSelectedRow?.row
        
        let vc = segue.destination as! AudioPlayerViewController
        
        vc.image = posts[indexPath!].mainImage
        vc.mainSongTitle = posts[indexPath!].name
        //vc.mainPreviewURL = posts[indexPath!].previewURL
        
    }
    */
    

}
