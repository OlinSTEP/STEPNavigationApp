//
//  cv_testing.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 6/5/23.
//

import Foundation
import opencv2
import VideoToolbox

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let cgImage = cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}

/// A class that uses OpenCV's support for Aruco detection to detect April tags
class AprilTagDetector {
    /// The underlying OpenCV detector
    let detector: ArucoDetector
    
    /// The init method creates the detector with the April tag corner refinement method and the 36h11 tag family
    init() {
        let parameters = DetectorParameters()
        parameters.cornerRefinementMethod = .CORNER_REFINE_APRILTAG
        let refineParams = RefineParameters()
        detector = ArucoDetector(dictionary: parameters, refineParams: refineParams)
        // April tag 36h11
        detector.setDictionary(dictionary: Objdetect.getPredefinedDictionary(dict: 20))
    }
    
    /// Detect the markers in the specified image
    /// - Parameter image: the image taken from, e.g., an `ARFrame`
    func detectMarkers(inImage image: CVPixelBuffer) {
        // Show source image
        if let image = UIImage(pixelBuffer: image) {
            let src = Mat(uiImage: image)
            let gray = Mat()
            Imgproc.cvtColor(src: src, dst: gray, code: .COLOR_BGRA2GRAY)
            let corners = NSMutableArray()
            let ids = Mat()
            detector.detectMarkers(image: gray, corners: corners, ids: ids)
            print("ids \(ids.cols()) \(ids.rows())")
        }
    }
}
