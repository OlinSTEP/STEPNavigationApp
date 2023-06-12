//
//  ContentView.swift
//  InvisibleMapTake2
//
//  Created by Paul Ruvolo on 3/30/23.
//

import SwiftUI
import Charts
import ARCoreGeospatial
import ARCoreCloudAnchors
import Firebase
import FirebaseDatabase
import FirebaseStorage


enum MainScreenType {
    case mainScreen
    case createAnchor
    case connectAnchor
    case findFirstAnchorToFormConnection(anchorID1: String, anchorID2: String)
    case walkToSecondAnchor(anchorID1: String, anchorID2: String)
    case findSecondAnchorToFormConnection(anchorID1: String, anchorID2: String)
    case deleteCloudAnchor
    case resolvingCloudAnchors
    case editAnchor
    case editingAnchor(anchorID: String)
    var isOnMainScreen: Bool {
        if case .mainScreen = self {
            return true
        }
        return false
    }
}

class MainUIStateContainer: ObservableObject {
    @Published var currentScreen: MainScreenType = .mainScreen
    public static var shared = MainUIStateContainer()
    private init() {
        
    }
}

struct ContentView : View {
    @StateObject var firebaseManager = FirebaseManager.shared
    @ObservedObject var uiState = MainUIStateContainer.shared
    @ObservedObject var navigationManager = NavigationManager.shared
    @ObservedObject var authHandler = AuthHandler.shared
    
    var body: some View {
        if authHandler.currentUID == nil {
            SignInWithApple()
                .frame(width: 280, height: 60)
                .onTapGesture(perform: authHandler.startSignInWithAppleFlow)
        } else {
            ZStack {
                ARViewContainer().edgesIgnoringSafeArea(.all)
                if !uiState.currentScreen.isOnMainScreen {
                    VStack {
                        Button("Back to main screen") {
                            uiState.currentScreen = .mainScreen
                        }
                        Spacer()
                    }
                }
                switch uiState.currentScreen {
                case .mainScreen:
                    MainScreen()
                case .createAnchor:
                    CreateAnchorView()
                case .connectAnchor:
                    ConnectAnchorView()
                case .editAnchor:
                    EditAnchorView()
                case .editingAnchor(let anchorID):
                    EditingAnchorView(anchorID: anchorID)
                case .findFirstAnchorToFormConnection(let anchorID1, let anchorID2):
                    FindFirstAnchor(anchorID1: anchorID1, anchorID2: anchorID2)
                case .walkToSecondAnchor(let anchorID1, let anchorID2):
                    WalkToSecondAnchor(anchorID1: anchorID1, anchorID2: anchorID2)
                case .findSecondAnchorToFormConnection(let anchorID1, let anchorID2):
                    FindSecondAnchor(anchorID1: anchorID1, anchorID2: anchorID2)
                case .deleteCloudAnchor:
                    DeleteCloudAnchor()
                case .resolvingCloudAnchors:
                    ResolvingCloudAnchorsView()
                }
            }
        }
    }
}

struct EditingAnchorView: View {
    let anchorID: String
    @State var newAnchorName: String
    @State var newCategory: String
    @State var newAssociatedOutdoorFeature: String
    @State var newIsReadable: Bool
    let metadata: CloudAnchorMetadata
    
    init(anchorID: String) {
        self.anchorID = anchorID
        metadata = FirebaseManager.shared.getCloudAnchorMetadata(byID: anchorID)!
        newAnchorName = metadata.name
        newAssociatedOutdoorFeature = metadata.associatedOutdoorFeature
        newCategory = metadata.type.rawValue
        newIsReadable = metadata.isReadable
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Name")
                Spacer()
                TextField("Name", text: $newAnchorName)
            }
            Toggle("Is Readable", isOn: $newIsReadable)
            HStack {
                Text("Category")
                Spacer()
                Picker("Anchor", selection: $newCategory) {
                    ForEach(AnchorType.allCases.map({$0.rawValue}).sorted(), id: \.self) { category in
                        Text(category)
                    }
                }
            }
            HStack {
                Text("Associated Outdoor Feature")
                Spacer()
                Picker("Associated Outdoor", selection: $newAssociatedOutdoorFeature) {
                    Text("").tag("")
                    ForEach(DataModelManager.shared.getLocationsByType(anchorType: .externalDoor).sorted(by: { $0.getName() < $1.getName() })) { outdoorFeature in
                        Text(outdoorFeature.getName()).tag(outdoorFeature.id)
                    }
                }
            }
            Spacer()
            HStack {
                Button("Cancel") {
                    MainUIStateContainer.shared.currentScreen = .createAnchor
                }
                Button("Save") {
                    let newMetadata =
                    CloudAnchorMetadata(name: newAnchorName,
                                        type: AnchorType(rawValue: newCategory) ?? .indoorDestination,
                                        associatedOutdoorFeature: newAssociatedOutdoorFeature,
                                        geospatialTransform: metadata.geospatialTransform, creatorUID: metadata.creatorUID,
                                        isReadable: newIsReadable)
                    FirebaseManager.shared.updateCloudAnchor(identifier: anchorID, metadata: newMetadata)
                    MainUIStateContainer.shared.currentScreen = .createAnchor
                }
            }
        }
        .background(Color.orange)
        .padding()
    }
}

