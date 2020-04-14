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
    var buttonClicked : String = ""
    var fromLogin = false
    var interval = 0.0
    var delay = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        print("from login", fromLogin)
        if (fromLogin) {
            interval = 10.0
            delay = 1.0
        }
        else{
            interval = 45.0
            delay = 2.0
        }
        let timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(selection), userInfo: nil, repeats: false)
        print(buttonClicked)
        let rgbColor = UIColor(
            red: 30.0 / 255,
            green: 70.0 / 255,
            blue: 200.0 / 255,
            alpha: 1.0
        )
        self.navigationItem.hidesBackButton = true
        progressCircle.trackColor = UIColor.red
        
        progressCircle.layer1Color = UIColor.white
        self.perform(#selector(progress), with: nil, afterDelay: 0.5)
    }
    
    @objc func selection(){
        self.performSegue(withIdentifier: "toSelection", sender: self)
    }
    
    @objc func progress(duration: TimeInterval){
        progressCircle.setProgress(duration: interval, value: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelection", let vc = segue.destination as? VTKViewer {
            vc.setValue(buttonClicked, forKey: "titleText");
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
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
}

