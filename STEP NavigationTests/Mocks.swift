//
//  Mocks.swift
//  STEP NavigationTests
//
//  Created by Sam Coleman on 4/10/23.
//

import Foundation
import SceneKit
import ARKit

/**
    A mock class for `ARFrame` that allows you to set a custom camera transform for testing purposes.

    - Note: This class does not implement all the properties and methods of `ARFrame`. You can add more as needed.
*/
public class MockARFrame: ARFrame {
    
    private let cameraTransform: simd_float4x4
    
    /**
         Initializes a new instance of `MockARFrame` with the given camera transform.
         
         - Parameter cameraTransform: The custom camera transform to use for this mock frame.
     */
    public init(cameraTransform: simd_float4x4) {
        self.cameraTransform = cameraTransform
        super.init()
    }
    
    /**
        This method is not implemented in this mock class.
     */
    public required init() {
        fatalError("init() has not been implemented")
    }
    
    /**
         Returns a mock camera with the custom transform set in the initializer.
         
         - Note: This property is overridden to return a mock camera instead of a real one.
     */
    public override var camera: ARCamera? {
        return MockARCamera(transform: cameraTransform)
    }
}

/**
 A mock class for `ARCamera` that allows you to set a custom transform for testing purposes.
 
 - Note: This class does not implement all the properties and methods of `ARCamera`. You can add more as needed.
 */
public class MockARCamera: ARCamera {
    
    private let transform: simd_float4x4
    
    /**
         Initializes a new instance of `MockARCamera` with the given transform.
         
         - Parameter transform: The custom transform to use for this mock camera.
     */
    public init(transform: simd_float4x4) {
        self.transform = transform
        super.init()
    }
    
    /**
         This method is not implemented in this mock class.
     */
    public required init() {
        fatalError("init() has not been implemented")
    }
    
    /**
         Returns the custom transform set in the initializer.
         
         - Note: This property is overridden to return a custom transform instead of a real one.
     */
    public override var transform: simd_float4x4 {
        return transform
    }
}

/**
 A mock class for `SCNNode` that allows you to set a custom transform for testing purposes.
 
 - Note: This class does not implement all the properties and methods of `SCNNode`. You can add more as needed.
 */
public class MockSCNNode: SCNNode {
    
    private let transformValue: simd_float4x4
    
    /**
         Initializes a new instance of `MockSCNNode` with the given transform.
         
         - Parameter transform: The custom transform to use for this mock node.
     */
    public init(transform: simd_float4x4) {
        self.transformValue = transform
        super.init()
    }
    
    /**
         This method is not implemented in this mock class.
     */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
         Returns the custom transform set in the initializer.
         
         - Note: This property is overridden to return a custom transform instead of a real one.
     */
    public override var simdTransform: simd_float4x4 {
        return transformValue
    }
}

