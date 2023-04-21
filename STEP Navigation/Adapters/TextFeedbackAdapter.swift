//
//  TextFeedbackAdapter.swift
//  InvisibleMapTake2
//
//  Created by Paul Ruvolo on 4/6/23.
//

import Foundation
import ARKit

/// Not sure of description yet
///
/// - notAtTarget
/// - atTarget
/// - closeToTarget
///
/// - TODO: Clarify what this is
public enum PositionState {
    /// user is far from target
    case notAtTarget
    /// user is at target
    case atTarget
    /// user is close to the target
    case closeToTarget
}

/// Struct for storing relative position of keypoint to user
///
/// Contains:
/// * `distance` (`Float`): distance in meters to keypoint
/// * `angleDiff` (`Float`): angle in radians to next keypoint
/// * `clockDirection` (`Int`): description of angle to keypoint in clock position where straight forward is 12
/// * `hapticDirection` (`Int`): description of angle to keypoint to use when haptic feedback is turned on.
/// * `targetState` (case of enum `PositionState`): the state (at, near, or away from target) of the position relative to the keypoint
public struct DirectionInfo {
    /// the distance in meters to keypoint
    public var distance: Float
    /// the ratio of lateral distance to the keypoint when the user passes it if they continue along their current heading versus the maximum allowable
    public var lateralDistanceRatioWhenCrossingTarget: Float
    /// the angle in radians (yaw) to the next keypoint
    public var angleDiff: Float
    /// the description of angle to keypoint in clock position where straight forward is 12
    public var clockDirection: Int
    /// the description of angle to keypoint to use when haptic feedback is turned on.
    public var hapticDirection: Int
    /// the state (at, near, or away from target) of the position relative to the keypoint
    public var targetState = PositionState.notAtTarget
    
    /// Initialize a DirectionInfo object
    ///
    /// - Parameters:
    ///   - distance: the distance to the next keypoint
    ///   - angleDiff: the angle (yaw) to the next keypoint
    ///   - clockDirection: the clock direction to the next keypoint
    ///   - hapticDirection: the state (at, near, or away from target) of the position relative to the keypoint
    public init(distance: Float, angleDiff: Float, clockDirection: Int, hapticDirection: Int, lateralDistanceRatioWhenCrossingTarget: Float) {
        self.distance = distance
        self.angleDiff = angleDiff
        self.clockDirection = clockDirection
        self.hapticDirection = hapticDirection
        self.lateralDistanceRatioWhenCrossingTarget = lateralDistanceRatioWhenCrossingTarget
    }
}

/// Dictionary of clock positions
///
/// * Keys (`Int` from 1 to 12 inclusive): clock position
/// * Values (`String`): corresponding spoken direction (e.g. "Slight right towards 2 o'clock")
public let ClockDirections = [
                              12: NSLocalizedString("straightDirection", comment: "Direction to user to continue moving in forward direction"),
                              1: NSLocalizedString("1o'clockDirection", comment: "direction to the user to turn towards the 1 o'clock direction"),
                              2: NSLocalizedString("2o'clockDirection", comment: "direction to the user to turn towards the 2 o'clock direction"),
                              3: NSLocalizedString("rightDirection", comment: "Direction to the user to make an approximately 90 degree right turn."),
                              4: NSLocalizedString("4o'clockDirection", comment: "direction to the user to turn towards the 4 o'clock direction"),
                              5: NSLocalizedString("5o'clockDirection", comment: "direction to the user to turn towards the 5 o'clock direction"),
                              6: NSLocalizedString("6o'clockDirection", comment: "direction to the user to turn towards the 6 o'clock direction"),
                              7: NSLocalizedString("7o'clockDirection", comment: "direction to the user to turn towards the 7 o'clock direction"),
                              8: NSLocalizedString("8o'clockDirection", comment: "direction to the user to turn towards the 8 o'clock direction"),
                              9: NSLocalizedString("leftDirection", comment: "Direction to the user to make an approximately 90 degree left turn."),
                              10: NSLocalizedString("10o'clockDirection", comment: "direction to the user to turn towards the 10 o'clock direction"),
                              11: NSLocalizedString("11o'clockDirection", comment: "direction to the user to turn towards the 11 o'clock direction")
                             ]

