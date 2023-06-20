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
import ARKit
import SceneKit


enum MainScreenType {
    case mainScreen
    case createAnchor
    case deleteCloudAnchor
    case resolvingCloudAnchors
    case visualizingARMap
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
                case .editAnchor:
                    EditAnchorView()
                case .editingAnchor(let anchorID):
                    EditingAnchorView(anchorID: anchorID)
                case .deleteCloudAnchor:
                    DeleteCloudAnchor()
                case .resolvingCloudAnchors:
                    ResolvingCloudAnchorsView()
                case .visualizingARMap:
                    VisualizingARMapView()
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
            Button("Delete an Anchor") {
                MainUIStateContainer.shared.currentScreen = .deleteCloudAnchor
            }
            Button("Map Anchor Connections") {
                MainUIStateContainer.shared.currentScreen = .resolvingCloudAnchors
            }
            Button("AR-Visualizer") {
                MainUIStateContainer.shared.currentScreen = .visualizingARMap
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
    @State var newResolved : String = ""
    
    var body: some View {
        HStack{
            VStack {
                Text("Go to the next anchor.")
                Text("Resolved " + newResolved)
                
                Button("save"){
                    PathRecorder.shared.toFirebase()
                }
                .onAppear() {
                    PositioningModel.shared.startPositioning()
                    PathRecorder.shared.startRecording()
                }
            }
        }
        .onReceive(positionModel.$currentLatLon) { latLon in
            guard let latLon = latLon else {
                return
            }
            loc = latLon
            let indoorAnchors = DataModelManager.shared.getNearbyLocations(
                for: .indoorDestination,
                location: loc,
                maxDistance: CLLocationDistance(100)
            )
            
            let pathAnchors = DataModelManager.shared.getNearbyLocations(
                for: .path,
                location: loc,
                maxDistance: CLLocationDistance(100)
            )
            
            PositioningModel.shared.resolveAnchors(withInfo: indoorAnchors.union(pathAnchors))
        }
        .onReceive(PositioningModel.shared.$lastAnchor) { anchorName in
            newResolved = anchorName
            let _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                newResolved = ""
            }
        }
    }
}

struct VisualizingARMapView: View{
    @ObservedObject var positioningModel = PositioningModel.shared
    
    var body: some View {
        Text("Visualizing")
            .onAppear {
                PositioningModel.shared.startPositioning()
                PositioningModel.shared.renderer()
            }
        
    }
}


//struct PathPlot: View {
//    let points: [KeypointInfo]
//    let currentTransform: simd_float4x4?
//    var body: some View {
//        if let plotBounds = Self.getPlotBounds(keypoints: points) {
//            Chart {
//                if let currentTransform = currentTransform {
//                    PointMark(x: .value("z", currentTransform.columns.3.z),
//                              y: .value("x", currentTransform.columns.3.x))
//                    .symbol(Arrow(angle: CGFloat(Float.pi/2 - getPhoneHeadingYaw(currentLocation: currentTransform)), size: 100))
//                }
//                ForEach(points) { point in
//                    LineMark(
//                        x: .value("z", point.location.translation.z),
//                        y: .value("x", point.location.translation.x)
//                    )
//                    PointMark(
//                        x: .value("z", point.location.translation.z),
//                        y: .value("x", point.location.translation.x)
//                    ).foregroundStyle(RouteNavigator.shared.isCheckedOff(point) ? .black : .blue)
//                }
//            }
//            .chartXScale(domain: ClosedRange(uncheckedBounds: (plotBounds.0, plotBounds.1)))
//            .chartYScale(domain: ClosedRange(uncheckedBounds: (plotBounds.2, plotBounds.3)))
//        } else {
//            Text("Localize first before seeing route preview")
//        }
//    }
//}

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

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
    
}
#endif
