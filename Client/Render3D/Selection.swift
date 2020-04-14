//
//  Selection.swift
//  Render3D
//
//  Created by Harihar Khanal on 4/13/20.
//  Copyright © 2020 Jonas Pena. All rights reserved.
//

import UIKit

class Selection: UIViewController {
    
    @IBOutlet var template: UIButton!
    
    @IBOutlet var patient: UIButton!
    
    @IBOutlet var procedures: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        template.layer.cornerRadius = 10
        patient.layer.cornerRadius = 10
        procedures.layer.cornerRadius = 10
        
        self.navigationItem.hidesBackButton = true
        print("begin selection")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func templateClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "toProgressFromTemplate", sender: self)
    }
    @IBAction func patientHeadScanClicked(_ sender: Any) {
         self.performSegue(withIdentifier: "toProgressFromHeadScan", sender: self)
    }
    @IBAction func proceduresClicked(_ sender: Any) {
         self.performSegue(withIdentifier: "toProgressFromProcedures", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProgressFromTemplate", let vc = segue.destination as? Progress {
            vc.buttonClicked = "Template"
        }
        else if segue.identifier == "toProgressFromHeadScan", let vc = segue.destination as? Progress {
            vc.buttonClicked = "Patient Headscan"
        }
        else if segue.identifier == "toProgressFromProcedures", let vc = segue.destination as? Progress {
            vc.buttonClicked = "Procedures"
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
