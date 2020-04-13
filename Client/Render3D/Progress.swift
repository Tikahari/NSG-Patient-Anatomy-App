//
//  Progress.swift
//  Render3D
//
//  Created by Tikahari Khanal on 4/12/20.
//  Copyright © 2020 Jonas Pena. All rights reserved.
//

import UIKit

class Progress: UIViewController {
    
    
    @IBOutlet var progressCircle: circlular!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let timer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(selection), userInfo: nil, repeats: false)
        
        let rgbColor = UIColor(
            red: 30.0 / 255,
            green: 70.0 / 255,
            blue: 200.0 / 255,
            alpha: 1.0
        )
        self.navigationItem.hidesBackButton = true
        progressCircle.trackColor = UIColor.red
        
        progressCircle.layer1Color = UIColor.white
        //animation speed
//        progressCircle.layer.speed = 0.05
        self.perform(#selector(progress), with: nil, afterDelay: 2.0)
    }
    
    @objc func selection(){
        self.performSegue(withIdentifier: "toSelection", sender: self)
    }
    
    @objc func progress(){
        progressCircle.setProgress(duration: 5.0, value: 1)
//        self.performSegue(withIdentifier: "toSelection", sender: self)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
}

