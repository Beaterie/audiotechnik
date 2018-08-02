//
//  AufnahmenController.swift
//  audiotechnik
//
//  Created by Jana Puschmann und Josef Roth on 01.07.18.
//  Copyright © 2018 Jana Puschmann und Josef Roth. All rights reserved.
//


import UIKit

class AufnahmenController: UITableViewController {
    
    // Membervariablen
    var spuren: [Spur]? = nil
    // ---------------------------------
    
    
    // Zurück zum Startbildschirm
    @IBAction func zurueckZumStartbildschirm(_ sender: Any) {
        performSegue(withIdentifier: "zumStartbildschirm", sender: self)
    }
    // ---------------------------------
    
    
    // Übermitteln der Membervariable an Startbildschirm/AufnahmeEditor
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextScene = segue.destination as? Startbildschirm {
            if segue.identifier == "zumStartbildschirm" {
                nextScene.spuren = spuren!
            }
        }
        else if let nextScene = segue.destination as? AufnahmeEditor,
            let indexPath = self.tableView.indexPathForSelectedRow  {
            if segue.identifier == "zumAufnahmeEditor" {
                nextScene.spur = self.spuren?[indexPath.row]
                nextScene.index = indexPath.row
                nextScene.title = self.spuren?[indexPath.row].name
            }
        }
    }
    // ---------------------------------
    
    
    // Anzahl an Sektionen/Kategorien
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // ---------------------------------
    
    
    // Anzahl an Zellen
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spuren!.count
    }
    // ---------------------------------
    
    
    // Befüllen einer einzelnen Zelle mit den Inhalten aus der entsprechenden Membervariable
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpurenZelle", for: indexPath) as! SpurenZelle
        
        cell.zellenInhalt = spuren![indexPath.row]
        
        return cell
    }
    // ---------------------------------

    
    // Zusatzoptionen pro Zelle (Abspielen und Löschen)
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
//        let play = UITableViewRowAction(style: .normal, title: "Abspielen") { action, index in
//            print("Abgespielt.")
//        }
//        play.backgroundColor = .blue //UIColor(red: 0, green: 0.549, blue: 1, alpha: 1)
        
        let delete = UITableViewRowAction(style: .normal, title: "Löschen") { action, index in
            print("Gelöscht?")
            let alert = UIAlertController(title: "Möchtest Du diese Spur wirklich löschen?", message: "Die Löschung der Spur kann nicht rückgängig gemacht werden!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ja", style: .default, handler: { action in
                self.spuren!.remove(at: editActionsForRowAt.row)
                self.tableView.reloadData()
                print("Ja!")
            }))
            alert.addAction(UIAlertAction(title: "Nein", style: .cancel, handler: { action in
                print("Nein!")
            }))
            
            self.present(alert, animated: true)
        }
        delete.backgroundColor = .red
        
//        return [play, delete]
        return [delete]
    }
    // ---------------------------------
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // Übergang zurück zu diesem Bildschirm
    @IBAction func zumAufnahmeController(segue: UIStoryboardSegue) {
        print("Zurück zum AufnahmeController")
    }
    // ---------------------------------
 
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
