import Foundation

class WorkoutViewModel: ObservableObject {
    @Published var exerciseInventory: [String] = [
        "Bench Press",
        "Squat",
        "Deadlift",
        "Overhead Press",
        "Pull-ups",
        "Rows",
        "Lunges"
    ]
    @Published var workouts: [Workout] = []
    
    func addExerciseToInventory(_ exercise: String) {
        if !exerciseInventory.contains(exercise) {
            exerciseInventory.append(exercise)
        }
    }
    
    func saveWorkout(exercises: [Exercise]) {
        let workout = Workout(date: Date(), exercises: exercises)
        workouts.append(workout)
    }
} 