struct EditAnchorView: View {
    @State var anchorID = FirebaseManager.shared.firstCloudAnchor ?? ""
    
    var body: some View {
        VStack {
            Picker("Anchor", selection: $anchorID) {
                ForEach(FirebaseManager.shared.mapAnchors.sorted(by: { $0.0 > $1.0 }), id: \.key) { cloudAnchorID, mapAnchorMetadata in
                    Text(mapAnchorMetadata.name)
                }
            }
            Button("Edit") {
                guard !anchorID.isEmpty else {
                    AnnouncementManager.shared.announce(announcement: "Please select a valid anchor")
                    return
                }
                
                MainUIStateContainer.shared.currentScreen = .editingAnchor(anchorID: anchorID)
            }
            .pickerStyle(WheelPickerStyle())
        }
    }
}

struct CreateAnchorView: View {
    @State private var anchorName: String = ""
    @State private var currentQuality: GARFeatureMapQuality?
    
    var body: some View {
        VStack {
            if let currentQuality = currentQuality {
                switch currentQuality {
                case .insufficient:
                    Text("Anchor quality insufficient")
                case .sufficient:
                    Text("Anchor quality sufficient")
                case .good:
                    Text("Anchor quality good")
                @unknown default:
                    Text("Anchor quality is unknown")
                }
            }
            TextField("Anchor Name", text: $anchorName)
            Button("Save Anchor") {
                PositioningModel.shared.createCloudAnchor(afterDelay: 30.0, withName: anchorName) { wasSuccessful in
                    MainUIStateContainer.shared.currentScreen = .mainScreen
                }
            }
        }
        .onReceive(PositioningModel.shared.$currentQuality) { newValue in
            currentQuality = newValue
        }
        .onAppear() {
            PositioningModel.shared.startPositioning()
        }
    }
}

struct MainScreen: View {
    var body: some View {
        VStack {
            Button("Add a Cloud Anchor") {
                MainUIStateContainer.shared.currentScreen = .createAnchor
            }
            Button("Edit a Cloud Anchor") {
                MainUIStateContainer.shared.currentScreen = .editAnchor
            }
            Button("Connect Two Anchors") {
                MainUIStateContainer.shared.currentScreen = .connectAnchor
            }
            Button("Delete an Anchor") {
                MainUIStateContainer.shared.currentScreen = .deleteCloudAnchor
            }
            Button("Resolve many Anchors") {
                MainUIStateContainer.shared.currentScreen = .resolvingCloudAnchors
            }
        }
        .background(Color.orange)
        .padding()
        .onAppear() {
            PositioningModel.shared.stopPositioning()
        }
    }
}

struct ResolvingCloudAnchorsView: View {
    @ObservedObject var positionModel = STEP_Mapping.PositioningModel.shared
    @State var loc:CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var body: some View {
        HStack{
            VStack {
                Text("Go to the next anchor.")
                
                Text("Cloud Anchor resolved")
                
                Button("save"){
                    PathRecorder.shared.manyAnchorstoFirebase()
                }
                .onAppear() {
                    PositioningModel.shared.startPositioning()
                    PathRecorder.shared.startRecordingPathonly()
                }
            }
        }
        .onReceive(positionModel.$currentLatLon) { latLon in
            guard let latLon = latLon else {
                return
            }
            loc = latLon
            let anchors = Array(
                DataModelManager.shared.getNearbyLocations(
                    for: .indoorDestination,
                    location: loc,
                    maxDistance: CLLocationDistance(50)
                )
            )
            for anchor in anchors {
                PositioningModel.shared.resolveCloudAnchor(byID : anchor.id)
            }
            
        }
    }
}


struct FindFirstAnchor: View {
    @ObservedObject var positioningModel = PositioningModel.shared
    let anchorID1: String
    let anchorID2: String