/// Dictionary of directions, somehow based on haptic feedback.
///
/// * Keys (`Int` from 0 to 6 inclusive): encoding of haptic feedback
/// * Values (`String`): corresponding spoken direction (e.g. "Slight right")
///
/// - TODO:
///  - Explain the rationale of this division
///  - Consider restructuring this
public let HapticDirections = [
                               1: NSLocalizedString("straightDirection", comment: "Direction to user to continue moving in forward direction"),
                               2: NSLocalizedString("slightRightDirection", comment: "Direction to user to take a slight right turn"),
                               3: NSLocalizedString("rightDirection", comment: "Direction to the user to make an approximately 90 degree right turn."),
                               4: NSLocalizedString("uTurnDirection", comment: "Direction to the user to turn around"),
                               5: NSLocalizedString("leftDirection", comment: "Direction to the user to make an approximately 90 degree left turn."),
                               6: NSLocalizedString("slightLeftDirection", comment: "Direction to user to take a slight left turn"),
                               0: "ERROR"
                              ]


/// Get the heading for the phone suitable for computing directions to the next waypoint.
///
/// The phone's direction is either the projection of its z-axis on the floor plane (x-z plane), or if the phone is lying flatter than 45 degrees, it is the projection of the phone's y-axis.
/// - Parameter currentLocation: the phone's location
/// - Returns: the phone's yaw that is used for computation of directions
public func getPhoneHeadingYaw(currentLocation: simd_float4x4)->Float {
    let zVector = currentLocation.columns.2.inhomogeneous
    let xVector = currentLocation.columns.0.inhomogeneous
    //  The vector with the lesser vertical component is more flat, so has
    //  a more accurate direction. If the phone is more flat than 45 degrees
    //  the upward vector is used for phone direction; if it is more upright
    //  the outward vector is used.
    let trueVector: simd_float3
    if abs(zVector.y) < abs(xVector.y) {
        trueVector = simd_float3(zVector.x, 0, zVector.z)
    } else {
        trueVector = simd_float3(xVector.x, 0, xVector.z)
    }
    return atan2f(trueVector.x, trueVector.z)
}

/// Navigation class that provides direction information given 2 LocationInfo position
class Navigation {
    
    /// DirectionText based on hapic/voice settings
    var Directions: Dictionary<Int, String> {
        return ClockDirections
    }
    
    /// Keypoint target dimension (width) in meters
    ///
    /// Further instructions will be given to the user once they pass inside this bounding box
    public var targetWidth: Float = 2.0
    
    /// Keypoint target dimension (depth) in meters
    ///
    /// Further instructions will be given to the user once they pass inside this bounding box
    public var targetDepth: Float = 0.5
    
    /// Keypoint target dimension (height) in meters
    ///
    /// Further instructions will be given to the user once they pass inside this bounding box
    public var targetHeight: Float = 3.0
    
    /// Keypoint target dimension (width) in meters
    ///
    /// Further instructions will be given to the user once they pass inside this bounding box
    public var lastKeypointTargetWidth: Float = 1.0
    
    /// Keypoint target dimension (depth) in meters
    ///
    /// Further instructions will be given to the user once they pass inside this bounding box
    public var lastKeypointTargetDepth: Float = 1.0
    
    /// Keypoint target dimension (height) in meters
    ///
    /// Further instructions will be given to the user once they pass inside this bounding box
    public var lastKeypointTargetHeight: Float = 3.0
    
    /// The offset between the user's direction of travel (assumed to be aligned with the front of their body and the phone's orientation)
    var headingOffset: Float?
    
    /// control whether to apply the heading offset or not
    public var useHeadingOffset = false
    
