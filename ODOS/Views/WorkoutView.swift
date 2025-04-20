import SwiftUI

struct WorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var startTime = Date()
    @State private var duration: TimeInterval = 0
    @State private var exercises: [Exercise] = []
    @State private var showingExercisePicker = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    workoutHeader
                    
                    // Exercises
                    ForEach($exercises) { $exercise in
                        ExerciseCard(exercise: $exercise)
                    }
                    
                    // Add Exercise Button
                    Button(action: { showingExercisePicker = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Exercises")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Cancel Button
                    Button(action: cancelWorkout) {
                        Text("Cancel Workout")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarItems(trailing: finishButton)
            .onReceive(timer) { _ in
                duration = Date().timeIntervalSince(startTime)
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePicker(viewModel: viewModel) { exerciseName in
                    let exercise = Exercise(
                        name: exerciseName,
                        instruction: "Going for 8-12 perfect form weight not goal",
                        sets: [Set(weight: 0, reps: 0, previousSet: "100 kg × 6")]
                    )
                    exercises.append(exercise)
                }
            }
        }
    }
    
    private var workoutHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Afternoon Workout")
                .font(.title)
                .bold()
            Text(startTime, style: .date)
                .foregroundColor(.secondary)
            Text(formatDuration(duration))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    private var finishButton: some View {
        Button("Finish") {
            finishWorkout()
        }
        .foregroundColor(.green)
        .font(.headline)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func finishWorkout() {
        let workout = Workout(
            name: "Afternoon Workout",
            date: startTime,
            duration: duration,
            exercises: exercises
        )
        viewModel.saveWorkout(workout)
        resetWorkout()
    }
    
    private func cancelWorkout() {
        resetWorkout()
    }
    
    private func resetWorkout() {
        exercises.removeAll()
        startTime = Date()
        duration = 0
    }
}

struct ExerciseCard: View {
    @Binding var exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exercise.name)
                .font(.headline)
            
            if let instruction = exercise.instruction {
                Text(instruction)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // Sets Table Header
            HStack {
                Text("Set")
                    .frame(width: 40, alignment: .leading)
                Text("Previous")
                    .frame(width: 100, alignment: .leading)
                Text("kg")
                    .frame(width: 60, alignment: .leading)
                Text("Reps")
                    .frame(width: 60, alignment: .leading)
                Spacer()
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
            
            // Sets
            ForEach($exercise.sets.indices, id: \.self) { index in
                SetRow(
                    setNumber: index + 1,
                    set: $exercise.sets[index]
                )
            }
            
            // Add Set Button
            Button(action: {
                exercise.sets.append(Set(weight: 0, reps: 0, previousSet: exercise.sets.last?.previousSet))
            }) {
                Text("+ Add Set")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.secondary.opacity(0.1))
                    .foregroundColor(.secondary)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
        .padding(.horizontal)
    }
}

struct SetRow: View {
    let setNumber: Int
    @Binding var set: Set
    
    var body: some View {
        HStack {
            Text("\(setNumber)")
                .frame(width: 40, alignment: .leading)
            Text(set.previousSet ?? "-")
                .frame(width: 100, alignment: .leading)
                .foregroundColor(.secondary)
            TextField("0", value: $set.weight, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 60)
                .keyboardType(.decimalPad)
            TextField("0", value: $set.reps, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 60)
                .keyboardType(.numberPad)
            Spacer()
            Button(action: { set.isCompleted.toggle() }) {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.isCompleted ? .green : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExercisePicker: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WorkoutViewModel
    let onSelect: (String) -> Void
    
    var body: some View {
        NavigationView {
            List(viewModel.exerciseInventory, id: \.self) { exercise in
                Button(action: {
                    onSelect(exercise)
                    dismiss()
                }) {
                    Text(exercise)
                }
            }
            .navigationTitle("Select Exercise")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
} 