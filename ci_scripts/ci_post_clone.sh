#!/bin/bash
echo "import Foundation" > ../STEP\ Navigation/ARCoreCredentials.swift
echo "let garAPIKey=\"$garAPIKey\"" >> ../STEP\ Navigation/ARCoreCredentials.swift
sed -e "s/GOOGLE_SERVICE_KEY/$GOOGLE_SERVICE_KEY/g" < GoogleService-info_skel.plist > ../STEP\ Navigation/GoogleService-Info.plist
sed -e "s/GOOGLE_SERVICE_KEY/$GOOGLE_SERVICE_MAPPING_KEY/g" < GoogleService_mapping-info_skel.plist > ../STEP\ Mapping/GoogleService-Info.plist