    /// Determines position of the next keypoint relative to the iPhone's current position.
    ///
    /// - Parameters:
    ///   - currentLocation
    ///   - nextKeypoint
    ///   - isLastKeypoint (true if the keypoint is the last one in the route, false otherwise)
    /// - Returns: relative position of next keypoint as `DirectionInfo` object
    public func getDirections(currentLocation: simd_float4x4, nextKeypoint: KeypointInfo, isLastKeypoint: Bool) -> DirectionInfo? {
        guard PositioningModel.shared.hasAligned() else {
            return nil
        }
        let nextLocation = PositioningModel.shared.currentLocation(of: nextKeypoint.location)
        // these tolerances are set depending on whether it is the last keypoint or not
        let keypointTargetDepth = isLastKeypoint ? lastKeypointTargetDepth : targetDepth
        let keypointTargetHeight = isLastKeypoint ? lastKeypointTargetHeight : targetHeight
        let keypointTargetWidth = isLastKeypoint ? lastKeypointTargetWidth : targetWidth

        let trueYaw  = getPhoneHeadingYaw(currentLocation: currentLocation) + (useHeadingOffset && headingOffset != nil ? headingOffset! : Float(0.0))
        // planar heading vector
        let planarHeading = simd_float3(sin(trueYaw), 0, cos(trueYaw))
        let delta = currentLocation.translation - nextLocation.translation
        let planarDelta = simd_float3(delta.x, 0, delta.z)
        // TODO: this isn't using the update position properly
        let headingProjectedOntoKeypointXDirection = simd_dot(nextKeypoint.orientation, planarHeading)
        
        // Finds angle from "forward"-looking towards the next keypoint in radians. Not sure which direction is negative vs. positive for now.
        let angle = atan2f(currentLocation.translation.x - nextLocation.translation.x,
                           currentLocation.translation.z - nextLocation.translation.z)
        
        let angleDiff = getAngleDiff(angle1: trueYaw, angle2: angle)
        
        let hapticDirection = getHapticDirection(angle: angleDiff)
        let clockDirection = getClockDirection(angle: angleDiff)
        
        //  Determine the difference in position between the phone and the next
        //  keypoint in the frame of the keypoint.
        let xDiff = simd_dot(delta, nextKeypoint.orientation)
        let yDiff = simd_dot(delta, simd_float3(0, 1, 0))
        let zDiff = simd_dot(delta, simd_cross(nextKeypoint.orientation, simd_float3(0, 1, 0)))
        
        let lateralDistanceRatioWhenCrossingTarget : Float
        if headingProjectedOntoKeypointXDirection <= 0 {
            lateralDistanceRatioWhenCrossingTarget = Float.infinity
        } else {
            lateralDistanceRatioWhenCrossingTarget = simd_length(-planarHeading*simd_dot(delta, nextKeypoint.orientation)/headingProjectedOntoKeypointXDirection + currentLocation.translation - nextLocation.translation) / keypointTargetWidth
        }
        
        var direction = DirectionInfo(distance: simd_length(planarDelta), angleDiff: angleDiff, clockDirection: clockDirection, hapticDirection: hapticDirection, lateralDistanceRatioWhenCrossingTarget: lateralDistanceRatioWhenCrossingTarget)
        
        //  Determine whether the phone is inside the bounding box of the keypoint
        if (xDiff <= keypointTargetDepth && yDiff <= keypointTargetHeight && zDiff <= keypointTargetWidth) {
            direction.targetState = .atTarget
        } else if (sqrtf(powf(Float(xDiff), 2) + powf(Float(zDiff), 2)) <= 4) {
            direction.targetState = .closeToTarget
        } else {
            direction.targetState = .notAtTarget
        }
        
        return direction
    }
    
    /// Divides all possible directional angles into six sections for using with haptic feedback.
    ///
    /// - Parameter angle: angle in radians from straight ahead.
    /// - Returns: `Int` from 0 to 6 inclusive, starting with 1 facing straight forward and continuing clockwise. 0 represents no angle.
    ///
    /// - SeeAlso: `HapticDirections`
    ///
    /// - TODO:
    ///    - potentially rethink this assignment to ints and dictionary.
    ///    - consider making return optional or throw an error rather than returning 0.
    private func getHapticDirection(angle: Float) -> Int {
        if (-Float.pi/6 <= angle && angle <= Float.pi/6) {
            return 1
        } else if (Float.pi/6 <= angle && angle <= Float.pi/3) {
            return 2
        } else if (Float.pi/3 <= angle && angle <= (2*Float.pi/3)) {
            return 3
        } else if ((2*Float.pi/3) <= angle && angle <= Float.pi) {
            return 4
        } else if (-Float.pi <= angle && angle <= -(2*Float.pi/3)) {
            return 4
        } else if (-(2*Float.pi/3) <= angle && angle <= -(Float.pi/3)) {
            return 5
        } else if (-Float.pi/3 <= angle && angle <= -Float.pi/6) {
            return 6
        } else {
            return 0
        }
    }
    
    /// Determine clock direction from angle in radians, where 0 radians is 12 o'clock.
    ///
    /// - Parameter angle: input angle to be converted, in radians
    /// - Returns: `Int` between 1 and 12, inclusive, representing clock position
    ///
    /// - SeeAlso: `ClockDirections`
    private func getClockDirection(angle: Float) -> Int {
        //  Determine clock direction, from 1-12, based on angle in radians,
        //  where 0 radians is 12 o'clock.
        let a = (angle * (6/Float.pi)) + 12.5
        
        let clockDir = Int(a) % 12
        return clockDir == 0 ? 12 : clockDir
    }
    
    /// Determines the difference between two angles, in radians
    ///
    /// - Parameters:
    ///   - angle1: the first angle
    ///   - angle2: the second angle
    /// - Returns: the difference between the two angles
    func getAngleDiff(angle1: Float, angle2: Float) -> Float {
        //  Function to determine the difference between two angles
        let a = angleNormalize(angle: angle1)
        let b = angleNormalize(angle: angle2)
        
        let d1 = a-b
        var d2 = 2*Float.pi - abs(d1)
        if (d1 > 0) {
            d2 = d2 * (-1)
        }
        return abs(d1) < abs(d2) ? d1 : d2
    }
    
