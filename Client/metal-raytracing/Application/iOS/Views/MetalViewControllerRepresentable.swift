//
//  MetalViewControllerRepresentable.swift
//  MPSDynamicScene-iOS
//
//  Created by Daniel Williamson on 11/13/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit



struct MetalViewController: UIViewControllerRepresentable {
    
    var activeScan: HeadScanJSONModel
    var dataModel: HeadScanDataModel
    
    init(activeScan: HeadScanJSONModel) {
        self.activeScan = activeScan
        self.dataModel = HeadScanDataModel(verts: activeScan.vertices, faces: activeScan.faces, normals: activeScan.normals, val: activeScan.val, size: activeScan.size)
    }
    
    
    
     func makeUIViewController(context: Context) -> ViewController {
        print("Making Metal View Controller")
        //Instantitate
        let metalViewController: ViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "Metal-ObjC")
        
        // Create Pointers to pass arrays to C code.
        
        let verticePointer = UnsafeMutablePointer<SIMD3<Float>>.allocate(capacity: dataModel.size)
        verticePointer.initialize(from: dataModel.vertices, count: dataModel.size)
        
        let normalPointer = UnsafeMutablePointer<SIMD3<Float>>.allocate(capacity: dataModel.size)
        normalPointer.initialize(from: dataModel.normals, count: dataModel.size)
        
        let valPointer = UnsafeMutablePointer<Float>.allocate(capacity: dataModel.size)
        valPointer.initialize(from: dataModel.val, count: dataModel.size)
        
        metalViewController.addDataModel(withVertices: verticePointer, normals: normalPointer, val: valPointer, size: Int32(dataModel.size))
      
        
        return metalViewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        print("updated")
    }
    
//    func makeCoordinator() -> (MetalCoordinator) {
//        return MetalCoordinator()
//    }
//    
    typealias UIViewControllerType = ViewController
    
//    class MetalCoordinator {
//        init(activeScan: HeadScanJSONModel, parent: UIViewControllerRepresentable) {
//            self.parent =
//        }
//    }
    func addActiveScantoScene(scan: HeadScanJSONModel) {
        
    }
    
}
