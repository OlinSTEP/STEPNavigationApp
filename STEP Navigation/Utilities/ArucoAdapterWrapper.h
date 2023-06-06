//
//  ArucoAdapterWrapper.h
//  STEP Navigation
//
//  Created by Paul Ruvolo on 6/5/23.
//

#ifndef ArucoAdapterWrapper_h
#define ArucoAdapterWrapper_h

#ifdef __cplusplus
#import "opencv2/objdetect.hpp"
#import "opencv2/objdetect/aruco_detector.hpp"
#else
#define CV_EXPORTS
#endif

@class Dictionary;

#import <Foundation/Foundation.h>

CV_EXPORTS @interface ArucoAdapterWrapper : NSObject
- (Dictionary*) getDictionaryWrapped NS_SWIFT_NAME(getPredefined());
@end

#endif /* ArucoAdapterWrapper_h */
