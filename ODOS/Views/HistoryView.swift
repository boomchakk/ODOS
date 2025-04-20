import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.workouts) { workout in
                    VStack(alignment: .leading) {
                        Text(workout.date, style: .date)
                            .font(.headline)
                        
                        ForEach(workout.exercises) { exercise in
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .font(.subheadline)
                                Text("Sets: \(exercise.sets) | Reps: \(exercise.reps) | Weight: \(exercise.weight) lbs")
                                    .font(.caption)
                            }
                            .padding(.leading)
                        }
                    }
                }
            }
            .navigationTitle("Workout History")
        }
    }
} 