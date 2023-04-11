//
//  TestPathPlannerModel.swift
//  STEP NavigationTests
//
//  Created by Sam Coleman on 4/10/23.
//

@testable import STEP_Navigation
import XCTest
import ARKit
import ARCoreCloudAnchors
import ARCoreGeospatial

// Some simd_float4x4 extensions for making transforms more easily
extension simd_float4x4 {
    init(translation: simd_float3, yaw: Float) {
        self.init(simd_quatf(angle: yaw, axis: simd_float3(0, 1, 0)))
        self.columns.3 = simd_float4(translation, 1.0)
    }
}

final class TestPathPlannerModel: XCTestCase {
    func setUpMock(angle: Float, distance: Float) -> (simd_float4x4, simd_float4x4) {
        // we would expect back -pi/2 and then 10 meters
//        let cameraTransform = simd_float4x4(translation: simd_float3(0, 0, 0), yaw: Float.pi/2)
//        let nextNodeTransform = simd_float4x4(translation: simd_float3(10.0, 0, 0), yaw: 0.0)
        
        let cameraTransform = simd_float4x4(translation: simd_float3(0, 0, 0), yaw: angle)
        let nextNodeTransform = simd_float4x4(translation: simd_float3(distance, 0, 0), yaw: 0.0)
        
        return (cameraTransform, nextNodeTransform)
    }


//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }


    func testCalculateStraightDistance() throws {
        let (cameraTranform, nextNodeTransform) = setUpMock(angle: Float.pi/2, distance: 10)
        
        let pathPlannerModel = PathPlannerModel()
        let straightDistance = pathPlannerModel.calculateStraightDistance(cameraTransform: cameraTranform, nextNodeTransform: nextNodeTransform)
        print("distance: \(straightDistance)")
    }
    
    func testCalculateAngleDifference() throws {
        let pathPlannerModel = PathPlannerModel()
        let angleDifference = pathPlannerModel.calculateAngleDifference(cameraTransform: cameraTranform, nextNodeTransform: nextNodeTransform)
        print("angle difference: \(angleDifference)")
    }

}