    /// Normalizes an angle in radians to be between -pi and pi
    ///
    /// - Parameter angle: an angle in radians
    /// - Returns: the angle mapped to between -pi and pi
    private func angleNormalize(angle: Float) -> Float {
        return atan2f(sinf(angle), cosf(angle))
    }
    
    /// Computes the average between two angles (accounting for wraparound)
    ///
    /// - Parameters:
    ///   - a: one of the two angles
    ///   - b: the other angle
    /// - Returns: the average fo the angles
    func averageAngle(a: Float, b: Float)->Float {
        return atan2f(sin(b) + sin(a), cos(a) + cos(b))
    }
    
    /// Get direction to next keypoint based on the current location
    ///
    /// - Parameter currentLocation: the current location of the device
    /// - Returns: the direction to the next keypoint with the distance rounded to the nearest tenth of a meter
    func getDirectionToNextKeypoint(currentLocation: simd_float4x4) -> DirectionInfo? {
        // returns direction to next keypoint from current location
        guard let nextKeypoint = RouteNavigator.shared.nextKeypoint, var dir = getDirections(currentLocation: currentLocation, nextKeypoint: nextKeypoint, isLastKeypoint: RouteNavigator.shared.onLastKeypoint) else {
            return nil
        }
        dir.distance = roundToTenths(dir.distance)
        return dir
    }
    
    /// Set the direction text based on the current location and direction info.
    ///
    /// - Parameters:
    ///   - currentLocation: the current location of the device
    ///   - direction: the direction info struct (e.g., as computed by the `Navigation` class)
    ///   - displayDistance: a Boolean that indicates whether the distance to the net keypoint should be displayed (true if it should be displayed, false otherwise)
    func setDirectionText(currentLocation: simd_float4x4, direction: DirectionInfo, displayDistance: Bool)->String? {
        guard let nextKeypoint = RouteNavigator.shared.nextKeypoint else {
            return nil
        }
        // Set direction text for text label and VoiceOver
        let xzNorm = sqrtf(powf(currentLocation.columns.3.x - nextKeypoint.location.translation.x, 2) + powf(currentLocation.columns.3.z - nextKeypoint.location.translation.z, 2))
        let slope = (nextKeypoint.location.translation.y - NavigationManager.shared.prevKeypointPosition.translation.y) / xzNorm
        let yDistance = abs(nextKeypoint.location.translation.y - NavigationManager.shared.prevKeypointPosition.translation.y)
        var dir = ""
        
        if yDistance > 1 && slope > 0.3 { // Go upstairs
            dir += "\(Directions[direction.clockDirection]!)" + NSLocalizedString(" and proceed upstairs", comment: "Additional directions given to user telling them to climb stairs")
            return updateDirectionText(dir, distance: 0, displayDistance: false)
        } else if yDistance > 1 && slope < -0.3 { // Go downstairs
            dir += "\(Directions[direction.clockDirection]!)\(NSLocalizedString("descendStairsDirection" , comment: "This is a direction which instructs the user to descend stairs"))"
            return updateDirectionText(dir, distance: direction.distance, displayDistance: false)
        } else { // normal directions
            dir += "\(Directions[direction.clockDirection]!)"
            return updateDirectionText(dir, distance: direction.distance, displayDistance:  displayDistance)
        }
    }
    
    /// Announce the direction (both in text and using speech if appropriate).  The function will automatically use the appropriate units based on settings to convert `distance` from meters to the appropriate unit.
    ///
    /// - Parameters:
    ///   - description: the direction text to display (e.g., may include the direction to turn)
    ///   - distance: the distance (expressed in meters)
    ///   - displayDistance: a Boolean that indicates whether to display the distance (true means display distance)
    func updateDirectionText(_ description: String, distance: Float, displayDistance: Bool)->String {
        let distanceToDisplay = roundToTenths(distance * Float(100.0/2.54/12.0))
        var altText = description
        if (displayDistance) {
                // don't use fractional feet or for higher numbers of meters (round instead)
                // Related to higher number of meters, there is a somewhat strange behavior in VoiceOver where numbers greater than 10 will be read as, for instance, 11 dot 4 meters (instead of 11 point 4 meters).
            altText += " " + NSLocalizedString("and walk", comment: "this text is presented when getting directions.  It is placed between a direction of how to turn and a distance to travel") + " \(Int(distanceToDisplay)) feet"
        }
        return altText
    }
        
}

/// - Returns: the number rounded to the nearest tenth
func roundToTenths(_ n: Float) -> Float {
    return roundf(10 * n)/10
}

