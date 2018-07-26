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
    @IBOutlet weak var aufnahme_knopf: UIButton!
    
    var recordingSession: AVAudioSession!
    var recorder: AVAudioRecorder!
    
    var aufnahme_titel: String!
    var aufnahme_url: URL!
    
    var spuren: [Spur] = [
        /*Spur(name: "Spur 1", dauer: "01:00"),
        Spur(name: "Spur 2", dauer: "00:45"),
        Spur(name: "Spur 3", dauer: "00:57")*/
    ]
    
    // Membervariablen: Wiedergabe

    
    // ---------------------------------
    
    // Aufnahme starten/beenden
    @IBAction func spurAufnehmen(_ sender: Any) {
        if recorder == nil {
            starteAufnahme()
        } else {
            beendeAufnahme(success: true)
            
            // speichert Aufnahmetitel und Dauer
            let aufnahme_dauer = String(format: "%:2fs", spurDauer(for: aufnahme_url))
            let aufnahme = Spur(name: aufnahme_titel, dauer: aufnahme_dauer)
            print("The duration of the recorded audio is " + aufnahme_dauer)
            spuren.append(aufnahme)
        }
    }
    
    // ---------------------------------
    
    func starteAufnahme() {
        aufnahme_titel = "Spur" + String(spuren.count+1) + ".m4a"
        aufnahme_url = getDocumentsDirectory().appendingPathComponent(aufnahme_titel)
        print("Recorded audio will be stored at: " + aufnahme_titel) // Aufruf funktioniert nicht im Log
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            recorder = try AVAudioRecorder(url: aufnahme_url, settings: settings)
            recorder.prepareToRecord()
            recorder.delegate = self
            recorder.record()
            
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
            try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
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

