//
//  NetworkManager.swift
//  NSG_Metal_Render3D
//
//  Created by Daniel Williamson on 10/25/20.
//

import Foundation

let IP_target = "10.20.0.190" //This is dependant on where the django "Medical Server" is running.
let PORT_target = "8080"

class NetworkManager: ObservableObject {
    
    @Published var activeUser = [User]()
    @Published var isAuthenticated: Bool = false
    @Published var authenticationDidFail: Bool = false
//  @Published var scans = [Scan]()
    
    func POSTUserAuthentication(password: String, username: String){
        
            let request = NSMutableURLRequest(url: NSURL(string: "http://" + IP_target + ":" + PORT_target + "/login?username")! as URL)
            let bodyData = "username=" + username + "&password=" + password;
        
            //set the method to "POST"
            request.httpMethod = "POST"
            request.httpBody = bodyData.data(using: String.Encoding.utf8)
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request as URLRequest) { (data, response, err) in
                if err == nil {
//                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            if let httpResponse = response as? HTTPURLResponse {
                                if(httpResponse.statusCode == 200){
//                                    let response = try decoder.decode(loginResponse.self, from: safeData)
//                                    self.activeUser = response.response
                                    DispatchQueue.main.async {
                                        self.authenticationDidFail = false
                                        self.isAuthenticated = true
                                    }
                                    
                                } else {
                                    DispatchQueue.main.async {
                                        self.authenticationDidFail = true
                                    }
                                }
                            }
                            
                            
                        } catch {
                            print(err)
                        }
                    }
                }
            }
            task.resume()
        }

    
    func GETAvailableScans(){
        
    }
    
}
