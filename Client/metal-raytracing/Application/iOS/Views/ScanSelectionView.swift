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
            List(scans) { scan in
                NavigationLink(destination: MetalViewController(activeScan: headscans[0])) {
//                NavigationLink(destination: MetalView(activeScan: $headscans[0])) {
                    HStack {
                        Image(scan.previewURL)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.all)
                            .frame(width: 175, height: 175 )
                        Spacer()
                        VStack {
//                            Text(scan.name)
//                            Text(scan.id)
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




let scans = [
    HeadScanListModel(name: "Albert Gator", id: "001"),
    HeadScanListModel(name: "Alberta Gator", id: "002")
]
