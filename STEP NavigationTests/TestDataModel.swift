//
//  TestDataModel.swift
//  STEP NavigationTests
//
//  Created by Sam Coleman on 4/10/23.
//

import XCTest
@testable import STEP_Navigation
import CoreLocation

final class STEP_NavigationTests: XCTestCase {
    var doorModels: Set<LocationDataModel> = []
    var busStopModels: Set<LocationDataModel> = []
    var dataModelMangaer = DataModelManager()
    let busStop = LocationDataModel(anchorType: .busStop, coordinates: CLLocationCoordinate2D(latitude: 37, longitude: -71), name: "Bus Stop 1")
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        let busStop = LocationDataModel(anchorType: .busStop, coordinates: CLLocationCoordinate2D(latitude: 37, longitude: -71), name: "Random bus stop")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }


    func testGetProperties() throws {
       // Test the creation and get private properties of a LocationDataModel
        
        XCTAssertEqual(busStop.getAnchorType(), .busStop, "Expected anchorType is .busStop")
        XCTAssertEqual(busStop.getName(), "Bus Stop 1", "Expected name is Bus Stop 1")
        
        // Compare coordinates with accuracy of 0.001 degrees
        XCTAssertEqual(
            busStop.getLocationCoordinate().latitude, 37, accuracy: 0.001,
            "Latitude values do not match"
        )
        XCTAssertEqual(
            busStop.getLocationCoordinate().longitude, -71, accuracy: 0.001,
            "Longitude values do not match"
        )
    }
    
    func testLocationDataModelParser() {
        busStopModels = try! LocationDataModelParser.parse(from: "testBusStops", fileType: "json", anchorType: .busStop)
        XCTAssertEqual(busStopModels.count, 2)
        
        doorModels = try! LocationDataModelParser.parse(from: "testDoors", fileType: "geojson", anchorType: .externalDoor)
        XCTAssertEqual(doorModels.count, 3)
    }
    
    func testDataModelManager() {
        
        // add bus stop models
        busStopModels = try! LocationDataModelParser.parse(from: "testBusStops", fileType: "json", anchorType: .busStop)
        doorModels = try! LocationDataModelParser.parse(from: "testDoors", fileType: "geojson", anchorType: .externalDoor)
        
        XCTAssertEqual(doorModels.count, 3)
        dataModelMangaer.multiAddDataModel(busStopModels, anchorType: .busStop)
        
        // check only one key in dataModelManager
        XCTAssertEqual(dataModelMangaer.getAllLocationModels().count, 1)

        // check the key in dataModelManager
        XCTAssertEqual(dataModelMangaer.getAnchorTypes(), [.busStop])

        // add door models
        dataModelMangaer.multiAddDataModel(doorModels, anchorType: .externalDoor)

        // check the value of the 2 keys
        XCTAssertEqual(dataModelMangaer.getAnchorTypes(), Set([.busStop, .externalDoor]))

        // get all door models
        XCTAssertEqual(dataModelMangaer.getLocationsByType(anchorType: .externalDoor), doorModels)
        
        // get all bus stop models
        XCTAssertEqual(dataModelMangaer.getLocationsByType(anchorType: .busStop), busStopModels)
        
        // confirm result of AnchorType not included is the empty set
        XCTAssertEqual(dataModelMangaer.getLocationsByType(anchorType: .frontdesk), Set())
        
        // add one data model
        dataModelMangaer.addDataModel(busStop)
        XCTAssertEqual(dataModelMangaer.getLocationsByType(anchorType: .externalDoor).count, 3)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
