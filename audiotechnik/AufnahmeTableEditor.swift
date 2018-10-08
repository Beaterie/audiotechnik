//
//  AufnahmeTableEditor.swift
//  audiotechnik
//
//  Created by Josef Roth on 07.10.18.
//  Copyright © 2018 Josef Roth. All rights reserved.
//

import UIKit
import AVFoundation

class AufnahmeTableEditor: UITableViewController {
    
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
    @IBAction func undoButton(_ sender: UIButton) {
        spur?.delay = false
        spur?.reverb = false
        spur?.highpass = false
        spur?.lowpass = false
        spur?.lowpitch = false
        spur?.highpitch = false
        Hall.setOn(false, animated: true)
        Echo.setOn(false, animated: true)
        Tiefpass.setOn(false, animated: true)
        Hochpass.setOn(false, animated: true)
        TieferPitch.setOn(false, animated: true)
        HoherPitch.setOn(false, animated: true)
    }
    
    @IBOutlet weak var Hall: UISwitch!
    @IBOutlet weak var Echo: UISwitch!
    @IBOutlet weak var Tiefpass: UISwitch!
    @IBOutlet weak var Hochpass: UISwitch!
    @IBOutlet weak var TieferPitch: UISwitch!
    @IBOutlet weak var HoherPitch: UISwitch!
    
    @IBAction func switchHall(_ sender: UISwitch) {
        spur?.reverb = !(spur?.reverb)!
        Hall.setOn((spur?.reverb)!, animated: true)
        if ((spur?.reverb)!) {
            print("Hall aktiviert: \((spur?.reverb)!)")
        }
        else {
            print("Hall deaktiviert: \((spur?.reverb)!)")
        }
    }
    @IBAction func switchEcho(_ sender: UISwitch) {
        spur?.delay = !(spur?.delay)!
        Echo.setOn((spur?.delay)!, animated: true)
    }
    @IBAction func switchTiefpass(_ sender: UISwitch) {
        spur?.lowpass = !(spur?.lowpass)!
        Tiefpass.setOn((spur?.lowpass)!, animated: true)
    }
    @IBAction func switchHochpass(_ sender: UISwitch) {
        spur?.highpass = !(spur?.highpass)!
        Hochpass.setOn((spur?.highpass)!, animated: true)
    }
    @IBAction func switchTieferPitch(_ sender: UISwitch) {
        spur?.lowpitch = !(spur?.lowpitch)!
        TieferPitch.setOn((spur?.lowpitch)!, animated: true)
        if (spur?.lowpitch)! {
            spur?.highpitch = false
            HoherPitch.setOn(false, animated: true)
        }
    }
    @IBAction func switchHoherPitch(_ sender: UISwitch) {
        spur?.highpitch = !(spur?.highpitch)!
        HoherPitch.setOn((spur?.highpitch)!, animated: true)
        if (spur?.highpitch)! {
            spur?.lowpitch = false
            TieferPitch.setOn(false, animated: true)
        }
    }
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .background).async {
            self.setupAudioEngine()
        }
        self.Hall.setOn((self.spur?.reverb)!, animated: true)
        self.Echo.setOn((self.spur?.delay)!, animated: true)
        self.Hochpass.setOn((self.spur?.highpass)!, animated: true)
        self.Tiefpass.setOn((self.spur?.lowpass)!, animated: true)
        self.HoherPitch.setOn((self.spur?.highpitch)!, animated: true)
        self.TieferPitch.setOn((self.spur?.lowpitch)!, animated: true)
        
        print("Hall Eingang: \((spur?.reverb)!)")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
    
    // Übermitteln der Membervariable an AufnahmenController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextScene = segue.destination as? AufnahmenController {
            nextScene.spuren![index!] = self.spur!
            nextScene.tableView.reloadData()
            print("Hall Ausgang: \((spur?.reverb)!)")
            print("Hall dort: \(nextScene.spuren![index!].reverb)")
        }
    }
    // ---------------------------------

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
            
            enginePlayer.play()
        }
    }
    func pause() {
        enginePlayer.pause()
    }
    func stop() {
        enginePlayer.stop()
    }

}
