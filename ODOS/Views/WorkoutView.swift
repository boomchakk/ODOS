import SwiftUI

struct WorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var exercises: [Exercise] = []
    @State private var selectedExercise = ""
    @State private var sets = ""
    @State private var reps = ""
    @State private var weight = ""
    @State private var showNewExerciseSheet = false
    @State private var newExerciseName = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(exercises) { exercise in
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .font(.headline)
                            Text("Sets: \(exercise.sets) | Reps: \(exercise.reps) | Weight: \(exercise.weight) lbs")
                                .font(.subheadline)
                        }
                    }
                    .onDelete(perform: deleteExercise)
                }
                
                VStack(spacing: 10) {
                    HStack {
                        Picker("Select Exercise", selection: $selectedExercise) {
                            Text("Select Exercise").tag("")
                            ForEach(viewModel.exerciseInventory, id: \.self) { exercise in
                                Text(exercise).tag(exercise)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Button(action: { showNewExerciseSheet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        TextField("Sets", text: $sets)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        
                        TextField("Reps", text: $reps)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        
                        TextField("Weight", text: $weight)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    Button(action: addExercise) {
                        Text("Add Exercise")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    if !exercises.isEmpty {
                        Button(action: completeWorkout) {
                            Text("Complete Workout")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Workout")
            .sheet(isPresented: $showNewExerciseSheet) {
                newExerciseSheet
            }
        }
    }
    
    private var newExerciseSheet: some View {
        NavigationView {
            VStack {
                TextField("New Exercise Name", text: $newExerciseName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    if !newExerciseName.isEmpty {
                        viewModel.addExerciseToInventory(newExerciseName)
                        selectedExercise = newExerciseName
                        newExerciseName = ""
                        showNewExerciseSheet = false
                    }
                }) {
                    Text("Add Exercise")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("New Exercise")
            .navigationBarItems(trailing: Button("Cancel") {
                showNewExerciseSheet = false
            })
        }
    }
    
    private func addExercise() {
        guard let setsInt = Int(sets),
              let repsInt = Int(reps),
              let weightDouble = Double(weight),
              !selectedExercise.isEmpty else { return }
        
        let exercise = Exercise(name: selectedExercise, sets: setsInt, reps: repsInt, weight: weightDouble)
        exercises.append(exercise)
        
        // Reset fields
        selectedExercise = ""
        sets = ""
        reps = ""
        weight = ""
    }
    
    private func deleteExercise(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }
    
    private func completeWorkout() {
        viewModel.saveWorkout(exercises: exercises)
        exercises.removeAll()
    }
} 