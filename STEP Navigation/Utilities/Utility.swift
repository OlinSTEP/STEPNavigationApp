//
//  Utility.swift
//  BreadCrumbsTest
//
//  Created by Chris Seonghwan Yoon on 8/3/17.
//  Copyright © 2017 OccamLab. All rights reserved.
//

import Foundation
import UIKit
import VideoToolbox

func pixelBufferToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage? {
    var cgImage: CGImage?
    VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
    return cgImage.map{UIImage(cgImage: $0)}
}
