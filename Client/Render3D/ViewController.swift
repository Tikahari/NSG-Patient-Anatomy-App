//
//  ViewController.swift
//  Render3D
//
//  Created by Jonas Pena on 2/9/20.
//  Copyright © 2020 Jonas Pena. All rights reserved.
//

import UIKit
import SceneKit


class ViewController: UIViewController {
    
    @IBOutlet var submit: UIButton!
    @IBOutlet weak var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        submit.layer.cornerRadius = 10
        print("did load")
    }


//    @IBAction func onSubmit(_ sender: Any) {
//        let VC = self.storyboard?.instantiateViewController(withIdentifier: "progress") as! Progress
//        self.present(VC, animated: true, completion: nil)
//    }

}

