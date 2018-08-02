//
//  AufnahmeEditor.swift
//  audiotechnik
//
//  Created by Jana Puschmann und Josef Roth on 01.07.18.
//  Copyright © 2018 Jana Puschmann und Josef Roth. All rights reserved.
//


import UIKit
import AVFoundation

class AufnahmeEditor: UIViewController {
    
    // Member
    var index: Int? = nil
    var spur: Spur? = nil
    var playButtonActive: Bool = false
    
    var audioAVEngine = AVAudioEngine()
    var enginePlayer = AVAudioPlayerNode()
    var pitchEffect = AVAudioUnitTimePitch()
    var delayEffect = AVAudioUnitDelay()
    var reverbEffect = AVAudioUnitReverb()
    var engineAudioFile: AVAudioFile!
    
    func setupAudioEngine() {
        let format = audioAVEngine.inputNode.inputFormat(forBus: 0)
        audioAVEngine.attach(enginePlayer)
        audioAVEngine.attach(pitchEffect)
        audioAVEngine.attach(reverbEffect)
        audioAVEngine.attach(delayEffect)
        audioAVEngine.connect(enginePlayer, to: pitchEffect, format: format)
        audioAVEngine.connect(pitchEffect, to: delayEffect, format: format)
        audioAVEngine.connect(delayEffect, to: reverbEffect, format: format)
        audioAVEngine.connect(reverbEffect, to: audioAVEngine.outputNode, format: format)
        
        do {
            try audioAVEngine.start()
        } catch {
            print("Error starting AVAudioEngine.")
        }
    }
    
    func play() {
        let fileURL = spur?.get_original_player().url
        var playFlag = true
        
        do {
            engineAudioFile = try AVAudioFile(forReading: fileURL!)
            pitchEffect.pitch = 10.0
            reverbEffect.loadFactoryPreset(.largeRoom)
            reverbEffect.wetDryMix = 25.0
            delayEffect.delayTime = 1.0
            delayEffect.feedback = 50.0
            delayEffect.wetDryMix = 25.0
        } catch {
            engineAudioFile = nil
            playFlag = false
            print("Error loading AVAudioFile.")
        }
        
//        do {
//            spur?.get_modified_player().isMeteringEnabled = true
//            spur?.get_modified_player().prepareToPlay()
//        } catch {
//            print("Error loading AudioPlayer")
//            playFlag = false
//        }
        
        if playFlag == true {
            enginePlayer.scheduleFile(engineAudioFile, at: nil, completionHandler: nil)
            enginePlayer.play()
//            spur?.get_modified_player().play()
        }
    }
    
 
    // Buttons
    @IBAction func playButton(_ sender: Any) {
        if playButtonActive == false {
//            spur?.get_modified_player().play()
            play()
        }
        else {
//            spur?.get_modified_player().stop()
        }
        playButtonActive = !playButtonActive
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioEngine()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // Übermitteln der Membervariable an AufnahmenController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextScene = segue.destination as? AufnahmenController {
            nextScene.spuren![index!] = self.spur!
            nextScene.tableView.reloadData()
        }
    }
    // ---------------------------------

}
