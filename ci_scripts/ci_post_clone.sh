#!/bin/bash
echo "import Foundation" > ../STEP\ Navigation/ARCoreCredentials.swift
echo "let garAPIKey=\"$garAPIKey\"" >> ../STEP\ Navigation/ARCoreCredentials.swift
sed -e "s/GOOGLE_SERVICE_KEY/$GOOGLE_SERVICE_KEY/g" < GoogleService-Info_skel.plist > ../STEP\ Navigation/GoogleService-Info.plist
