import Foundation

class WorkoutViewModel: ObservableObject {
    @Published var databaseExercises: [DatabaseExercise] = []
    @Published var workouts: [Workout] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var generatedWorkouts: [String: [Exercise]] = [:]
    
    private let exerciseService = ExerciseService.shared
    private let aiService = AIWorkoutService.shared
    
    // Predefined workout plans
    private var workoutPlans: [String: [String]] = [
        "Upper Body": ["Bench Press", "Overhead Press", "Pull-ups", "Rows", "Lateral Raises"],
        "Lower Body": ["Squats", "Deadlifts", "Leg Press", "Calf Raises", "Leg Extensions"],
        "Push": ["Bench Press", "Overhead Press", "Incline Press", "Tricep Extensions", "Lateral Raises"],
        "Pull": ["Pull-ups", "Rows", "Face Pulls", "Bicep Curls", "Lat Pulldowns"]
    ]
    
    // Available equipment in the gym
    private let availableEquipment = [
        "Barbell", "Dumbbell", "Cable Machine", "Smith Machine",
        "Pull-up Bar", "Bench", "Squat Rack", "Leg Press Machine",
        "Lat Pulldown Machine", "Resistance Bands"
    ]
    
    init() {
        Task {
            await loadExercises()
        }
    }
    
    @MainActor
    func loadExercises() async {
        isLoading = true
        do {
            databaseExercises = try await exerciseService.fetchExercises()
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func createWorkoutExercise(from dbExercise: DatabaseExercise) -> Exercise {
        Exercise(from: dbExercise)
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
    
    @MainActor
    func generateAIWorkout(type: String) async {
        isLoading = true
        
        let request = WorkoutRequest(
            type: type,
            equipment: availableEquipment,
            experienceLevel: "Intermediate",
            duration: 60
        )
        
        do {
            let recommendations = try await aiService.generateWorkout(request: request)
            
            // Convert AI recommendations to exercises
            let exercises = recommendations.compactMap { recommendation -> Exercise? in
                // Try to find a matching exercise in our database
                if let dbExercise = findMatchingExercise(for: recommendation) {
                    var exercise = Exercise(from: dbExercise)
                    // Add the recommended sets with default weight
                    exercise.sets = Array(repeating: WorkoutSet(weight: 0, reps: 0), count: recommendation.sets)
                    exercise.recommendedReps = recommendation.repsRange
                    exercise.notes = recommendation.notes
                    return exercise
                }
                return nil
            }
            
            generatedWorkouts[type] = exercises
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    private func findMatchingExercise(for recommendation: ExerciseRecommendation) -> DatabaseExercise? {
        // First try exact match
        if let exercise = databaseExercises.first(where: { $0.name.lowercased() == recommendation.name.lowercased() }) {
            return exercise
        }
        
        // Then try fuzzy match
        return databaseExercises.first { exercise in
            exercise.name.lowercased().contains(recommendation.name.lowercased()) ||
            recommendation.name.lowercased().contains(exercise.name.lowercased())
        }
    }
    
    func getWorkoutPlan(_ planName: String) -> [Exercise] {
        // First check if we have an AI-generated workout
        if let generatedWorkout = generatedWorkouts[planName] {
            return generatedWorkout
        }
        
        // If not, generate one asynchronously for next time
        Task {
            await generateAIWorkout(type: planName)
        }
        
        // Meanwhile, return the default workout
        guard let exerciseNames = workoutPlans[planName] else { return [] }
        
        return exerciseNames.compactMap { name in
            if let dbExercise = databaseExercises.first(where: { $0.name == name }) {
                var exercise = Exercise(from: dbExercise)
                exercise.sets = [WorkoutSet(weight: 0, reps: 0)]
                return exercise
            }
            return nil
        }
    }
} 
