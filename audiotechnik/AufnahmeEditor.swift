//
//  AufnahmeEditor.swift
//  audiotechnik
//
//  Created by Jana Puschmann und Josef Roth on 01.07.18.
//  Copyright © 2018 Jana Puschmann und Josef Roth. All rights reserved.
//


import UIKit

class AufnahmeEditor: UIViewController {
    
    // Member
    var index: Int? = nil
    var spur: Spur? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
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
