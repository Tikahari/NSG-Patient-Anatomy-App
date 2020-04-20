//
//  ViewController.swift
//  Render3D
//
//  Created by Jonas Pena on 2/9/20.
//  Copyright © 2020 Jonas Pena. All rights reserved.
//

import UIKit
import SceneKit


let IP_target = "192.168.1.138"
let PORT_target = "8000"

class ViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var studies = [Study]()
    var readyToSegue = false
    
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
        let request = NSMutableURLRequest(url: NSURL(string: "http://192.168.1.124:8000/login")! as URL)
        let bodyData = "username=" + username! + "&password=" + password!;
        //set the method to "POST"
        request.httpMethod = "POST"
        request.httpBody = bodyData.data(using: String.Encoding.utf8)
        //create a task o
        var task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode == 200){
                    
                    self.readyToSegue = true
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                        var studiesArray = [Study]()
                        let jsonArray = (json as! Array<NSObject>)
                
                        for study in jsonArray{
                            let patientName = study.value(forKey: "patientName") as! String
                            let studyId = (study.value(forKey: "studyID") as! String)
                            let studyName = study.value(forKey: "studyName") as! String
                            let studyStatus = study.value(forKey: "studyStatus") as! String
                            
                            let newStudy = Study(patientName: patientName, studyId: studyId, studyName: studyName, studyStatus: studyStatus)
                            studiesArray.append(newStudy)
                        }
                        self.studies = studiesArray
                    }
                    DispatchQueue.main.async {
                        if(self.readyToSegue){ self.performSegue(withIdentifier: "loginSegue", sender: self) }
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
        if segue.identifier == "loginSegue", let vc = segue.destination as? TableViewController {
            vc.studiesData = self.studies
        }
    }
    
}

