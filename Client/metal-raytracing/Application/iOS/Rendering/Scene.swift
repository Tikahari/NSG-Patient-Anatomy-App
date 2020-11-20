import Foundation
import simd
import MetalKit
import MetalPerformanceShaders

struct Uniforms {
    let viewMatrix: matrix_float4x4
    let viewProjectionMatrix: matrix_float4x4
    let width: UInt
    let height: UInt
    let frameIndex: UInt
    let jitter: SIMD2<Float>
}


class SceneEngine {

    // Acceleration structure rebuilds occur on the CPU timeline even when building
    // on the GPU, so you may have multiple builds in flight simultaneously. Similarly,
    // the CPU may be rebuilding an acceleration structure while the GPU is using it
    // for intersection. Therefore, you need one instance acceleration structure per
    // frame. In contrast, triangle acceleration structures are built once at startup
    // and are either static or only refit from frame to frame, so you only need one
    // triangle acceleration structure per object.
    //
    // Note that using an instance acceleration structure instead of directly intersecting
    // a triangle acceleration structure typically has a performance cost. If there is
    // only one object in the scene or if you can afford to pack the objects in the scene
    // into a single triangle acceleration structure it is typically preferable to use
    // a single triangle acceleration structure and intersect it directly.
    var instanceAccelerationStructures = [MPSInstanceAccelerationStructure]()

    var device: MTLDevice
    var library: MTLLibrary
    var commandQueue: MTLCommandQueue
    var frameIndex: Int!

    let encodeSemaphore = DispatchSemaphore(value: 1)

    var sceneObjects = [SceneObject]()
    var sceneObjectInstances = [SceneObjectInstance]()
    
    var instanceTransformsSize: Int!
    var instanceNormalTransformsSize: Int!
    
    var instanceTransformBuffer: MTLBuffer!
    var instanceNormalTransformBuffer: MTLBuffer!
    var instanceBuffer: MTLBuffer!
    

    init(device: MTLDevice, library: MTLLibrary, commandQueue: MTLCommandQueue) {
        self.device = device
        self.library = library
        self.commandQueue = commandQueue
    }

    func getInstanceTransformsSize() -> Int {
        // Buffer offsets need to be aligned to 256 bytes on macOS, so align each buffer
        // range to 256 bytes.
        return ((self.instanceTransformsSize + 255) & ~255)
    }

    func updateInstanceTransformsSize() {
        self.instanceTransformsSize = self.sceneObjectInstances.count * MemoryLayout<simd_float4x4>.size
    }

    func getInstanceTransformsBufferSize() -> Int {
        // You need to allocate space in the buffer for each frame which can be
        // simultaneously in flight. This allows the CPU to write into one region of the
        // buffer while the GPU is reading from another region, which avoids stalling the
        // GPU.

        // Allocate one extra buffer range (maxFramesInFlight + 1) so that the previous
        // frame's transformation matrices will always be available even if the CPU has
        // started writing into the oldest frame's buffer range.
        return Int(self.instanceTransformsSize * Constants.maxFramesInFlight + 1)
    }

    func updateNormalTransformsSize() {
        self.instanceNormalTransformsSize = self.sceneObjectInstances.count * MemoryLayout<simd_float3x3>.size

    }

    func getInstanceNormalTransformsSize() -> Int {
        return((self.instanceNormalTransformsSize + 255) & ~255)
    }

    func instanceNormalTransformsBufferSize() -> Int {
        return (self.instanceNormalTransformsSize) * (Constants.maxFramesInFlight + 1)
    }

    func instanceBufferSize() -> Int {
        let instancesSize = self.sceneObjectInstances.count * MemoryLayout<UInt32>.size
        return (instancesSize + 255) & ~255
    }

    func instanceTransformBufferOffset() -> Int {
        return (self.instanceTransformsSize * (frameIndex % (Constants.maxFramesInFlight + 1)))
    }

    func previousInstanceTransformBufferOffset() -> Int {
        let index = (Int(self.frameIndex) % (Constants.maxFramesInFlight + 1))
        // Wrap around backwards if needed
        return (self.instanceTransformsSize * (index))
    }

    func instanceNormalTransformBufferOffset() -> Int {
        return (self.instanceNormalTransformsSize * (frameIndex % (Constants.maxFramesInFlight + 1)))
    }

    func accelerationStructure() -> MPSInstanceAccelerationStructure {
        return self.instanceAccelerationStructures[Int(Int(self.frameIndex) % Constants.maxFramesInFlight)]
    }

    // Create vertex buffers, instance buffer, etc.
    func createBuffers(){

        // Allocate buffers
        let instanceTransformsBufferSize = self.getInstanceTransformsBufferSize()
        let instanceNormalTransformsBufferSize = self.instanceNormalTransformsBufferSize()
        let instanceBufferSize = self.instanceBufferSize()

        self.instanceTransformBuffer = self.device.makeBuffer(length: instanceTransformsBufferSize)
        self.instanceNormalTransformBuffer = self.device.makeBuffer(length: instanceNormalTransformsBufferSize)
        self.instanceBuffer = self.device.makeBuffer(length: instanceBufferSize)

        // Write object ID into the instance buffer for each instance. This will be used by
        // the instance acceleration structure to index into the array of per-object
        // triangle acceleration structures.
//        for instance in self.sceneObjectInstances {
//            //Write to instance
////            self.transform
//        }


        // When using managed buffers, you need to indicate that you modified the buffer
        // so that the GPU copy can be updated
    }

    func createAccelerationStructures() {}

    func finalize() {

    }

    func updateVerticesWithCommandBuffer(time: Float, commandBuffer: MTLCommandBuffer){

    }

    func updateInstances() {

    }

    func encodeReffitingToCommandBuffer(commandBuffer: MTLCommandBuffer){

    }

    func updateWithCommandBuffer(commandBuffer: MTLCommandBuffer,
                                 time: Float, completedHandler: MPSInstanceAccelerationStructure){

    }


}


class SceneObject {

    var animated: Bool!
    var vertexCount: UInt8!

    init(animated: Bool, vertexCount: UInt8) {
        self.animated = animated
        self.vertexCount = vertexCount
    }

    func getVertices(vertices: SIMD3<Float>, normals: SIMD4<Float>) {

    }

    func updateVerticesWithCommandBuffer(commandBuffer: MTLCommandBuffer,
                                         vertexBuffer: MTLBuffer,
                                         normalBuffer: MTLBuffer,
                                         bufferOffset: UInt8,
                                         time: Float) {

    }
}

class SceneObjectInstance {
    var obj: SceneObject!
    var transform: simd_float4x4!
    
    init(obj: SceneObject, transform: simd_float4x4) {
        self.obj = obj
        self.transform = transform
    }
}




