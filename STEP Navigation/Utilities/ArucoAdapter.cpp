//
//  ArucoAdapter.cpp
//  STEP Navigation
//
//  Created by Paul Ruvolo on 6/5/23.
//

#include "ArucoAdapter.hpp"
#include "opencv2/objdetect.hpp"

cv::Ptr<cv::aruco::Dictionary> getPredefined() {
    return cv::Ptr<cv::aruco::Dictionary>(
            new cv::aruco::Dictionary(cv::aruco::getPredefinedDictionary(cv::aruco::DICT_APRILTAG_36h11)));
}
