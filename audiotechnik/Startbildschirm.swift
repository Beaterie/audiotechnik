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
    @IBOutlet weak var activateMetronome: UIButton!
    @IBOutlet weak var deactivateMetronome: UIButton!
    
    var metronomeActivity: Bool = false
    var metronomeMode: Bool = false
    
    var recordingSession = AVAudioSession.sharedInstance()
    var recorder: AVAudioRecorder!
    var metronome_player: AVAudioPlayer!
    
    @IBOutlet weak var aufnahme_knopf: UIButton!
    var aufnahme_titel: String!
    var aufnahme_url: URL!
    var aufnahme_player: AVAudioPlayer!
    
    var spuren: [Spur] = [
        /*Spur(name: "Spur 1", dauer: "01:00"),
        Spur(name: "Spur 2", dauer: "00:45"),
        Spur(name: "Spur 3", dauer: "00:57")*/
    ]
    
    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    // Membervariablen: Wiedergabe
    @IBOutlet weak var wiedergabe_knopf: UIButton!
//    var players: [AVAudioPlayer] = [] // erstellt eine Playerinstanz pro verfügbarer Audiospur

    // ---------------------------------
    
    @IBAction func activateMetronomeAction(_ sender: UIButton) {
        if !metronomeMode {
            metronomeMode = !metronomeMode
            os_log("Metronome activated.", log: OSLog.default, type: .info)
        }
    }
    
    // ---------------------------------

    
    @IBAction func deactivateMetronomeAction(_ sender: UIButton) {
        if metronomeMode {
            metronomeMode = !metronomeMode
            os_log("Metronome deactivated.", log: OSLog.default, type: .error)
        }
    }
    

    // ---------------------------------

    
    // Aufnahme starten/beenden
    @IBAction func spurAufnehmen(_ sender: Any) {
        if recorder == nil {
            // play metronome sound
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // change 2 to desired number of seconds
                if self.metronomeMode == true {
                    do {
                        let metronome_url = Bundle.main.url(forResource: "4-cowbell", withExtension: "mp3", subdirectory: "audioFiles")
                        try self.metronome_player = AVAudioPlayer(contentsOf: metronome_url!)
                        self.metronome_player.volume = 0.8
                        self.metronome_player.prepareToPlay()
                        self.metronome_player.play()
                        self.metronomeActivity = true
                    } catch {
                        // Error: File not loaded
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
            let aufnahme = Spur(name: aufnahme_titel, dauer: aufnahme_dauer, player: aufnahme_player)
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
//            let metronom_url = Bundle.main.url(forResource: "1-piano", withExtension: "mp3", subdirectory: "audioFiles")
//            print("\(metronom_url!)")
//
//            var metronom: AVAudioPlayer = try AVAudioPlayer(contentsOf: metronom_url!)
//            metronom.play()
            
            recorder = try AVAudioRecorder(url: aufnahme_url, settings: self.settings)
            recorder.prepareToRecord()
            recorder.delegate = self
            recorder.record()
//            metronom.play()
            
            if recorder.isRecording {
                aufnahme_knopf.setTitle("Aufnahme beenden", for: .normal)
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
            
            do {
                try aufnahme_player = AVAudioPlayer(contentsOf: aufnahme_url)
//                players.append(tmp_player)
//                spuren[spuren.count].set_player(player: tmp_player)
            } catch {
                // Error: File not loaded
                os_log("Could not load file!", log: OSLog.default, type: .error)
            }
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
    @IBAction func kompositionAbspielen(_ sender: Any) {
        // regelt die simultane Wiedergabe fuer alle gespeicherten Player
        if spuren.count != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // change 2 to
                for spur in self.spuren {
                    self.audioWiedergabe(player: spur.get_modified_player())
                }
            }
        } else {
            let alert = UIAlertController(title: "Keine Aufnahmen", message: "Es existieren keine Aufnahmen die abgespielt werden können.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            
            os_log("Failed to play audio!", log: OSLog.default, type: .error)
        }
    }
    // ---------------------------------
    
    
    func audioWiedergabe(player: AVAudioPlayer) {
        // spielt Audioaufnahme ab oder pausiert sie
        if !player.isPlaying {
            player.play()
            wiedergabe_knopf.setTitle("Gesamtkomposition pausieren", for: .normal)
        } else {
            player.pause()
            wiedergabe_knopf.setTitle("Gesamtkomposition abspielen", for: .normal)
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

