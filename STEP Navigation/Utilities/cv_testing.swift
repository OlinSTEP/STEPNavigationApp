//
//  cv_testing.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 6/5/23.
//

import Foundation
import opencv2

class AprilTagDetector {
    let detector: ArucoDetector
    init() {
        let dict = ArucoAdapterWrapper().getPredefined()
        let data = Data(apriltag36h11_bytes)
        let aprilTagData = Mat(rows: 587, cols: (6 * 6 + 7) / 8, type: CvType.CV_8UC4, data: data)
        let dictionary = Dictionary(bytesList: aprilTagData, _markerSize: 6)
        let parameters = DetectorParameters()
        let refineParams = RefineParameters()
        detector = ArucoDetector(dictionary: parameters, refineParams: refineParams)
        detector.setDictionary(dictionary: dictionary)
        detector.setDictionary(dictionary: dict!)
    }
    func detectMarkers(inImage image: UIImage) {
        // Show source image
        let src = Mat(uiImage: image)
        let corners = NSMutableArray()
        var ids = Mat()
        detector.detectMarkers(image: src, corners: corners, ids: ids)
    }
}