    var body: some View {
        VStack {
            if positioningModel.resolvedCloudAnchors.contains(anchorID1) {
                Text("Resolved first anchor")
                Button("Next Step") {
                    MainUIStateContainer.shared.currentScreen = .walkToSecondAnchor(anchorID1: anchorID1, anchorID2: anchorID2)
                }
            } else {
                Text("Find Anchor by scanning your phone around \(FirebaseManager.shared.getCloudAnchorName(byID: anchorID1)!)")
            }
        }
        .background(Color.orange)
        .padding()
    }
}

struct FindSecondAnchor: View {
    @ObservedObject var positioningModel = PositioningModel.shared
    let anchorID1: String
    let anchorID2: String
    @State var showingPopover = false
    
    var body: some View {
        VStack {
            Button("Show Recorded Path") {
                showingPopover.toggle()
            }
            if positioningModel.resolvedCloudAnchors.contains(anchorID2) {
                Text("Resolved second anchor")
                Button("Done") {
                    PathRecorder.shared.toFirebase()
                    MainUIStateContainer.shared.currentScreen = .createAnchor
                }
            } else {
                Text("Find Anchor by scanning your phone around \(FirebaseManager.shared.getCloudAnchorName(byID: anchorID2)!)")
            }
        }
        .popover(isPresented: $showingPopover) {
            let keypoints = PathRecorder.shared.breadCrumbs.map({ KeypointInfo(id: UUID(), mode: .cloudAnchorBased, location: $0.pose)})
            let currentPose = PositioningModel.shared.cameraTransform
            PathPlot(points: keypoints, currentTransform: currentPose)
        }
        .background(Color.orange)
        .padding()
    }
}

struct PathPlot: View {
    let points: [KeypointInfo]
    let currentTransform: simd_float4x4?
    var body: some View {
        if let plotBounds = Self.getPlotBounds(keypoints: points) {
            Chart {
                if let currentTransform = currentTransform {
                    PointMark(x: .value("z", currentTransform.columns.3.z),
                              y: .value("x", currentTransform.columns.3.x))
                    .symbol(Arrow(angle: CGFloat(Float.pi/2 - getPhoneHeadingYaw(currentLocation: currentTransform)), size: 100))
                }
                ForEach(points) { point in
                    LineMark(
                        x: .value("z", point.location.translation.z),
                        y: .value("x", point.location.translation.x)
                    )
                    PointMark(
                        x: .value("z", point.location.translation.z),
                        y: .value("x", point.location.translation.x)
                    ).foregroundStyle(RouteNavigator.shared.isCheckedOff(point) ? .black : .blue)
                }
            }
            .chartXScale(domain: ClosedRange(uncheckedBounds: (plotBounds.0, plotBounds.1)))
            .chartYScale(domain: ClosedRange(uncheckedBounds: (plotBounds.2, plotBounds.3)))
        } else {
            Text("Localize first before seeing route preview")
        }
    }
    
    static func getPlotBounds(keypoints: [KeypointInfo])->(Float, Float, Float, Float)? {
        guard let xMin = keypoints.map({$0.currentTransform!.translation.z}).min(),
              let xMax = keypoints.map({$0.currentTransform!.translation.z}).max(),
              let yMin = keypoints.map({$0.currentTransform!.translation.x}).min(),
              let yMax = keypoints.map({$0.currentTransform!.translation.x}).max() else {
            return nil
        }
        var yPaddingOnEachSide = Float(2.0)
        var xPaddingOnEachSide = Float(2.0)

        if xMax - xMin > yMax - yMin {
            yPaddingOnEachSide += ((xMax - xMin) - (yMax - yMin))/2.0
        } else {
            xPaddingOnEachSide += ((yMax - yMin) - (xMax - xMin))/2.0
        }
        return (xMin - xPaddingOnEachSide, xMax + xPaddingOnEachSide, yMin - yPaddingOnEachSide, yMax + yPaddingOnEachSide)
    }
}

struct RoutePreview: View {
    @ObservedObject var positioningModel = PositioningModel.shared
    @ObservedObject var routeManager = RouteNavigator.shared
    
    var body: some View {
        if let keypoints = routeManager.originalKeypoints,
           let currentTransform = positioningModel.cameraTransform {
            PathPlot(points: keypoints, currentTransform: currentTransform)
        } else {
            Text("Localize first before seeing route preview")
        }
    }
}


