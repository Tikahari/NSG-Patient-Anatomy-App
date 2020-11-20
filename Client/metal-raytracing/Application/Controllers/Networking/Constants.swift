//
//  Constants.swift
//  NSG_Metal_Render3D
//
//  Created by Daniel Williamson on 11/1/20.
//

import Foundation

struct Constants {
    
    struct MedicalServer {
        static let baseURL = "http://10.20.0.190:8080"
    }
    
    struct APIParameterKey {
        static let password = "password"
        static let username = "username"
    }
    static let maxFramesInFlight: Int = 3
}

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
}
