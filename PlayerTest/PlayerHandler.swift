//
//  PlayerHandler.swift
//  PlayerTest
//
//  Created by Lourenço Gomes on 27/07/2021.
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

import Foundation
import AVFoundation
import MediaPlayer

class PlayerHandler : NSObject, AVAudioPlayerDelegate {

    private var player : AVPlayer?
    private var playerItem : AVPlayerItem?
    private var progressUpdateTimer: Timer?
    
    var urlString   : String?
    var imageUrl    : String?
    var title       : String?
    var artist      : String?
    var albumTitle  : String?
    var duration    : Int = 0
    var isPlaying   : Bool = false {
        didSet {
            if let c = _isPlayingChanged{
                c(isPlaying)
            }
        }
    }
    var isReady     : Bool = false
    var progress    : Int = 0 {
        didSet {
            if let c = _progressChanged{
                c(progress)
            }
        }
    }
    let bytesPointer = UnsafeMutableRawPointer.allocate(byteCount: 4, alignment: 1)
    
    
    private var _isPlayingChanged : ((Bool)->Void)?
    func onIsPlayingChanged(_ isPlayingChanged : @escaping ((Bool)->Void)){
        _isPlayingChanged = isPlayingChanged
    }
    
    private var _progressChanged : ((Int)->Void)?
    func onProgressChanged(_ progressChanged : @escaping ((Int)->Void)){
        _progressChanged = progressChanged
    }
    
    var playerDuration : CMTime {
        get {
            if let thePlayerItem = player?.currentItem {
                if thePlayerItem.status == .readyToPlay {
                    return thePlayerItem.duration
                }else {
                    return CMTimeMake(value: Int64(duration/1000), timescale: 1)
                }
            }
            return CMTime.invalid
        }
    }
    
    func prepareSongAndSession(
        urlString  : String,
        imageUrl   : String,
        title      : String,
        artist     : String,
        albumTitle : String,
        duration   : Int) {
        
        self.urlString  = urlString
        self.imageUrl   = imageUrl
        self.title      = title
        self.artist     = artist
        self.albumTitle = albumTitle
        self.duration   = duration
        
        
        guard let url = URL(string: urlString ) else {
            print("Error: cannot create stream URL")
            return
        }
        
        /* Play file
        guard let url = URL(fileURLWithPath:  urlString ) else {
            print("Error: cannot create stream URL")
            return
        }*/
        
        debugPrint("Will play stream:\(url.absoluteString)")
        player = AVPlayer(url: url)
        
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory( .playback, mode: .default)
            if let p = player {
                let combinedbits : UInt = UInt(NSKeyValueObservingOptions.initial.rawValue) | UInt(NSKeyValueObservingOptions.new.rawValue)
                p.addObserver(self, forKeyPath: "status",
                              options: NSKeyValueObservingOptions.init(rawValue: combinedbits),
                              context: bytesPointer)
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemWasInterrupted(_:)), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
                playerItem=p.currentItem
            }
        } catch let sessionError {
            print(sessionError)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if context == bytesPointer {
            if let status = AVPlayer.Status(rawValue: change![NSKeyValueChangeKey.newKey] as! Int ){
                switch status {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
                //case .unknown :
                    //buttonPlayPausePressed.isEnabled = false
                
                case .readyToPlay:
                    //buttonPlayPausePressed.isEnabled = true
                    setupRemoteTransportControls()
                    setupNowPlaying()
                    
                default:
                    print("\(status)")
                }
            }
        }
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player?.rate == 0.0 {
                playPause()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player?.rate == 1.0 {
                playPause()
                return .success
            }
            return .commandFailed
        }
        commandCenter.skipBackwardCommand.addTarget{ [unowned self] event in
            if self.player?.rate == 1.0 {
                rewind()
                
                return .success
            }
            return .commandFailed
        }
        commandCenter.skipForwardCommand.addTarget{ [unowned self] event in
            if self.player?.rate == 1.0 {
                forward()
                return .success
            }
            return .commandFailed
        }
        
    }
    
    func playPause() {
        if let p = player {
            if isPlaying {
                p.pause()
                isPlaying = false
            }else {
                p.play()
                isPlaying = true
            }
        }else{
            isPlaying = false
        }
        createTimers(true)
    }
    
    func rewind() {
        if CMTIME_IS_INVALID(playerDuration) {
            return
        }
        if isPlaying {
            let progress = CMTimeGetSeconds(playerItem!.currentTime())
            playerItem?.seek(to: CMTimeMake(value: Int64(progress - 10.0), timescale: 1
            ), completionHandler: nil)
            updateNowPlayingInfoProgress(Float(progress))
        }
    }
    
    func forward() {
        if CMTIME_IS_INVALID(playerDuration) {
            return
        }
        if isPlaying {
            let progress = CMTimeGetSeconds(playerItem!.currentTime())
            playerItem?.seek(to: CMTimeMake(value: Int64(progress + 10.0), timescale: 1
            ), completionHandler: nil)
            updateNowPlayingInfoProgress(Float(progress))
        }
    }
    
    func seekTo(position: Int){
        if CMTIME_IS_INVALID(playerDuration) {
            return
        }
        if isPlaying {
            let progress = Float(CMTimeGetSeconds((playerItem?.currentTime())!))
            print("progress\(progress)")
            print("position\(position/1000)")
            playerItem?.seek(to: CMTimeMake(value: Int64(position / 1000), timescale: 1
            ), completionHandler: nil)
            updateNowPlayingInfoProgress(progress)
        }

    }
    
    deinit {
        if let p = player {
            p.removeObserver(self, forKeyPath: "status")
        }
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        createTimers(false)
    }
    
    @objc func playerItemDidReachEnd() {
        isPlaying = false
        progress = 0
        updateNowPlayingInfoProgress(0.0)
    }
    
    @objc func playerItemWasInterrupted(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        if type == .began {
            // Interruption began, take appropriate actions
            let center = MPNowPlayingInfoCenter.default()
            var playingInfo = center.nowPlayingInfo
            playingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 0
            center.nowPlayingInfo = playingInfo
            isPlaying = false
        }
        else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Interruption Ended - playback should resume
                    let center = MPNowPlayingInfoCenter.default()
                    var playingInfo = center.nowPlayingInfo
                    playingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 1
                    center.nowPlayingInfo = playingInfo
                    isPlaying = true
                    player?.play()
                } else {
                    // Interruption Ended - playback should NOT resume
                }
            }
        }
    }
    
    var nowPlayingInfo = [String : Any]()
    
    func setupNowPlaying() {
        // Define Now Playing Info
        
        if let url = URL(string: imageUrl ?? "") {
            downloadImage(url:url) { image in
                self.nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: image.size) { size in
                        return image
                    }
                MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
            }
        }
        
        let totalDuration = Float (duration / 1000)
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = albumTitle
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = totalDuration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func updateNowPlayingInfoProgress(_ progress: Float) {

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = progress
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func createTimers(_ create: Bool) {
        if create {
            createTimers(false)
            progressUpdateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateProgress(_:)), userInfo: nil, repeats: true)
        } else {
            if let put = progressUpdateTimer {
                put.invalidate()
                progressUpdateTimer = nil
            }
        }
    }
    
    @objc func updateProgress(_ updatedTimer: Timer?) {
        if isPlaying {
            progress = Int(CMTimeGetSeconds(playerItem!.currentTime())) *  1000
        }
    }
    


}
