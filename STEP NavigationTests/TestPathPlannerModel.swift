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
    
    init(translation: simd_float3, rotation: simd_quatf) {
        self = simd_float4x4(rotation)
        self.columns.3.x = translation.x
        self.columns.3.y = translation.y
        self.columns.3.z = translation.z
    }
    
    init(translation: simd_float3, cameraYaw: Float) {
        // cameraYaw = 0 corresponds to aligning the -z axis of the phone to the x-axis of the world
        self = matrix_identity_float4x4
        self.columns.0 = simd_float4(0, -1, 0, 0)
        self.columns.1 = simd_float4(0, 0, 1, 0)
        self.columns.2 = simd_float4(-1, 0, 0, 0)
        self.columns.3 = simd_float4(translation, 1)
        self = self * simd_float4x4(simd_quatf(angle: cameraYaw, axis: simd_float3(-1, 0, 0)))
    }
}

final class TestPathPlannerModel: XCTestCase {
    func setUpMock(angle: Float, distance: Float) -> (simd_float4x4, simd_float4x4) {
        
        let cameraTransform = simd_float4x4(translation: simd_float3(0, 0, 0), cameraYaw: angle)
        let nextNodeTransform = simd_float4x4(translation: simd_float3(distance, 0, 0), yaw: 0.0)
        
        return (cameraTransform, nextNodeTransform)
    }

    func testCalculateStraightDistance() throws {
        let (cameraTranform, nextNodeTransform) = setUpMock(angle: Float.pi/2, distance: 10)
        let pathPlannerModel = PathPlannerModel()
        let straightDistance = pathPlannerModel.calculateStraightDistance(cameraTransform: cameraTranform, nextNodeTransform: nextNodeTransform)
        XCTAssertEqual(straightDistance, 10)
    }
    
    func testCalculateAngleDifference() throws {
        let (cameraTranform, nextNodeTransform) = setUpMock(angle: Float.pi/2, distance: 10)
        let pathPlannerModel = PathPlannerModel()
        let angleDifference = pathPlannerModel.calculateAngleDifference(cameraTransform: cameraTranform, nextNodeTransform: nextNodeTransform)
        let tolerance: Float = 0.00001
        XCTAssertTrue(abs(angleDifference - -Float.pi/2) < tolerance)
    }

}
