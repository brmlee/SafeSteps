import Foundation

/// A struct that stores basic information about a user
/// Used in `FirebaseManager`
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 21, 2023
///
struct User {
    var name: String
    var device_id: String
    var age: Int
    var sex: String
    var survey_responses: [String: Int]
}
