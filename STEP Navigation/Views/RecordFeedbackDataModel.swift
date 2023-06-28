//
//  RecordFeedbackDataModel.swift
//  STEP Navigation
//
//  Created by Muya Guoji on 6/26/23.
//  Test Line

import Foundation

/// A class to handle creating route recording feedback and uploading it to Firebase
class RecordFeedbackDataModel {
/// Saves route recording feedback information given by the user. The feedback is serialized to JSON format and then uploaded.
    /// - Parameters:
    ///   - recordFeedbackStatus: A string representing the user's choice, either 'thumbs up' or 'thumbs down'.
    ///   - recordResponse: A string containing additional descriptions or comments added by the user.
    ///   - isHoldAnchorSelected: A boolean indicating whether the user experienced problems with phone could not host the anchor.
    ///   - isRecordingInstructionSelected: A boolean indicating whether the user had issues with the instructions.
    ///   - isRecordLongerSelected: A boolean  indicating whether the navigation took longer than anticipated.
    ///   - isRecordOtherSelected: A boolean indicating whether the user encountered other issues in the above.
    func saveRecordFeedback(
                    recordFeedbackStatus: RecordFeedbackStatus,
                    recordResponse: String,
                 isHoldAnchorSelected: Bool,
               isRecordingInstructionSelected: Bool,
          isRecordLongerSelected: Bool,
        isRecordOtherSelected: Bool) {
        let recordFeedback: [String: Any] = [
            "Phone could not host the anchor": isHoldAnchorSelected,
            "Unclear Instructions": isRecordingInstructionSelected,
            "Took longer than expected": isRecordLongerSelected,
            "Other": isRecordOtherSelected,
            "Problem Description": recordResponse,
            "Good/Bad":recordFeedbackStatus,
            "associatedLog": FirebaseManager.shared.lastLogPath ?? ""
        ]
            
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: recordFeedback)
            uploadRecordFeedback(jsonData)
            
        } catch {
            print("Failed to serialize feedback to JSON")
        }
    }
   
    /// Uploads the updated feedback data to Firebase.
    private func uploadRecordFeedback(_ recordFeedback: Data) {
        FirebaseManager.shared.uploadRecordFeedback(recordFeedback)
    }
    
    /// Returns the URL for the document directory in the user's domain.
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


