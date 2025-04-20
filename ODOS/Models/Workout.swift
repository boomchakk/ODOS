import Foundation

struct Workout: Identifiable {
    let id = UUID()
    var name: String
    var date: Date
    var duration: TimeInterval
    var exercises: [Exercise]
} 