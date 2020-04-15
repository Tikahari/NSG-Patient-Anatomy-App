//
//  ViewController.swift
//  Render3D
//
//  Created by Jonas Pena on 2/9/20.
//  Copyright © 2020 Jonas Pena. All rights reserved.
//

import UIKit
import SceneKit


let IP_target = "108.83.161.83"
let PORT_target = "8080"

class ViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
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
        let request = NSMutableURLRequest(url: NSURL(string: "http://" + IP_target + ":" + PORT_target + "/login?username")! as URL)
        let bodyData = "username=" + username! + "&password=" + password!;
        //set the method to "POST"
        request.httpMethod = "POST"
        request.httpBody = bodyData.data(using: String.Encoding.utf8)
        //create a task o
        var task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode == 200){
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "loginSegue", sender: self)
                    }
                    
                }
                else{
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: "Alert", message: "Incorrect username or password", preferredStyle: .alert)
                        let dismissAction = UIAlertAction(title: "Dismiss", style: .default){ (action:UIAlertAction) in
                            alert.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(dismissAction)
                        self.present(alert, animated: false, completion: nil)
                    }
                    
                }
            }
            
        }
        task.resume()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSegue", let vc = segue.destination as? Progress {
            vc.fromLogin = true
        }
    }
    
}