struct Arrow: ChartSymbolShape {
    let angle: CGFloat
    let size: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let w = rect.width * size * 0.05 + 0.6
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 1))
        path.addLine(to: CGPoint(x: -0.2, y: -0.5))
        path.addLine(to: CGPoint(x: 0.2, y: -0.5))
        path.closeSubpath()
        return path.applying(.init(rotationAngle: angle))
            .applying(.init(scaleX: w, y: w))
            .applying(.init(translationX: rect.midX, y: rect.midY))
    }
    
    var perceptualUnitRect: CGRect {
        return CGRect(x: 0, y: 0, width: 1, height: 1)
    }
}


struct DeleteCloudAnchor: View {
    @State var anchorID = FirebaseManager.shared.firstCloudAnchor ?? ""
    @ObservedObject var firebaseManager = FirebaseManager.shared
    
    var body: some View {
        VStack {
            Picker("Anchor to delete", selection: $anchorID) {
                ForEach(FirebaseManager.shared.mapAnchors.sorted(by: { $0.0 > $1.0 }), id: \.key) { cloudAnchorID, mapAnchorMetadata in
                    Text(mapAnchorMetadata.name)
                        .tag(cloudAnchorID)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            Button("Delete") {
                FirebaseManager.shared.deleteCloudAnchor(id: anchorID)
                MainUIStateContainer.shared.currentScreen = .createAnchor
            }
        }
        .background(Color.orange)
        .padding()
    }
}

struct ConnectAnchorView: View {
    @State var anchorID1 = FirebaseManager.shared.firstCloudAnchor ?? ""
    @State var anchorID2 = FirebaseManager.shared.firstCloudAnchor ?? ""
    @ObservedObject var firebaseManager = FirebaseManager.shared
    @State var currentQuality: GARFeatureMapQuality?
    
    var body: some View {
        VStack {
            if let currentQuality = currentQuality {
                switch currentQuality {
                case .insufficient:
                    Text("Anchor quality insufficient")
                case .sufficient:
                    Text("Anchor quality sufficient")
                case .good:
                    Text("Anchor quality good")
                @unknown default:
                    Text("Anchor quality is unknown")
                }
            }
            Picker("Anchor 1", selection: $anchorID1) {
                ForEach(FirebaseManager.shared.mapAnchors.sorted(by: { $0.0 > $1.0 }), id: \.key) { cloudAnchorID, mapAnchorMetadata in
                    Text(mapAnchorMetadata.name)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            Picker("Anchor 2", selection: $anchorID2) {
                ForEach(FirebaseManager.shared.mapAnchors.sorted(by: { $0.0 > $1.0 }), id: \.key) { cloudAnchorID, mapAnchorMetadata in
                    Text(mapAnchorMetadata.name)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            Button("Connect Cloud Anchors") {
                guard anchorID1 != anchorID2 else {
                    AnnouncementManager.shared.announce(announcement: "Navigating two and from the same point of interest is not currently supported")
                    return
                }
                PositioningModel.shared.resolveCloudAnchor(byID: anchorID1)
                PositioningModel.shared.resolveCloudAnchor(byID: anchorID2)
                PathRecorder.shared.startAnchorID = anchorID1
                PathRecorder.shared.stopAnchorID = anchorID2
                MainUIStateContainer.shared.currentScreen = .findFirstAnchorToFormConnection(anchorID1: anchorID1, anchorID2: anchorID2)
            }
            
        }
        .background(Color.orange)
        .padding()
        .onReceive(PositioningModel.shared.$currentQuality) { newQuality in
            currentQuality = newQuality
        }
        .onAppear() {
            PositioningModel.shared.startPositioning()
        }
    }
}

struct WalkToSecondAnchor: View {
    let anchorID1: String
    let anchorID2: String
    @ObservedObject var positioningModel = PositioningModel.shared
    
    var body: some View {
        HStack{
            VStack {
                if let currentQuality = PositioningModel.shared.currentQuality {
                    switch currentQuality {
                    case .insufficient:
                        Text("Anchor quality insufficient")
                    case .sufficient:
                        Text("Anchor quality sufficient")
                    case .good:
                        Text("Anchor quality good")
                    @unknown default:
                        Text("Anchor quality is unknown")
                    }
                }
                Text("Walk to the second anchor")
                Button("Next step") {
                    PathRecorder.shared.stopRecordingPath()
                    MainUIStateContainer.shared.currentScreen = .findSecondAnchorToFormConnection(anchorID1: anchorID1, anchorID2: anchorID2)
                }
            }
        }.onAppear() {
            PathRecorder.shared.startRecording()
        }
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

