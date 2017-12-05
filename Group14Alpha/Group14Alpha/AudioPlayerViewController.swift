//
//  AudioPlayerViewController.swift
//  Group14Alpha
//
//  Created by Dennis Hannusch on 11/21/17.
//  Copyright © 2017 Group 14. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase


class AudioPlayerViewController: UIViewController {
    var pinID = String()
    var image = UIImage()
    var imageURL = String()
    var mainSongTitle = String()
    var mainPreviewURL = String()
    var trackURL = String()
    var message = String()
    var track: SPTTrack?
    var userEmail = String()
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var playOrPauseBtn: UIButton!
    @IBOutlet weak var messageView: UILabel!
    
    @IBOutlet weak var deletePinBtnOutlet: UIButton!
    @IBAction func deletePinButton(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to delete this pin?", message: "Press OK to delete", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .destructive){action in
            let databaseRef  = Database.database().reference()
            MediaPlayer.shared.pause()
            print("delete pin")
            databaseRef.child("Pins").child(self.pinID).removeValue()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "mapViewController")
            self.present(vc, animated: true, completion: nil)
        }
        let action2 = UIAlertAction(title:"Cancel", style: .cancel)
        alert.addAction(action)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MediaPlayer.shared.delegate = self
        MediaPlayer.shared.configurePlayer(authSession: LoginManager.shared.auth.session, id: LoginManager.shared.auth.clientID)
        
        songTitle.text = mainSongTitle
        let mainImageURL = URL(string: imageURL)
        let mainImageData = NSData(contentsOf: mainImageURL!)
        let mainImage = UIImage(data: mainImageData as! Data)
        background.image = mainImage
        mainImageView.image = mainImage
        messageView.text = message
        if userEmail == Auth.auth().currentUser?.email!{
            deletePinBtnOutlet.isHidden = false
        }
        else{
            deletePinBtnOutlet.isHidden = true
        }
        self.load(track: trackURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func load(track: String) {
        guard LoginManager.shared.isLogged else {return}
        MediaPlayer.shared.loadTrack(url: track) {[weak self] (track, error) in
            guard let `self` = self else {return}
            guard let track = track, error == nil else {
                self.showDefaultError()
                return
            }
            self.track = track
            self.play(t: track)
        }
    }
    
    func downloadFileFromURL(url: URL){
        
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
            customURL, response, error in
            
            //self.play(url: customURL!)
        })
        downloadTask.resume()
    }
    
    //func play(url:URL){
    func play(t: SPTTrack ){
        do {
//            player = try AVAudioPlayer(contentsOf: url)
//            player.prepareToPlay()
//            player.play()
            MediaPlayer.shared.play(track: t)
        }
        catch{
            print(error)
        }
        
    }
    
    @IBAction func playOrPause(_ sender: AnyObject) {
        //if player.isPlaying {
        if MediaPlayer.shared.isPlaying{
            //player.pause()
            MediaPlayer.shared.pause()
            playOrPauseBtn.setTitle("Play", for: .normal)
        }
        else{
            //player.play()
            MediaPlayer.shared.resume()
            playOrPauseBtn.setTitle("Pause", for: .normal)
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

extension AudioPlayerViewController: MediaPlayerDelegate {
    
    func mediaPlayerDidStartPlaying(track: SPTPartialTrack) {
        
    }
    
    func mediaPlayerDidChange(trackProgress: Double) {
        //progressSlider.setValue(Float(trackProgress), animated: true)
    }
    
    func mediaPlayerDidPause() {
        
    }
    
    func mediaPlayerDidResume() {
        
    }
    
    func mediaPlayerDidFail(error: Error) {
        showDefaultError()
        MediaPlayer.shared.pause()
        //updatePlayButton(playing: false)
    }
    
    func mediaPlayerDidFinishTrack() {
        //updatePlayButton(playing: false)
        //progressSlider.setValue(0, animated: false)
    }
    
    fileprivate func showDefaultError() {
        let alert = UIAlertController(title: "Oops", message: "Something went wrong. Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
