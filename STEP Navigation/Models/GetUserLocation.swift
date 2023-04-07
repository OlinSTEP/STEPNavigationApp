//
//  GetUserLocation.swift
//  STEP Navigation
//
//  Created by Xinyi WU on 4/7/23.
//

import Foundation
import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    var session: ARSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an AR session and set the delegate
        session = ARSession()
        session.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start the AR session
        let configuration = ARWorldTrackingConfiguration()
        session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the AR session
        session.pause()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Get the user's location in world space
        let userLocation = frame.camera.transform
        
        // Do something with the user's location
        print("User's location: \(userLocation)")
    }
}
