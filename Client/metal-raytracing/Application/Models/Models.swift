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

struct HeadScanJSONModel: Identifiable, Codable {
    let name: String = "Patient n"
    let id: String
    let size: Int
    let vertices: [[Float]]
    let faces: [[Float]]
    let normals: [[Float]]
    let val: [Float]
    let dim: SIMD3<Float>
    let voxels: [[[Float]]]
}
struct HeadScanDataModel {
    var vertices = [SIMD3<Float>]()
    var faces = [SIMD3<Float>]()
    var normals = [SIMD3<Float>]()
    var val: [Float]
    var dim: SIMD3<Float>
    var size: Int
    var voxelArray: MDLVoxelArray
    var voxels: [[[Float]]]
    var mesh: MDLMesh!
    
    init(verts: [[Float]], faces: [[Float]], normals: [[Float]], val: [Float], dim: SIMD3<Float>, size: Int, voxels: [[[Float]]]) {
        for index in 1...val.count {
            self.vertices.append(SIMD3<Float>(verts[index - 1]))
            self.faces.append(SIMD3<Float>(faces[index - 1]))
            self.normals.append(SIMD3<Float>(normals[index - 1]))
            
            
        }
        self.val = val
        self.size = size
        self.voxels = voxels
        self.dim = dim
        self.voxelArray = MDLVoxelArray(data: Data(count: size), boundingBox: MDLAxisAlignedBoundingBox(maxBounds: SIMD3<Float>(self.dim.x,self.dim.y,self.dim.z), minBounds: SIMD3<Float>(0,0,0)), voxelExtent: 1)
    }
}


struct HeadScan: Identifiable {
    var id: String {
        return scanID
    }
    let scanID: String
}


