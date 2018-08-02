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
    var original_player: AVAudioPlayer?
    var modified_player: AVAudioPlayer?
    // ---------------------------------
    
    
    // Konstruktor
    init(name: String, dauer: String, player: AVAudioPlayer) {
        self.name = name
        self.dauer = dauer
        self.original_player = player
        self.modified_player = player
    }
    init(name: String, dauer: String) {
        self.name = name
        self.dauer = dauer
        self.original_player = nil
        self.modified_player = nil
    }
    // ---------------------------------
    
    
    // Getter
    func get_name() -> String {
        return self.name
    }
    func get_dauer() -> String{
        return self.dauer
    }
    func get_original_player() -> AVAudioPlayer {
        return self.original_player!
    }
    func get_modified_player() -> AVAudioPlayer {
        return self.modified_player!
    }
    // ---------------------------------
    
    // Setter
    func set_name(name: String) {
        self.name = name
    }
    func set_dauer(dauer: String) {
        self.dauer = dauer
    }
    func set_original_player(player: AVAudioPlayer) {
        self.original_player = player
    }
    func set_modified_player(player: AVAudioPlayer) {
        self.modified_player = player
    }
    // ---------------------------------
}
