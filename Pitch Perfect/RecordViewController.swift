//
//  RecordViewController.swift
//  Pitch Perfect
//
//  Created by Eric Hodgins on 2015-11-14.
//  Copyright © 2015 Eric Hodgins. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pausePlayButton: UIButton!
    
    var soundBarView1 = UIView()
    var soundBarView2 = UIView()
    var soundBarView3 = UIView()
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addSoundBars()
    }
    
    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
        pausePlayButton.hidden = true
        recordButton.enabled = true
        recordingLabel.text = "Tap to Record"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Record Audio
    @IBAction func recordAudio(sender: AnyObject) {
        stopButton.hidden = false
        pausePlayButton.hidden = false
        recordingLabel.text = "Recording..."
        recordButton.enabled = false
        
        soundBarView1.hidden = false
        soundBarView2.hidden = false
        soundBarView3.hidden = false
        
        animateSoundBars()
        
        // record the users voice
        // get directory path
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        print("")
        // make the recording name be the date and time
        let recordingName = "my_audio.wav"
        
        // save the file at this location
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        // start the session, let the system know what you intend to do.
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        //make a AVAudioRecorder object and try to record
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    
    //MARK: Stop and Pause Recording
    @IBAction func recordingStop(sender: AnyObject) {
        recordingLabel.hidden = true
        
        soundBarView1.hidden = true
        soundBarView2.hidden = true
        soundBarView3.hidden = true
        
        resetSoundBars()
        
        //stop recording
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    
    @IBAction func pauseRecording(sender: AnyObject) {
        if audioRecorder.recording {
            audioRecorder.pause()
            resetSoundBars()
            pausePlayButton.setTitle("▶︎", forState: .Normal)
        } else {
            audioRecorder.record()
            animateSoundBars()
            pausePlayButton.setTitle("∎∎", forState: .Normal)
        }
    }
    
    
    
    //MARK: Soundbars and Animation
    func addSoundBars() {
        let soundViewMiddle = CGRectMake(view.frame.width/2, 110, 3, 40)
        let soundViewLeft = CGRectMake(view.frame.width/2 - 8, 120, 3, 20)
        let soundViewRight = CGRectMake(view.frame.width/2 + 8, 120, 3, 20)
        
        soundBarView1 = UIView(frame: soundViewLeft)
        soundBarView1.backgroundColor = UIColor.blackColor()
        
        soundBarView2 = UIView(frame: soundViewRight)
        soundBarView2.backgroundColor = UIColor.blackColor()
        
        soundBarView3 = UIView(frame: soundViewMiddle)
        soundBarView3.backgroundColor = UIColor.blackColor()
        
        view.addSubview(soundBarView2)
        view.addSubview(soundBarView1)
        view.addSubview(soundBarView3)
        
        soundBarView1.hidden = true
        soundBarView2.hidden = true
        soundBarView3.hidden = true
    }

    
    func animateSoundBars() {
        UIView.animateWithDuration(0.1, delay: 0, options: [UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.Repeat], animations: { () -> Void in
            self.soundBarView1.transform = CGAffineTransformMakeScale(1, 1.5)
            self.soundBarView2.transform = CGAffineTransformMakeScale(1, 1.5)
            self.soundBarView3.transform = CGAffineTransformMakeScale(1, 0.5)
            }, completion: nil)
        
    }
    
    func resetSoundBars() {
        UIView.animateWithDuration(0.5, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
            self.soundBarView1.transform = CGAffineTransformIdentity
            self.soundBarView2.transform = CGAffineTransformIdentity
            self.soundBarView3.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    
    //MARK: Finished Recording
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag) {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            
            
            performSegueWithIdentifier("stopRecording", sender: recordedAudio)
            
        } else {
            print("recording was not successful")
            recordButton.enabled = true
            stopButton.hidden = true
        }
    }

    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
            
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }

}

