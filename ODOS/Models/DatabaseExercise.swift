import Foundation

struct DatabaseExercise: Identifiable, Codable {
    let id: String
    var name: String
    var force: String?
    var level: String
    var mechanic: String?
    var equipment: String?
    var primaryMuscles: [String]
    var secondaryMuscles: [String]
    var instructions: [String]
    var category: String
    var images: [String]?
} 