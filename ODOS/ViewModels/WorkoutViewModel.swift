import Foundation

class WorkoutViewModel: ObservableObject {
    @Published var exerciseInventory: [String] = [
        "Bench Press (Barbell)",
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
    
    func saveWorkout(_ workout: Workout) {
        workouts.append(workout)
    }
    
    func getLastWorkout(for exerciseName: String) -> Exercise? {
        for workout in workouts.reversed() {
            if let exercise = workout.exercises.first(where: { $0.name == exerciseName }) {
                return exercise
            }
        }
        return nil
    }
} 