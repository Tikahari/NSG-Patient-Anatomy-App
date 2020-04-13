//
//  ViewController.swift
//  Render3D
//
//  Created by Jonas Pena on 2/9/20.
//  Copyright © 2020 Jonas Pena. All rights reserved.
//

import UIKit
import SceneKit

let IP_target = "127.0.0.1"
let PORT_target = "8000"

class ViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("did load")
        
        
        
    }
    


    @IBAction func submitAction(_ sender: Any) {
        
        //grab username from field
        let username = usernameField.text;
        
        //grab password from field
        let password = passwordField.text;
        
        //create a string dict from the username and password
        let params = ["username":username, "password": password] as! Dictionary<String, String>
        
        //create a urlrequest type, passing in the url to the local server
        let request = NSMutableURLRequest(url: NSURL(string: "http://127.0.0.1:8000/login/")! as URL)
        print("request url")
        //set the method to "POST"
        request.httpMethod = "POST"
        request.addValue("jvFsM5rh6PtLak1l5hSgAs5uO1vSvagajQFe9T7oqTGdQh8cBGZA5mORApofmX9f", forHTTPHeaderField: "X-CSRF-TOKEN")
        //create a task o
        var task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
            print(data)
            print(response)
            print(error)
            
            
        }
        task.resume()
}
}

