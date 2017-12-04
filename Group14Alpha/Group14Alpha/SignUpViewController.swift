//
//  SignUpViewController.swift
//  Group14Alpha
//
//  Created by Steven  Villarreal on 11/30/17.
//  Copyright © 2017 Group 14. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    //@IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        firstName.borderStyle = UITextBorderStyle.roundedRect
        //lastName.borderStyle = UITextBorderStyle.roundedRect
        email.borderStyle = UITextBorderStyle.roundedRect
        password.borderStyle = UITextBorderStyle.roundedRect
        
        firstName.resignFirstResponder()
        
        super.viewDidLoad()
        
        signUpBtn.setTitleColor(UIColor.gray, for: .disabled)
        signUpBtn.isEnabled = false
        firstName.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        //lastName.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        email.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        password.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.characters.count == 1 {
            if textField.text?.characters.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let firstName = firstName.text, !firstName.isEmpty,
            //let lastName = lastName.text, !lastName.isEmpty,
            let email = email.text, !email.isEmpty,
            let password = password.text, !password.isEmpty
        else {
            signUpBtn.isEnabled = false
            return
        }
        signUpBtn.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func signUpAction(_ sender: Any) {
        
        Auth.auth().createUser(withEmail: email.text!, password: password.text!, completion: {
            user, error in
            print(error)
            if error != nil{
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    
                    switch errCode {
                    case .invalidEmail:
                        let alert = UIAlertController(title: "Oops", message: "Invalid Email", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        print("invalid email")
                    case .emailAlreadyInUse:
                        let alert = UIAlertController(title: "Oops", message: "Email Already In Use", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        print("in use")
                    case .weakPassword:
                        let alert = UIAlertController(title: "Weak Password", message: "Password should be at least six characters", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    default:
                        print("Create User Error: \(error!)")
                    }
                }
            }
            else{
                print("User Created")
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.firstName.text!
                changeRequest?.commitChanges { (error) in
                    // ...
                }
                
                let alert = UIAlertController(title: "SUCCESS", message: "Account created for \(String(describing: self.firstName.text!))", preferredStyle: .alert)
                let action = UIAlertAction(title: "Continue", style: .default) {action in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "mapViewController")
                    self.present(vc, animated: true, completion: nil)
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
                
            }
            
        })
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
