//
//  PlayerVC.swift
//  PlayerTest
//
//  Created by Lourenço Gomes on 24/07/2021.
//

import UIKit

class PlayerVC : UIViewController {
    
    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelChapter: UILabel!
    @IBOutlet weak var dayOfTheWeek: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var labelTimeEleapsed: UILabel!
    @IBOutlet weak var labelTimePlayed: UILabel!
    @IBOutlet var sliderPosition: UISlider!
    
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var buttonPlayPausePressed: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    
    var playerHandler : PlayerHandler = PlayerHandler()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        playerHandler.prepareSongAndSession(
            urlString: "",
            imageUrl: "",
            title: "",
            artist: "",
            albumTitle: "",
            duration: 0)
       
        playerHandler.onIsPlayingChanged { isPlaying in
            self.buttonPlayPausePressed.setImage(isPlaying ? UIImage(systemName: "pause") : UIImage(systemName: "play") , for: .normal)
        }
        
        if let url = URL(string: "" ) {
            downloadImage(url: url, imageView: imageCover)
        }
        self.labelTitle.text =  ""
        self.labelChapter.text = ""
        self.sliderPosition.maximumValue = 0
        self.labelTimePlayed.text = millisToTime(0)
        playerHandler.onProgressChanged { progress in
            if !self.isChangingSlidePosition {
                self.sliderPosition.value = Float(progress)
                self.labelTimeEleapsed.text = millisToTime(progress)
                print(progress)
            }
        }
    }
    
    @IBAction func buttonPlay(_ sender: Any) {
        playerHandler.playPause()
    }
    
    var isChangingSlidePosition = false
    
    @IBAction func sliderPositionEndChanged(_ sender: UISlider) {
        isChangingSlidePosition=false
        playerHandler.seekTo(position: Int(sender.value))
    }
    
    @IBAction func sliderPositionChanged(_ sender: UISlider) {
        labelTimePlayed.text = millisToTime(Int(sender.value))
    }
    
    @IBAction func sliderPositionBeginChanged(_ sender: UISlider) {
        isChangingSlidePosition=true
    }
    
    @IBAction func fastForwardPressed(_ sender: Any) {
        playerHandler.forward()
    }
    
    @IBAction func rewindPressed(_ sender: Any) {
        playerHandler.rewind()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
