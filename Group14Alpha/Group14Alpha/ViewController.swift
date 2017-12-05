//
//  ViewController.swift
//  Group14Alpha
//
//  Created by Dennis Hannusch on 10/24/17.
//  Copyright © 2017 Group 14. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import CoreData
import Firebase

class ViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var primaryLoginButton: UIButton!
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        username.borderStyle = UITextBorderStyle.roundedRect
        password.borderStyle = UITextBorderStyle.roundedRect

        username.delegate = self
        password.delegate = self
        
        super.viewDidLoad()
        
        primaryLoginButton.setTitleColor(UIColor.gray, for: .disabled)
        primaryLoginButton.isEnabled = false
        username.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        password.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
    }
    
    @IBAction func customFBButton(_ sender: UIButton) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err)
                return
            }
            self.showEmailAddress()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "mapViewController")
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func signUpBtn(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "signUpViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.characters.count == 1 {
            if textField.text?.characters.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let username = username.text, !username.isEmpty,
            let password = password.text, !password.isEmpty
        else {
            primaryLoginButton.isEnabled = false
            return
        }
        primaryLoginButton.isEnabled = true
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func primaryLoginButton(_ sender: UIButton) {
        defaults.set("\(username)", forKey: "username")
        defaults.set("\(username)", forKey: "password")
        Auth.auth().signIn(withEmail: username.text!, password: password.text!, completion: {
            user, error in
            
            if error != nil{
                print("Incorrect Login Credentials")
                let alert = UIAlertController(title: "Oops", message: "The username or password you entered is incorrect", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                print("Logged In")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "mapViewController")
                self.present(vc, animated: true, completion: nil)
            }
        })
        
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("Segue to MAPVIEW")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "mapViewController")
        self.present(vc, animated: true, completion: nil)
        if error != nil {
            print(error)
            return
        }
    }

    func showEmailAddress() {
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            if err != nil {
                
                print("Failed to start graph request:", err!)
                return
            }
            print(result!)
        }
    }
}

