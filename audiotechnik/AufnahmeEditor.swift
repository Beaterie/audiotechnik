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
    var equalizer = AVAudioUnitEQ()
    var filter1: AVAudioUnitEQFilterParameters?
    var filter2: AVAudioUnitEQFilterParameters?
    var engineAudioFile: AVAudioFile!
//    var mixer = AVAudioMixerNode()
    
    func setupAudioEngine() {
        let format = audioAVEngine.inputNode.inputFormat(forBus: 0)
        audioAVEngine.attach(enginePlayer)
        audioAVEngine.attach(pitchEffect)
        audioAVEngine.attach(reverbEffect)
        audioAVEngine.attach(delayEffect)
        audioAVEngine.attach(equalizer)
//        audioAVEngine.attach(mixer)
        audioAVEngine.connect(enginePlayer, to: pitchEffect, format: format)
        audioAVEngine.connect(pitchEffect, to: delayEffect, format: format)
        audioAVEngine.connect(delayEffect, to: reverbEffect, format: format)
        audioAVEngine.connect(reverbEffect, to: equalizer, format: format)
        audioAVEngine.connect(equalizer, to: audioAVEngine.outputNode, format: format)
//        audioAVEngine.connect(mixer, to: audioAVEngine.mainMixerNode, format: format)
        
        do {
            try audioAVEngine.start()
        } catch {
            print("Error starting AVAudioEngine.")
        }
    }
    
    func pause() {
        enginePlayer.pause()
    }
    func stop() {
        enginePlayer.stop()
    }
    
    func play() {
        var playFlag = true
        
        do {
            engineAudioFile = try AVAudioFile(forReading: (spur?.get_url())!)
            spur?.engineAudioFile = try AVAudioFile(forReading: (spur?.get_url())!)
            
            if (spur?.delay)! {
                delayEffect.delayTime = 1.0
                delayEffect.feedback = 50.0
                delayEffect.wetDryMix = 35.0
                spur?.delayEffect.delayTime = 1.0
                spur?.delayEffect.feedback = 50.0
                spur?.delayEffect.wetDryMix = 35.0
            } else {
                delayEffect.wetDryMix = 0.0
                spur?.delayEffect.wetDryMix = 0.0
            }
            
            if (spur?.reverb)! {
                reverbEffect.loadFactoryPreset(.largeRoom)
                reverbEffect.wetDryMix = 50.0
                spur?.reverbEffect.loadFactoryPreset(.largeRoom)
                spur?.reverbEffect.wetDryMix = 50.0
            } else {
                reverbEffect.wetDryMix = 0.0
                spur?.reverbEffect.wetDryMix = 0.0
            }
            
            if (spur?.lowpass)! {
                filter1 = equalizer.bands[0]
                filter1?.filterType = AVAudioUnitEQFilterType.lowPass
                filter1?.frequency = 100
                filter1?.bypass = false
                spur?.filter1 = equalizer.bands[0]
                spur?.filter1?.filterType = AVAudioUnitEQFilterType.lowPass
                spur?.filter1?.frequency = 100
                spur?.filter1?.bypass = false
            } else {
                filter1?.bypass = true
                spur?.filter1?.bypass = true
            }
            
            if (spur?.highpass)! {
                filter2 = equalizer.bands[0]
                filter2?.filterType = AVAudioUnitEQFilterType.highPass
                filter2?.frequency = 500
                filter2?.bypass = false
                spur?.filter2 = equalizer.bands[0]
                spur?.filter2?.filterType = AVAudioUnitEQFilterType.highPass
                spur?.filter2?.frequency = 500
                spur?.filter2?.bypass = false
            } else {
                filter2?.bypass = true
                spur?.filter2?.bypass = true
            }
            
            if (spur?.lowpitch)! {
                pitchEffect.pitch = -500.0
                spur?.pitchEffect.pitch = -500.0
            } else if (spur?.highpitch)! {
                pitchEffect.pitch = 500.0
                spur?.pitchEffect.pitch = 500.0
            } else {
                pitchEffect.pitch = 0.0
                spur?.pitchEffect.pitch = 0.0
            }
            
        } catch {
            engineAudioFile = nil
            playFlag = false
            print("Error loading AVAudioFile.")
        }
        
        if playFlag == true {
            enginePlayer.scheduleFile(engineAudioFile, at: nil, completionHandler: nil)
//
//            var buffer = AVAudioPCMBuffer(pcmFormat: engineAudioFile.processingFormat, frameCapacity: AVAudioFrameCount(engineAudioFile.length))
//            do {
//                try engineAudioFile.read(into: buffer!)
//            } catch {}
//
//            var buffer2 = AVAudioPCMBuffer(pcmFormat: engineAudioFile2.processingFormat, frameCapacity: AVAudioFrameCount(engineAudioFile2.length))
//            do {
//                try engineAudioFile2.read(into: buffer2!)
//            } catch {}

            
//            enginePlayer.scheduleBuffer(buffer!, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
//            enginePlayer2.scheduleBuffer(buffer2!, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
//
            
//            let outputFormat:AVAudioFormat = enginePlayer.outputFormat(forBus: 0)
//
//            let kStartDelayTime = 0.0; // seconds - in case you wanna delay the start
//
//            let startSampleTime:AVAudioFramePosition = enginePlayer.lastRenderTime!.sampleTime;
//            let startFramePosition:AVAudioFramePosition = (enginePlayer.lastRenderTime?.sampleTime)!;
//
//            var startTime:AVAudioTime = AVAudioTime(sampleTime: (startSampleTime + Int64(kStartDelayTime * outputFormat.sampleRate)), atRate: outputFormat.sampleRate)
//            startTime = AVAudioTime.init(sampleTime: startFramePosition, atRate: Double(self.mixer.rate))
//            print("Time: \(startTime)")
            
            enginePlayer.play()
        }
    }
    
 
    // Buttons
    @IBAction func playButton(_ sender: UIButton) {
        DispatchQueue.global(qos: .background).async {
            if self.playButtonActive == false {
                self.play()
                self.playButtonActive = !self.playButtonActive
            }
        }
    }
    @IBAction func pauseButton(_ sender: UIButton) {
        DispatchQueue.global(qos: .background).async {
            if self.playButtonActive == true {
                self.pause()
                self.playButtonActive = !self.playButtonActive
            }
        }
    }
    @IBAction func stopButton(_ sender: UIButton) {
        DispatchQueue.global(qos: .background).async {
            if self.playButtonActive == true {
                self.stop()
                self.playButtonActive = !self.playButtonActive
            }
        }
    }
    
    @IBAction func activateReverb(_ sender: UIButton) {
        spur?.reverb = true
    }
    @IBAction func deactivateReverb(_ sender: UIButton) {
        spur?.reverb = false
    }
    @IBAction func activateDelay(_ sender: UIButton) {
        spur?.delay = true
    }
    @IBAction func deactivateDelay(_ sender: UIButton) {
        spur?.delay = false
    }
    @IBAction func activateLowpass(_ sender: UIButton) {
        spur?.lowpass = true
    }
    @IBAction func deactivateLowpass(_ sender: UIButton) {
        spur?.lowpass = false
    }
    @IBAction func activateHighpass(_ sender: UIButton) {
        spur?.highpass = true
    }
    @IBAction func deactivateHighpass(_ sender: UIButton) {
        spur?.highpass = false
    }
    @IBAction func activateLowpitch(_ sender: UIButton) {
        spur?.lowpitch = true
        spur?.highpitch = false
    }
    @IBAction func activateHighpitch(_ sender: UIButton) {
        spur?.highpitch = true
        spur?.lowpitch = false
    }
    @IBAction func deactivatePitch(_ sender: UIButton) {
        spur?.highpitch = false
        spur?.lowpitch = false
    }
    @IBAction func fullReset(_ sender: UIButton) {
        spur?.delay = false
        spur?.reverb = false
        spur?.highpass = false
        spur?.lowpass = false
        spur?.lowpitch = false
        spur?.highpitch = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .background).async {
            self.setupAudioEngine()
        }
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
