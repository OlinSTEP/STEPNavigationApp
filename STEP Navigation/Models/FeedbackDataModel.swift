
import Foundation

struct MultipleChoiceModel {
    static func saveFeedback(feedbackStatus: String,
                             response: String,
                             isNavigationSelected: Bool,
                             isRouteRecordingSelected: Bool,
                             isLocationAnchorSelected: Bool,
                             isOtherSelected: Bool) {
        let feedback: [String: Any] = [
            "Navigation Problem": isNavigationSelected,
            "Route Recording": isRouteRecordingSelected,
            "Location Anchor Problem": isLocationAnchorSelected,
            "Others": isOtherSelected,
            "Problem Description": response,
            "Good/Bad":feedbackStatus,
            "associatedLog": FirebaseManager.shared.lastLogPath ?? ""
        ]

        
        do {
                   let jsonData = try JSONSerialization.data(withJSONObject: feedback)
                   FirebaseManager.shared.uploadFeedback(jsonData)
       
               }
        
        catch {
            print("Failed to serialize feedback to JSON")
        }
    }
    
    static func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
    }
