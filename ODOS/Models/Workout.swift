import Foundation

struct Exercise: Identifiable {
    let id = UUID()
    var name: String
    var sets: Int
    var reps: Int
    var weight: Double
}

struct Workout: Identifiable {
    let id = UUID()
    var date: Date
    var exercises: [Exercise]
} 