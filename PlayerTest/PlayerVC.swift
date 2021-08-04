//
//  PlayerVC.swift
//  PlayerTest
//
//  Created by Lourenço Gomes on 24/07/2021.
//
//  Copyright 2021 Lourenço Gomes
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in the
//  Software without restriction, including without limitation the rights to use, copy,
//  modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//   PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//   HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR // OTHER LIABILITY, WHETHER IN AN ACTION
//   OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
            urlString: "https://github.com/lgleto/iOSPlayerExample/raw/main/assets/RockOnLeto.mp3",
            imageUrl: "https://github.com/lgleto/iOSPlayerExample/raw/main/assets/50771337_10213633203484426_2882724728441667584_n.jpg",
            title: "Rock On",
            artist: "Leto",
            albumTitle: "Rock",
            duration: 60000)
       
        playerHandler.onIsPlayingChanged { isPlaying in
            self.buttonPlayPausePressed.setImage(isPlaying ? UIImage(systemName: "pause") : UIImage(systemName: "play") , for: .normal)
        }
        
        if let url = URL(string: "https://github.com/lgleto/iOSPlayerExample/raw/main/assets/50771337_10213633203484426_2882724728441667584_n.jpg" ) {
            downloadImage(url: url, imageView: imageCover)
        }
        self.labelTitle.text =  "Rock On"
        self.labelChapter.text = "Leto"
        self.sliderPosition.maximumValue = 60000
        self.labelTimePlayed.text = millisToTime(60000)
        playerHandler.onProgressChanged { progress in
            if !self.isChangingSlidePosition {
                self.sliderPosition.value = Float(progress)
                self.labelTimeEleapsed.text = millisToTime(progress)
                self.labelTimePlayed.text = millisToTime(60000 - progress)
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
