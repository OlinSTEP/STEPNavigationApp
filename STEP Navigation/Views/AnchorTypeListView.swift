//
//  AnchorTypeListView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/7/23.
//

import SwiftUI
import CoreLocation

struct AnchorTypeListView: View {
    @StateObject private var anchorData = AnchorData()
    
    var body: some View {

        NavigationView {
            List {
                ForEach(AnchorDetails.AnchorType.allCases, id: \.self) {
                    anchorType in
                    NavigationLink (
                        destination: LocalAnchorListView(anchorType: anchorType)
                            .environmentObject(anchorData),
                        label: {
                            Text(anchorType.rawValue)
                                .font(.title)
                        })
                }
            }
            .navigationTitle("My Anchor Groups")
            .toolbar (content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        print("Pressed home")
                    }, label: {
                        Image(systemName: "house")
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Pressed settings")
                    }, label: {
                        Image(systemName: "gear")
                    })
                }
            })
             //TODO make this asynch
            .onAppear {
                let dataModelManager = DataModelManager()
                let busModels = try! LocationDataModelParser.parse(from: "mbtaBusStops", fileType: "json", anchorType: .busStop)
                dataModelManager.multiAddDataModel(busModels, anchorType: .busStop)
                let closeStops = dataModelManager.getNearbyLocations(for: .busStop, location: CLLocationCoordinate2D(latitude: 42.293592, longitude: -71.264154), maxDistance: CLLocationDistance(3000))
                print("debug here")
                print(closeStops)
            }
        }
    }
}

struct AnchorTypeListView_Previews: PreviewProvider {
    static var previews: some View {
        AnchorTypeListView()
    }
}
