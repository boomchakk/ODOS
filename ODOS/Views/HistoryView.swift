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
                                ForEach(exercise.sets) { set in
                                    Text("Weight: \(Int(set.weight))kg | Reps: \(set.reps)")
                                        .font(.caption)
                                }
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