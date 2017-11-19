//
//  SpotifyViewController.swift
//  Group14Alpha
//
//  Created by Dennis Hannusch on 11/14/17.
//  Copyright © 2017 Group 14. All rights reserved.
//

import UIKit

class SpotifyViewController: UIViewController {

    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        SPTAuth.defaultInstance().clientID = "3aaa2372c22e45a18901c0cfc5ee44e8"
        SPTAuth.defaultInstance().redirectURL = URL(string:"group14alpha://callback")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = SPTAuth.defaultInstance().spotifyAppAuthenticationURL()
        
    }
    
    @IBAction func spotifyLoginButton(_ sender: Any) {
        if UIApplication.shared.canOpenURL(loginUrl!) {
            if auth.canHandle(auth.redirectURL) {
                // To do - build in error handling
            }
        }
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
