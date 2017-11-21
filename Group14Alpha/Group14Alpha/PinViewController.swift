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

class PinViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    var userDefaults: UserDefaults!
    
    @IBOutlet weak var spotTableView: UITableView!
    var searchURL = "https://api.spotify.com/v1/search?q=Kendrick+Lamar&type=track"
    typealias JSONStandard = [String : AnyObject]
    var names = [String]()
    
    @IBOutlet weak var pinColorPicker: UIPickerView!
    var colorData: [String] = [String]()
    @IBOutlet weak var pinMessage: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinMessage.delegate = self
        pinColorPicker.delegate = self
        pinColorPicker.dataSource = self
        self.colorData = ["Red","Green","Blue","Pink","Yellow","Orange","Purple","Black","White"]
        
        callAlamo(url: searchURL)

        // Do any additional setup after loading the view.
    }
    
    func callAlamo(url: String){
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
            
            self.parseData(JSONData: response.data!)
            
            
        })
    }
    
    func parseData(JSONData: Data){
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let tracks = readableJSON["tracks"] as? JSONStandard{
                if let items = tracks ["items"] as? [JSONStandard] {
                    for i in 0..<items.count{
                        let item = items[i]
                        
                        let name = item["name"] as! String
                        names.append(name)
                        
                        self.spotTableView.reloadData()
                    }
                }
            }
        }
        catch{
            print(error)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        cell?.textLabel?.text = names[indexPath.row]
        
        return cell!
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
    
    
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        print("Row: \(row)")
        print("Value: \(self.colorData[row])")
    }
    
    @IBAction func pinItButton(_ sender: Any) {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
