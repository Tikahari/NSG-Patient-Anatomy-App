//
//  ScanSelectionView.swift
//  NSG_Metal_Render3D
//
//  Created by Daniel Williamson on 10/25/20.
//

import SwiftUI

struct ScanSelectionView: View {
    @Binding var headscans: [HeadScanJSONModel]
    @State var didSucceed: Bool = false

    var body: some View {
        NavigationView {
            List(headscans) { scan in

//                Navigation Link Destination: Obj-C Metal Controller
//                Arguments: Scan Destination: Currently
                NavigationLink(destination: MetalViewController(activeScan: scan)) {
                
//                Navigation Link Description: SwiftUI MetalKit View
//                NavigationLink(destination: MetalView(activeScan: $headscans[0])) {
                    HStack {
//                        Image(scan.previewURL)
                        Image("ico")
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
        Text("Preview")
    }
}
