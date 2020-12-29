//
//  NetworkManager.swift
//  NSG_Metal_Render3D
//
//  Created by Daniel Williamson on 10/25/20.
//

import Foundation

let IP_target = "192.168.1.15" //This is dependant on where the django "Medical Server" is running.

let PORT_target = "8080"

//import Alamofire
//import PromisedFuture

class NetworkController: ObservableObject {
    
    @Published var isAuthenticated: Bool = false
    @Published var authenticationDidFail: Bool = false
    @Published var activeUser: String = ""
    @Published var scans = [HeadScanJSONModel]()
    
    var userAuth = [UserJSONModel]()
    
    
    func GETAvailableScans(){}
    
//    url: String , packageId : Int ,callback :@escaping (myObject) -> Void , errorCallBack : @escaping (String) -> Void ){
//
//    let token = spm.getUserToken()
//    let headers = ["X-Auth-Token" : token]
//    let newUrl = url + "?packageId=" + String(packageId)
//
//    sendApi(url: url, httpMethod: HTTPMethod.get , parameters: nil, encoding: JSONEncoding.default, headers: headers, callbackSuccess: {(jsonObject) in
//
//    } , callbackFailure:{ (jsonObject)in
//
//    })
//}
    
    
    
    
    func POSTUserAuthentication(password: String, username: String){
        
//        let loginFuture = APIClient.login(username: username, password: password)
//
//        loginFuture.execute(onSuccess: {headscan in
//            self.isAuthenticated = true
//            print(headscan)
//        }, onFailure: {error in
//
//            print(error)
//        })
//
            let request = NSMutableURLRequest(url: NSURL(string: "http://" + IP_target + ":" + PORT_target + "/login?username")! as URL)

            let bodyData = "username=" + username + "&password=" + password;


            //set the method to "POST"
            request.httpMethod = "POST"
            request.httpBody = bodyData.data(using: String.Encoding.utf8)

            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request as URLRequest) { (data, response, err) in
                if err == nil {
                    if let safeData = data {
                        do {
                            if let httpResponse = response as? HTTPURLResponse {
                                if(httpResponse.statusCode == 200){
                                    do {
                                        let decoder = JSONDecoder()
                                        let jsonresponse = try decoder.decode(loginResponse.self, from: safeData)
    
                                        DispatchQueue.main.async {

                                            self.authenticationDidFail = false
                                            self.isAuthenticated = true
                                            self.scans = jsonresponse.scans
                                        }
                                    } catch {
                                        print("error: ", error)
                                    }
                                    
                                    
                                    
                                    

                                } else {
                                    DispatchQueue.main.async {
                                        self.authenticationDidFail = true
                                    }
                                }
                            }


                        } 
                    }
                }
            }
            task.resume()
        }

    

    
    func returnUsername() -> String {
        return self.userAuth[0].username
    }
}
