//
//  User.swift
//  NSG_Metal_Render3D
//
//  Created by Daniel Williamson on 10/25/20.
//

import Foundation

struct loginResponse: Decodable {
    let response: [User]
}

//struct scansResponse: Decodable {
//    let response: [Scan]
//}

struct User: Decodable, Identifiable {
    var id: String {
        return objectID
    }
    let objectID: String
    let username: String
}
//
//struct Scan: Decodable, Identifiable {
//    var id: String {
//        return objectID
//    }
//    let objectID: String
//    let patientName: String
//    let data: String
//}
