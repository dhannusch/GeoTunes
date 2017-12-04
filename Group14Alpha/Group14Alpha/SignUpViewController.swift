//
//  SignUpViewController.swift
//  Group14Alpha
//
//  Created by Steven  Villarreal on 11/30/17.
//  Copyright © 2017 Group 14. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        firstName.borderStyle = UITextBorderStyle.roundedRect
        lastName.borderStyle = UITextBorderStyle.roundedRect
        email.borderStyle = UITextBorderStyle.roundedRect
        password.borderStyle = UITextBorderStyle.roundedRect
        
        firstName.resignFirstResponder()
        
        super.viewDidLoad()
        
        signUpBtn.setTitleColor(UIColor.gray, for: .disabled)
        signUpBtn.isEnabled = false
        firstName.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        lastName.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
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
            let lastName = lastName.text, !lastName.isEmpty,
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
