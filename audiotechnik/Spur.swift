//
//  Spur.swift
//  audiotechnik
//
//  Created by Jana Puschmann und Josef Roth on 01.07.18.
//  Copyright © 2018 Jana Puschmann und Josef Roth. All rights reserved.
//

import AVFoundation
import Foundation

class Spur {
    
    // Membervariablen
    var name: String
    var dauer: String
    var url: URL
    var delay: Bool = false
    var reverb: Bool = false
    var highpass: Bool = false
    var lowpass: Bool = false
    var highpitch: Bool = false
    var lowpitch: Bool = false
    var enginePlayer = AVAudioPlayerNode()
    var pitchEffect = AVAudioUnitTimePitch()
    var delayEffect = AVAudioUnitDelay()
    var reverbEffect = AVAudioUnitReverb()
    var equalizer = AVAudioUnitEQ()
    var filter1: AVAudioUnitEQFilterParameters?
    var filter2: AVAudioUnitEQFilterParameters?
    var engineAudioFile: AVAudioFile!
    // ---------------------------------
    
    
    // Konstruktor
    init(name: String, dauer: String, url: URL) {
        self.name = name
        self.dauer = dauer
        self.url = url
        self.delayEffect.wetDryMix = 0.0
        self.reverbEffect.wetDryMix = 0.0
    }
    // ---------------------------------
    
    
    // Getter
    func get_name() -> String {
        return self.name
    }
    func get_dauer() -> String {
        return self.dauer
    }
    func get_url() -> URL {
        return self.url
    }
    // ---------------------------------
    
    // Setter
    func set_name(name: String) {
        self.name = name
    }
    func set_dauer(dauer: String) {
        self.dauer = dauer
    }
    func set_url(url: URL) {
        self.url = url
    }
    // ---------------------------------
}
