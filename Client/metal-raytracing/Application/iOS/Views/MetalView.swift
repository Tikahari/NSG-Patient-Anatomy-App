//
//  MetalView.swift
//  NSG_Metal_Render3D
//
//  Created by Daniel Williamson on 10/25/20.
//

import SwiftUI
import MetalKit
import simd
import MetalPerformanceShaders


//var objectivec_renderer = Renderer()

struct MetalView: UIViewRepresentable {
    @Binding var activeScan: HeadScanJSONModel
    	
    // Lifecycle Check: 1 - Make Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    // Lifecycle Check: 2 - Make View (give it context)
    func makeUIView(context: UIViewRepresentableContext<MetalView>) -> MTKView {
        
        
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        mtkView.sampleCount = 1
        mtkView.colorPixelFormat = MTLPixelFormat.rgba16Float
        
        //1. create device - representation of iPhone / system GPU
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0)
        mtkView.drawableSize = mtkView.frame.size
        mtkView.enableSetNeedsDisplay = true
        
        return mtkView
    }
    
    // Lifecycle Check: 3 : update view as neccessary (also should be contextualized)
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<MetalView>) {
    }
    
    //Lifecycle Check 4: Dismantle View
    func dismantleUIView(_  uiView: MTKView, context: UIViewRepresentableContext<MetalView>) {
    }
    
    class Coordinator : NSObject, MTKViewDelegate {
        var view: MTKView?
        var device: MTLDevice?
        var queue: MTLCommandQueue?
        var library: MTLLibrary?
        var frameIndex: Int?
        
        var shadowPipeline: MTLComputePipelineState?
        var compositePipeline: MTLComputePipelineState?
        var copyPipeline: MTLRenderPipelineState?
        var renderPipeline: MTLRenderPipelineState?
        
        var previousTexture: MTLTexture?
        var previousDepthNormalTexture: MTLTexture?
        var shadowRayTexture: MTLTexture?
        var intersectionTexture: MTLTexture?
        var randomTexture: MTLTexture?
        
        var depthStencilState: MTLDepthStencilState?
        var intersector: MPSRayIntersector?
        var frameSemaphore: DispatchSemaphore!
        var size: CGSize!
        
        var textureAllocator: MPSSVGFDefaultTextureAllocator!
        var TAA: MPSTemporalAA!
        var denoiser: MPSSVGFDenoiser!
        
//        var uniforms = [Uniforms]()
        
        
        var parent: MetalView
        var activeScan: HeadScanJSONModel!
//        var scene: SceneEngine!
        

        var computePipelineState: MTLComputePipelineState!
        var samplerState: MTLSamplerState!
//        var textureAllocator: MPSSVGFDefaultTextureAllocator
        var svgf: MPSSVGF!

        
        init(_ parent: MetalView) {
            self.parent = parent
            if let metalDevice = MTLCreateSystemDefaultDevice() {
                self.device = metalDevice
                self.queue = metalDevice.makeCommandQueue()
                self.library = metalDevice.makeDefaultLibrary()
                
                
            }
            self.activeScan = self.parent.activeScan
            
            
            super.init()
            
            loadMPSSVGF()
            createPipelines()
            createIntersector()
            

//            scene = SceneEngine(
//                device: device!,
//                library: library!,
//                commandQueue: queue!)


            
            
//            self.computePipelineState = buildComputePipeline(device:self.metalDevice)
//            self.samplerState = buildSamplerState(device: self.metalDevice)
        }
        
        func loadMPSSVGF() {
            
            // The app only denoises shadows which only have a single-channel,
            // so set the channel count to 1. This is faster then denoising
            // all 3 channels on an RGB image.
            svgf = MPSSVGF(device: device!)
            
            // The app integrates samples over time while limiting ghosting artifacts,
            // so set the temporal weighting to an exponential moving average and
            // reduce the temporal blending factor
            svgf.channelCount = 1
            svgf.temporalWeighting = MPSTemporalWeighting.exponentialMovingAverage
            // Create the MPSSVGFDenoiser convenience object. Although you
            // could call the low-level denoising kernels directly on the MPSSVGF
            // object, for simplicity this sample lets the MPSSVGFDenoiser object
            // take care of it.
            denoiser = MPSSVGFDenoiser()
            
            // Adjust the number of bilateral filter iterations used by the denoising
            // process. More iterations will tend to produce better quality at the cost
            // of performance, while fewer iterations will perform better but have
            // lower quality. Five iterations is a good starting point. The best way to
            // improve quality is to reduce the amount of noise in the denoiser's input
            // image using techniques such as importance sampling and low-discrepancy
            // random sequences.
            denoiser.bilateralFilterIterations = 5;
            
            // Create the temporal antialiasing object
            TAA = MPSTemporalAA(device: device!)
        }
        
        func createPipelines(){
            let computeDescriptor = MTLComputePipelineDescriptor()
            computeDescriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
            
            computeDescriptor.computeFunction = library!.makeFunction(name: "shadowKernel")
                try! shadowPipeline = device!.makeComputePipelineState(function: computeDescriptor.computeFunction!)
            if((shadowPipeline == nil)){
                print("Error: No Shadow Pipeline")
            }
            
            computeDescriptor.computeFunction = library!.makeFunction(name: "compositeKernel")
            try! compositePipeline = device!.makeComputePipelineState(function: computeDescriptor.computeFunction!)
            if((compositePipeline == nil)){
                print("Error: No Composite Pipeline")
            }
            
            let renderDescriptor = MTLRenderPipelineDescriptor()
            renderDescriptor.sampleCount = 1
            renderDescriptor.vertexFunction = library!.makeFunction(name: "copyVertex")
            renderDescriptor.fragmentFunction = library!.makeFunction(name: "copyFragment")
            renderDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.rgba16Float
            try! copyPipeline = device!.makeRenderPipelineState(descriptor: renderDescriptor)
            if((compositePipeline == nil)){
                print("Error: No Copy Pipeline")
            }
            
            // This render pipeline rasterizes triangle geometry and outputs color, depth,
            // normals, motion vectors, and shadow rays
            renderDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.rgba16Float
            renderDescriptor.colorAttachments[1].pixelFormat = MTLPixelFormat.rgba16Float
            renderDescriptor.colorAttachments[2].pixelFormat = MTLPixelFormat.rg16Float
            renderDescriptor.colorAttachments[3].pixelFormat = MTLPixelFormat.rgba32Float
            renderDescriptor.colorAttachments[4].pixelFormat = MTLPixelFormat.rgba32Float
            
            renderDescriptor.depthAttachmentPixelFormat = MTLPixelFormat.depth32Float
            
            try! renderPipeline = device!.makeRenderPipelineState(descriptor: renderDescriptor)
            if((renderPipeline == nil)){
                print("Error: No Render Pipeline")
            }
        }

        // Initialize the MPS ray intersector
        func createIntersector(){
            // Create a ray intersector.
            intersector = MPSRayIntersector(device: device!)
            
            // Use the max distance field of the ray struct to ignore shadow
            // rays for pixels that do not have any geometry
            intersector!.rayDataType = MPSRayDataType.originMinDistanceDirectionMaxDistance
            
            intersector!.intersectionDataType = MPSIntersectionDataType.distance
        }
        

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            self.size = size
//
//            // Release any textures the denoiser is holding on to, then release
//            // everything from the texture allocators.
//            denoiser.releaseTemporaryTextures()
//            textureAllocator.reset()
//
//            self.previousDepthNormalTexture = textureAllocator.texture(with: MTLPixelFormat.rgba16Float, width: Int(size.width), height: Int(size.height))
//
//            self.previousTexture = textureAllocator.texture(with: MTLPixelFormat.rgba16Float, width: Int(size.width), height: Int(size.height))
//
//            let renderTargetDescriptor = MTLTextureDescriptor()
//
//            renderTargetDescriptor.width = Int(size.width)
//            renderTargetDescriptor.height = Int(size.height)
//
//            // Generate a 2xRGBA32Float 2D array texture to contain shadow ray origins,
//            // min distances, directions, and max distances.
//            renderTargetDescriptor.textureType = MTLTextureType.type2DArray
//            renderTargetDescriptor.pixelFormat = MTLPixelFormat.rgba32Float
//            renderTargetDescriptor.usage = [MTLTextureUsage.renderTarget, MTLTextureUsage.shaderRead]
//            renderTargetDescriptor.arrayLength = 2
//
//            shadowRayTexture = device!.makeTexture(descriptor: renderTargetDescriptor)
//
//            // Generate a 1xR32Float 2D array texture to contain the corresponding
//            // intersection distance.
//            renderTargetDescriptor.usage = [MTLTextureUsage.shaderWrite, MTLTextureUsage.shaderRead]
//            renderTargetDescriptor.arrayLength = 1
//            renderTargetDescriptor.pixelFormat = MTLPixelFormat.r32Float
//
//            intersectionTexture = device!.makeTexture(descriptor: renderTargetDescriptor)
//
//            // Finally, allocate a 2D R32UInt texture to contain random values for each
//            // pixel. This value is used to decorrelate pixels while drawing pseudorandom
//            // numbers from a Halton sequence while generating shadow rays.
//            renderTargetDescriptor.textureType = MTLTextureType.type2D
//            renderTargetDescriptor.pixelFormat = MTLPixelFormat.r8Uint
//            renderTargetDescriptor.usage = MTLTextureUsage.shaderRead
//            renderTargetDescriptor.arrayLength = 1
//
//            randomTexture = device!.makeTexture(descriptor: renderTargetDescriptor)
//
//            var randomValues = [UInt8]()
//            let width = Int(size.width)
//            let height = Int(size.height)
//            for _ in 1...width {
//                randomValues.append(UInt8(Int.random(in: 0...15)))
//            }
//            let ranMemSize = MemoryLayout<UInt8>.size * height
//
//            let region = MTLRegionMake2D(0, 0, width, height)
//            randomTexture!.replace(region:region,
//                            mipmapLevel:0,
//                            withBytes:randomValues,
//                            bytesPerRow:ranMemSize)
//            frameIndex = 0

        }
        
        func updateUniforms() {}
        
        func draw(in view: MTKView) {
            guard view.currentDrawable != nil else {
                return
            }

            
//            self.scene.rootNode.children.append(Sphere(name:"sphere1", radius:5, origin: SIMD3(0, 5, 5)))
//
//            let niftiVolume = NiftiVolume(name: "activeScan", scan: activeScan)
//
//            self.scene.rootNode.children.append(NiftiVolume(name: "activeScan", scan: activeScan ))
            
//            self.scene.lights.append(Light())

//            let commandBuffer = metalCommandQueue.makeCommandBuffer()!
//            let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
//            commandEncoder.setComputePipelineState(self.computePipelineState)
            
//            let rpd = view.currentRenderPassDescriptor
//            rpd?.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 1, 1)
//            rpd?.colorAttachments[0].loadAction = .clear
//            rpd?.colorAttachments[0].storeAction = .store
//            let re = commandBuffer.makeRenderCommandEncoder(descriptor: rpd!)
//            re?.endEncoding()
            
//            var screenUniforms = ScreenUniforms(
//                camera:self.camera
//            )
            
//            commandEncoder.setTexture(drawable.texture, index: 0)
//            var shaderObjects = [ShaderObject]()
//            for sphere in niftiVolume.children {
//                var shaderObject = sphere.shaderObject()
//                shaderObject.textureIndex = 0
//                commandEncoder.setTexture(sphere.baseColorTexture, index: Int(0))
//                shaderObjects.append(shaderObject)
//            }
            
//            print(shaderObjects)
 
//            var sceneUniforms = SceneUniforms(objects: shaderObjects)
//            var lightUniforms = LightUniforms(lights: scene.lights)

//            commandEncoder.setSamplerState(samplerState, index: 0)

//            commandEncoder.setBytes(&screenUniforms,length: MemoryLayout.size(ofValue: screenUniforms), index: 0)
//            commandEncoder.setBytes(&sceneUniforms, length: MemoryLayout.stride(ofValue: sceneUniforms), index: 1)
//            commandEncoder.setBytes(&lightUniforms, length: MemoryLayout.size(ofValue: lightUniforms), index: 2)
//            
//            commandEncoder.dispatchThreads(MTLSizeMake(drawable.texture.width, drawable.texture.height, 1),
//                                           threadsPerThreadgroup: MTLSizeMake(1, 1, 1))
//            
//            commandEncoder.endEncoding()
//            
//            commandBuffer.present(drawable)
//            commandBuffer.commit()
//            
        }
    }

}

struct MetalView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

