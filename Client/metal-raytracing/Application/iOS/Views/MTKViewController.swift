
//import UIKit
//import MetalKit
//
//class MTKViewController: UIViewController {
//
//    var renderer: Renderer!
//    var mtkView: MTKView!
//    
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        guard let mtkView = self.view as? MTKView,
//              let defaultDevice = MTLCreateSystemDefaultDevice() else { fatalError() }
//        mtkView.device = defaultDevice
////        renderer = Renderer(metalKitView: mtkView)
////        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
////        mtkView.delegate = renderer
//    }
//}
