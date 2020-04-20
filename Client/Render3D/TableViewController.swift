//
//  TableViewController.swift
//  Render3D
//
//  Created by Jonas Pena on 4/15/20.
//  Copyright © 2020 Jonas Pena. All rights reserved.
//

import Foundation

class TableViewController : UITableViewController {
    
    private var observation: NSKeyValueObservation?
    var studiesData = [Study]()
 
    var filename : String = ""
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studiesData.count
    }
    
    
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCell
        cell.patientNameLabel.text = "Patient Name: " + studiesData[indexPath.row].patientName
        cell.studyNameLabel.text = "Study Name: " + studiesData[indexPath.row].studyName
        cell.studyStatusLabel.text = "Study Status: " + studiesData[indexPath.row].studyStatus
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        
      
        let studyID = studiesData[indexPath.row].studyId
        let patientName = studiesData[indexPath.row].patientName
        //create a string dict from the username and password
        //let params = ["username":username, "password": password] as! Dictionary<String, String>
        
        //create a urlrequest type, passing in the url to the local server
        let request = NSMutableURLRequest(url: NSURL(string: "http://192.168.1.124:8000/studies?studyID=" + studyID)! as URL)
        //set the method to "POST"
        request.httpMethod = "GET"
      
        //create a task o
        
        var task = URLSession.shared.downloadTask(with: request as URLRequest){ data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")

                }

                do {
                    let documentDirUrl = try FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    
                    var fileURL = documentDirUrl.appendingPathComponent(patientName)
                    fileURL.appendPathExtension("nii")
                    fileURL.appendPathExtension("gz")
                    self.filename = patientName + ".nii.gz"
                    try FileManager.default.moveItem(at: data!, to: fileURL)
                    
                   

                }
                catch  {
                    print("Error writing file: Either already exists with that name or some kind of error")
                }
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "clickedCellSegue", sender: self)
                }
//                else{
//                    DispatchQueue.main.async {
//
//                        let alert = UIAlertController(title: "Alert", message: "Incorrect username or password", preferredStyle: .alert)
//                        let dismissAction = UIAlertAction(title: "Dismiss", style: .default){ (action:UIAlertAction) in
//                            alert.dismiss(animated: true, completion: nil)
//                        }
//                        alert.addAction(dismissAction)
//                        self.present(alert, animated: false, completion: nil)
//                    }
//
//                }
            }
            
        }
        observation = task.progress.observe(\.fractionCompleted) { progress, _ in
          print("progress: ", progress.fractionCompleted)
        }
        task.resume()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "clickedCellSegue", let vc = segue.destination as? Progress {
            vc.nameOfFile = filename
        }
    }
}
