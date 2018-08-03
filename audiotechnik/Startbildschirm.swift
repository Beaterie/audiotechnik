//
//  Startbildschirm.swift
//  audiotechnik
//
//  Created by Jana Puschmann und Josef Roth on 01.07.18.
//  Copyright © 2018 Jana Puschmann und Josef Roth. All rights reserved.
//


import UIKit
import os
import AVFoundation

class Startbildschirm: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    // Membervariablen: Aufnahme
    var metronomeActivity: Bool = false
    var metronomeMode: Bool = true
    
    var recordingSession = AVAudioSession.sharedInstance()
    var recorder: AVAudioRecorder!
    var metronome_player: AVAudioPlayer!
    
    let delayToPlay: Double = 0.0
    
    @IBOutlet weak var aufnahme_knopf: UIButton!
    var aufnahme_titel: String!
    var aufnahme_url: URL!
//    var aufnahme_player: AVAudioPlayer!
    
    var spuren: [Spur] = []
    
    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    var audioAVEngine = AVAudioEngine()
    var mixer = AVAudioMixerNode()
    // ---------------------------------
    
    
    @IBAction func activateMetronomeAction(_ sender: UIButton) {
        metronomeMode = true
        os_log("Metronome activated.", log: OSLog.default, type: .info)
    }
    // ---------------------------------

    
    @IBAction func deactivateMetronomeAction(_ sender: UIButton) {
        metronomeMode = false
        os_log("Metronome deactivated.", log: OSLog.default, type: .info)
    }
    // ---------------------------------

    
    // Aufnahme starten/beenden
    @IBAction func spurAufnehmen(_ sender: Any) {
        if recorder == nil {
            
            aufnahme_knopf.setTitle("Aufnahme beenden", for: .normal)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + self.delayToPlay) {
                if self.metronomeMode == true {
                    do {
                        let metronome_url = Bundle.main.url(forResource: "4-cowbell", withExtension: "mp3", subdirectory: "audioFiles")
                        try self.metronome_player = AVAudioPlayer(contentsOf: metronome_url!)
                        self.metronome_player.volume = 0.2
                        self.metronome_player.prepareToPlay()
                        self.metronome_player.play()
                        self.metronomeActivity = true
                    } catch {
                        os_log("Could not load file!", log: OSLog.default, type: .error)
                        self.metronomeActivity = false
                    }
                }
                self.starteAufnahme()
            }
        } else {
            if metronomeActivity == true {
                metronome_player.stop()
                metronomeActivity = false
            }
            beendeAufnahme(success: true)
            
            // speichert Aufnahmetitel und Dauer
            let aufnahme_dauer = String(format: "%.2fs", spurDauer(for: aufnahme_url))
            let aufnahme = Spur(name: aufnahme_titel, dauer: aufnahme_dauer, url: aufnahme_url)
            print("The duration of the recorded audio is " + aufnahme_dauer)
            spuren.append(aufnahme)
        }
    }
    // ---------------------------------
    
    
    func starteAufnahme() {
        aufnahme_titel = "Spur" + String(spuren.count+1) + ".m4a"
        aufnahme_url = getDocumentsDirectory().appendingPathComponent(aufnahme_titel)
        print("Recorded audio will be stored at: " + aufnahme_titel + " as \(aufnahme_url!)") // Aufruf funktioniert nicht im Log

        do {
            recorder = try AVAudioRecorder(url: aufnahme_url, settings: self.settings)
            recorder.prepareToRecord()
            recorder.delegate = self
            recorder.record()
            
            if recorder.isRecording {
//                aufnahme_knopf.setTitle("Aufnahme beenden", for: .normal)
            }
        } catch {
            beendeAufnahme(success: false)
        }
    }
    // ---------------------------------

    
    func beendeAufnahme(success: Bool) {
        
        recorder.stop()
        recorder = nil
        
        let alert: UIAlertController!
        
        if success {
            aufnahme_knopf.setTitle("Neue Spur aufnehmen", for: .normal)
            alert = UIAlertController(title: "Aufnahme erfolgreich", message: "Die Aufnahme wurde gespeichert", preferredStyle: .alert)
        } else {
            aufnahme_knopf.setTitle("Neue Spur aufnehmen", for: .normal)
            
            alert = UIAlertController(title: "Aufnahme gescheitert", message: "Die Aufnahme konnte nicht gespeichert werden.", preferredStyle: .alert)
            
            os_log("Failed to record audio!", log: OSLog.default, type: .error)
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    // ---------------------------------
    
    
    // Gesamtkomposition (alle Spuren gleichzeitig) abspielen
    @IBAction func playButton(_ sender: UIButton) {
        
        if audioAVEngine.isRunning == false {
            if spuren.count != 0 {
                self.setupAudioEngine()
                DispatchQueue.main.asyncAfter(deadline: .now() + self.delayToPlay) {
                    self.play()
                }
            } else {
                let alert = UIAlertController(title: "Keine Aufnahmen", message: "Es existieren keine Aufnahmen die abgespielt werden können.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                
                os_log("Failed to play audio!", log: OSLog.default, type: .error)
            }
        }
        else {
            print("Audio Engine läuft noch!")
            self.stop()
            DispatchQueue.main.asyncAfter(deadline: .now() + self.delayToPlay) {
                self.play()
            }
        }
    }
    @IBAction func pauseButton(_ sender: UIButton) {
        pause()
    }
    @IBAction func stopButton(_ sender: UIButton) {
        stop()
    }
    // ---------------------------------
    
    func pause() {
        for spur in self.spuren {
            spur.enginePlayer.pause()
            print("Pausing Players...")
        }
//        audioAVEngine.pause()
    }
    func stop() {
        for spur in self.spuren {
            spur.enginePlayer.stop()
            print("Stopping Players...")
        }
//        audioAVEngine.stop()
    }
    func play() {
        for spur in self.spuren {
            spur.enginePlayer.play()
            print("Playing Players...")
        }
    }
    // ---------------------------------
    
    
    // Übergang zurück zu diesem Bildschirm
    @IBAction func zumStartbildschirm(segue: UIStoryboardSegue) {
        print("Zurück zum Startbildschirm")
    }
    // ---------------------------------
    
    
    // Übergang zum AufnahmeController (Übermitteln der Membervariable an AufnahmeController)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextScene = segue.destination as? UINavigationController {
            if segue.identifier == "zeigeAufnahmen" {
                let scene = nextScene.viewControllers[0] as! AufnahmenController
                scene.spuren = spuren
            }
        }
    }
    // ------------------------------------------------
    
    
    // Rückgabe der Dauer einer Audioaufnahmespur in Sekunden
    func spurDauer(for spur_url: URL) -> Double {
        let asset = AVURLAsset(url: spur_url)
        return Double(CMTimeGetSeconds(asset.duration))
    }
    // ------------------------------------------------
    
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    // ------------------------------------------------
    
    
    
    func requestRecordPermission() {
        // Erbitte Erlaubnis, um das Mikrofon zu verwenden und Audio aufzunehmen
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                                             //with: .defaultToSpeaker)
            try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [] allowed in
                DispatchQueue.main.async {
                    if allowed {
                       os_log("Recording permission granted.", log: OSLog.default, type: .info)
                    } else {
                        os_log("Recording permission denied. Failed to record audio!", log: OSLog.default, type: .error)
                    }
                }
            }
        } catch {
            os_log("Failed to record audio!", log: OSLog.default, type: .error)
        }
    }
    // ------------------------------------------------
    
    
    func setupAudioEngine() {
        let format = audioAVEngine.inputNode.inputFormat(forBus: 0)
        audioAVEngine.attach(mixer)
        
        for spur in self.spuren {
            audioAVEngine.attach(spur.enginePlayer)
            audioAVEngine.attach(spur.pitchEffect)
            audioAVEngine.attach(spur.reverbEffect)
            audioAVEngine.attach(spur.delayEffect)
            audioAVEngine.attach(spur.equalizer)
            audioAVEngine.connect(spur.enginePlayer, to: spur.pitchEffect, format: format)
            audioAVEngine.connect(spur.pitchEffect, to: spur.delayEffect, format: format)
            audioAVEngine.connect(spur.delayEffect, to: spur.reverbEffect, format: format)
            audioAVEngine.connect(spur.reverbEffect, to: spur.equalizer, format: format)
            audioAVEngine.connect(spur.equalizer, to: mixer, format: format)
        }
        
        audioAVEngine.connect(mixer, to: audioAVEngine.mainMixerNode, format: format)
        
        do {
            try audioAVEngine.start()
        } catch {
            print("Error starting AVAudioEngine.")
        }
        
        for spur in self.spuren {
            do {
                spur.engineAudioFile = try AVAudioFile(forReading: spur.get_url())
            } catch {
                print("Fehler bei der URL-Zuweisung.")
            }
            spur.enginePlayer.scheduleFile(spur.engineAudioFile, at: nil, completionHandler: nil)
        }
    }
    // ------------------------------------------------
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // ------------------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Erbitte Aufnahmeerlaubnis vom Nutzer
        requestRecordPermission()
    }
}

