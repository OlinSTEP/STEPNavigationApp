//
//  ArucoAdapter.hpp
//  STEP Navigation
//
//  Created by Paul Ruvolo on 6/5/23.
//

#ifndef ArucoAdapter_hpp
#define ArucoAdapter_hpp
#include "opencv2/objdetect.hpp"

#include <stdio.h>

cv::Ptr<cv::aruco::Dictionary> getPredefined();

#endif /* ArucoAdapter_hpp */
