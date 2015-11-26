//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Eric Hodgins on 2015-11-15.
//  Copyright © 2015 Eric Hodgins. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    
    var engine: AVAudioEngine!
    var audioFile: AVAudioFile!
    var reverb: AVAudioUnitReverb!
    @IBOutlet weak var switchOutlet: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchOutlet.addTarget(self, action: Selector("activateReverb:"), forControlEvents: UIControlEvents.ValueChanged)
        
        audioPlayer = try! AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        audioPlayer.enableRate = true
        audioPlayer.delegate = self
        
        engine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: receivedAudio.filePathUrl)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Finished Playing
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        // do something when audioPlayer is done playing
        switchOutlet.enabled = true
    }
    
    //MARK: Sound Effects
    @IBAction func playSoundSlowly(sender: AnyObject) {
        switchOutlet.enabled = false
        setupSoundSettings(0.5)
    }
    
    @IBAction func playSoundFast(sender: AnyObject) {
        switchOutlet.enabled = false
        setupSoundSettings(2.0)
    }
    
    @IBAction func playChipmunkAudio(sender: AnyObject) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthVadorAudio(sender: AnyObject) {
        playAudioWithVariablePitch(-1000)
    }

    func playAudioWithVariablePitch(pitch: Float) {
        switchOutlet.enabled = true
        audioPlayer.stop()
        engine.stop()
        engine.reset()
        
        let playerNodeA = AVAudioPlayerNode()
        engine.attachNode(playerNodeA)
        
        reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(AVAudioUnitReverbPreset.Cathedral)
        
        // if the switch is on put on some reverb
        if (switchOutlet.on) {
            reverb.wetDryMix = 60
        } else {
            reverb.wetDryMix = 0
        }
        engine.attachNode(reverb)
        
        
        let audioTimePitch = AVAudioUnitTimePitch()
        audioTimePitch.pitch = pitch
        
        engine.attachNode(audioTimePitch)
        
        let buffer = AVAudioPCMBuffer(PCMFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
        try! audioFile.readIntoBuffer(buffer)
        
        // connect all the nodes together
        engine.connect(playerNodeA, to: audioTimePitch, format: buffer.format)
        engine.connect(audioTimePitch, to: reverb, format: buffer.format)
        engine.connect(reverb, to: engine.outputNode, format: buffer.format)
        
        
        playerNodeA.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        try! engine.start()
        playerNodeA.play()
        
    }
    
    //MARK: Audioplayer Settings
    func setupSoundSettings(rate: Float) {
        engine.stop()
        engine.reset()
        
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        audioPlayer.rate = rate
        audioPlayer.play()
    }

    
    //MARK: Stop Recording
    @IBAction func stopPlayingRecording(sender: AnyObject) {
        switchOutlet.enabled = true
        audioPlayer.stop()
        engine.stop()
        engine.reset()
    }
    
    
    //MARK: Switch Control
    func activateReverb(switchState: UISwitch) {
        // ability to turn reverb on or off while the darth or chipmunk effect is playing.
        if let reverbOn = reverb {
            if switchState.on {
                reverbOn.wetDryMix = 60
            } else {
                reverbOn.wetDryMix = 0
            }
        }
    }
    
}
