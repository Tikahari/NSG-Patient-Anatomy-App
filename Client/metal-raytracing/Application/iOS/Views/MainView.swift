//
//  MainView.swift
//  NSG_Metal_Render3D
//
//  Created by Daniel Williamson on 10/25/20.
//

import SwiftUI
import UIKit

// let MainViewController = UIHostingController(rootView: ScanSelectionView())

struct MainView: View {
    
    @State var authenticationDidSucceed: Bool = false
    @State var username: String = ""
    
    var body: some View {
//        addSubview(MainViewController.view)
        if authenticationDidSucceed {
//            ScanSelectionView()
//            MetalViewController()
        } else {
            LoginView(authenticationDidSucceed: $authenticationDidSucceed)
        }
        
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
