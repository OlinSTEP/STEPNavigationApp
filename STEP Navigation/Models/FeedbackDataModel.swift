
import Foundation

class FeedbackModel {
    
    func saveFeedback(feedbackStatus: String,
                      response: String,
                      isInstructionsSelected: Bool,
                      isObstacleSelected: Bool,
                      isLostSelected: Bool,
                      isLongerSelected: Bool,
                      isOtherSelected: Bool) {
        let feedback: [String: Any] = [
            "Incorrect or unclear instructions": isInstructionsSelected,
            "The route led me into a large obstacle": isObstacleSelected,
            "The navigation took longer than expected": isLongerSelected,
            "I got lost along the route": isLostSelected,
            "Other": isOtherSelected,
            "Problem Description": response,
            "Good/Bad":feedbackStatus,
            "associatedLog": FirebaseManager.shared.lastLogPath ?? ""
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: feedback)
            uploadFeedback(jsonData)
            
        } catch {
            print("Failed to serialize feedback to JSON")
        }
    }
    
    private func uploadFeedback(_ feedbackData: Data) {
        FirebaseManager.shared.uploadFeedback(feedbackData)
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
