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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
