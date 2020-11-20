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
    
    init(activeScan: HeadScanJSONModel) {
        self.activeScan = activeScan
    }
    
    
    func makeUIViewController(context: Context) -> ViewController {
        print("Making Metal View Controller")
        //Instantitate
        let metalViewController: ViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "Metal-ObjC")
        var dataModel: HeadScanDataModel = HeadScanDataModel(verts: activeScan.vertices, faces: activeScan.faces, normals: activeScan.normals, val: activeScan.val)
//        dataModel.vertices.withUnsafeBufferPointer {
//            (vertices: UnsafeBufferPointer<vector_float3>) -> () in vertices.baseAddress
//        }
        //add scan to view controller
        metalViewController.addDataModel(withVertices: &dataModel.vertices, normals: &dataModel.normals, faces: &dataModel.faces, val: &dataModel.val)
      
        
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
