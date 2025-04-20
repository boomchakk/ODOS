import Foundation

struct Set: Identifiable {
    let id = UUID()
    var weight: Double
    var reps: Int
    var isCompleted: Bool = false
    var previousSet: String?
}

struct Exercise: Identifiable {
    let id = UUID()
    var name: String
    var instruction: String?
    var sets: [Set]
}

struct Workout: Identifiable {
    let id = UUID()
    var name: String
    var date: Date
    var duration: TimeInterval
    var exercises: [Exercise]
} 