//
//  AudioPlayerViewController.swift
//  Group14Alpha
//
//  Created by Dennis Hannusch on 11/21/17.
//  Copyright © 2017 Group 14. All rights reserved.
//

import UIKit
import AVFoundation



class AudioPlayerViewController: UIViewController {
    var image = UIImage()
    var mainSongTitle = String()
    var mainPreviewURL = String()
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var playOrPauseBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songTitle.text = mainSongTitle
        background.image = image
        mainImageView.image = image
        downloadFileFromURL(url: URL(string: mainPreviewURL)!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadFileFromURL(url: URL){
        
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
            customURL, response, error in
            
            self.play(url: customURL!)
        })
        downloadTask.resume()
    }
    
    func play(url:URL){
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
        }
        catch{
            print(error)
        }
        
    }
    
    @IBAction func playOrPause(_ sender: AnyObject) {
        if player.isPlaying {
            player.pause()
            playOrPauseBtn.setTitle("Play", for: .normal)
        }
        else{
            player.play()
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
