//
//  ScanSelectionView.swift
//  NSG_Metal_Render3D
//
//  Created by Daniel Williamson on 10/25/20.
//

import SwiftUI

struct ScanSelectionView: View {
    
    @State var didSucceed: Bool = false
    
    var body: some View {
        NavigationView {
            List(scans) { scan in
                NavigationLink(destination: MetalView()) {
                    HStack {
                        Image(scan.previewURL)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.all)
                            .frame(width: 175, height: 175 )
                        Spacer()
                        VStack {
                            Text(scan.name)
                            Text(scan.id)
                        }
                    }
                    .frame(height:150)
                    .cornerRadius(15.0)
                }
            }
            .navigationBarTitle("Scans")
        }
        

    }
}

struct ScanSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ScanSelectionView()
    }
}

struct Scan: Identifiable {
    let name: String
    let previewURL: String = "ico"
    let data: Int
    let id: String
}

let scans = [
    Scan(name: "Albert Gator", data: 1, id: "001"),
    Scan(name: "Alberta Gator", data: 1, id: "002"),
    Scan(name: "John Doe", data: 1, id: "003"),
    Scan(name: "Jane Doe", data: 1, id: "004")
]
