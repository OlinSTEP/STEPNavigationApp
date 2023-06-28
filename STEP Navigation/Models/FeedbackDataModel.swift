
import Foundation


/// A class to handle creating feedback and uploading it to Firebase
class FeedbackModel {
/// Saves feedback information given by the user. The feedback is serialized to JSON format and then uploaded.
    /// - Parameters:
    ///   - feedbackStatus: A string indicating whether the users chose 'thumbs up' 'thumbs down'.
    ///   - response: A string containing extra descriptions added by the user.
    ///   - isInstructionsSelected: A boolean indicating whether the user had problems with instructions.
    ///   - isObstacleSelected: A boolean indicating whether the user encountered large obstacles.
    ///   - isLostSelected: A boolean indicating whether the user got lost during navigation.
    ///   - isLongerSelected: A boolean indicating whether the navigation took longer than expected.
    ///   - isOtherSelected: A boolean indicating whether the user experienced other issues not listed above.
    func saveFeedback(feedbackStatus: FeedbackStatus,
                      response: String,
                      isInstructionsSelected: Bool,
                      isObstacleSelected: Bool,
                      isLostSelected: Bool,
                      isLongerSelected: Bool,
                      isOtherSelected: Bool) {
        let feedback: [String: Any] = [
            "Incorrect or unclear instructions": isInstructionsSelected,
            "Directed me into a wall": isObstacleSelected,
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
   
    /// Uploads the updated feedback data to Firebase.
    private func uploadFeedback(_ feedbackData: Data) {
        FirebaseManager.shared.uploadFeedback(feedbackData)
    }
    
    /// Returns the URL for the document directory in the user's domain.
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
