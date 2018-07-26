//
//  SpurenZelle.swift
//  audiotechnik
//
//  Created by Jana Puschmann und Josef Roth on 01.07.18.
//  Copyright © 2018 Jana Puschmann und Josef Roth. All rights reserved.
//


import UIKit

class SpurenZelle: UITableViewCell {
    
    // Labels
    @IBOutlet weak var dauerLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    // ---------------------------------
    
    
    // Belegung der Labels mit den Inhalten der Membervariablen
    var zellenInhalt: Spur? {
        didSet {
            guard let spur = zellenInhalt else { return }
            nameLabel.text = spur.name
            dauerLabel.text = spur.dauer
        }
    }
    // ---------------------------------
    
    
    // Reinigung der Zellstruktur
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        dauerLabel.text = nil
    }
    // ---------------------------------
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
