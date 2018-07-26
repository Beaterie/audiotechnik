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
import Speech

class Startbildschirm: UIViewController {
    
    // Membervariablen
    var spuren: [Spur] = [
        Spur(name: "Spur 1", dauer: "01:00"),
        Spur(name: "Spur 2", dauer: "00:45"),
        Spur(name: "Spur 3", dauer: "00:57")
    ]
    // ---------------------------------
    
    
    // Aufnahme starten/beenden
    @IBAction func spurAufnehmen(_ sender: Any) {
        let temp_name = "Spur " + String(spuren.count+1)
        let aufnahme = Spur(name: temp_name, dauer: "00:42")
        // AUFNAHMEZYKLUS EINFÜGEN
        spuren.append(aufnahme)
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

