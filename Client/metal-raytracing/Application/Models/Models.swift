//
//  User.swift
//  NSG_Metal_Render3D
//
//  Created by Daniel Williamson on 10/25/20.
//
import Foundation
import simd

struct loginResponse: Codable {
    let scans: [HeadScanJSONModel]
}

struct scansResponse: Codable {
    let response: [HeadScanJSONModel]
}

struct UserJSONModel: Codable {
    let username: String
}

struct HeadScanListModel: Identifiable, Codable {
    let name: String
    var previewURL: String = "ico"
    let id: String
}
struct HeadScanJSONModel: Codable {
    let size: Int
    let vertices: [[Float]]
    let faces: [[Float]]
    let normals: [[Float]]
    let val: [Float]
}
struct HeadScanDataModel {
    var vertices = [SIMD3<Float>]()
    var faces = [SIMD3<Float>]()
    var normals = [SIMD3<Float>]()
    var val: [Float]
    var size: Int
    
    init(verts: [[Float]], faces: [[Float]], normals: [[Float]], val: [Float], size: Int) {
        for index in 1...val.count {
            self.vertices.append(SIMD3<Float>(verts[index - 1]))
            self.faces.append(SIMD3<Float>(faces[index - 1]))
            self.normals.append(SIMD3<Float>(normals[index - 1]))
            
            
        }
        self.val = val
        self.size = size
        
    }
}


struct HeadScan: Identifiable {
    var id: String {
        return scanID
    }
    let scanID: String
}


