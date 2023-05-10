#!/bin/bash

xcodebuild docbuild -scheme "STEP Navigation" \
    -derivedDataPath docc \
    -destination 'generic/platform=iOS';

$(xcrun --find docc) process-archive transform-for-static-hosting \
  "./docc/Build/Products/Debug-iphoneos/STEP Navigation.doccarchive" --hosting-base-path STEPNavigationApp --output-path docs;
