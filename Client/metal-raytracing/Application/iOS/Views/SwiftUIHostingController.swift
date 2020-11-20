//
//  SwiftUIHostingController.swift
//  MPSDynamicScene
//
//  Created by Daniel Williamson on 11/13/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class SwiftUIHostingController: UIHostingController<MainView> {

    required init?(coder: NSCoder) {
        super.init(coder: coder,rootView: MainView());
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
