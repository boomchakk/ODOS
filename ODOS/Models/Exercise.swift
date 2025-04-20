import Foundation

struct WorkoutSet: Identifiable {
    let id = UUID()
    var weight: Double
    var reps: Int
    var isCompleted: Bool = false
    var previousSet: String?
}

struct Exercise: Identifiable {
    let id: UUID
    var databaseId: String
    var name: String
    var instructions: [String]
    var equipment: String?
    var level: String?
    var primaryMuscles: [String]
    var sets: [WorkoutSet]
    var recommendedReps: String?
    var notes: String?
    
    init(from dbExercise: DatabaseExercise) {
        self.id = UUID()
        self.databaseId = dbExercise.id
        self.name = dbExercise.name
        self.instructions = dbExercise.instructions
        self.equipment = dbExercise.equipment
        self.level = dbExercise.level
        self.primaryMuscles = dbExercise.primaryMuscles
        self.sets = []
        self.recommendedReps = nil
        self.notes = nil
    }
} 