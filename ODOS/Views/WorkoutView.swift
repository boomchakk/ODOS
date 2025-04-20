import SwiftUI

struct WorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var startTime: Date?
    @State private var duration: TimeInterval = 0
    @State private var exercises: [Exercise] = []
    @State private var showingExercisePicker = false
    @State private var workoutName = "New Workout"
    @State private var isEditingName = false
    @State private var showingWorkoutPicker = true
    @State private var isWorkoutActive = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            Group {
                if showingWorkoutPicker {
                    workoutPickerView
                } else {
                    activeWorkoutView
                }
            }
            .navigationBarItems(trailing: isWorkoutActive ? finishButton : nil)
        }
    }
    
    private var workoutPickerView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Select Workout")
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Empty Workout Option
                Button(action: startEmptyWorkout) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Empty Workout")
                            .font(.headline)
                        Text("Start with a blank workout")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Workout Plan Options
                Text("Workout Plans")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    workoutPlanButton("Upper Body", systemImage: "figure.arms.open")
                    workoutPlanButton("Lower Body", systemImage: "figure.walk")
                    workoutPlanButton("Push", systemImage: "arrow.up")
                    workoutPlanButton("Pull", systemImage: "arrow.down")
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    private var activeWorkoutView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                workoutHeader
                
                if isWorkoutActive {
                    // Timer
                    timerView
                        .padding(.horizontal)
                    
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
                } else {
                    // Start Workout Button
                    Button(action: startWorkout) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Start Workout")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .onReceive(timer) { _ in
            if let start = startTime {
                duration = Date().timeIntervalSince(start)
            }
        }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePicker(viewModel: viewModel) { exercise in
                var newExercise = exercise
                newExercise.sets = [WorkoutSet(weight: 0, reps: 0)]
                exercises.append(newExercise)
            }
        }
    }
    
    private var workoutHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isEditingName {
                TextField("Workout Name", text: $workoutName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title)
                    .onSubmit {
                        isEditingName = false
                    }
            } else {
                Button(action: { isEditingName = true }) {
                    HStack {
                        Text(workoutName)
                            .font(.title)
                            .bold()
                        Image(systemName: "pencil")
                            .font(.headline)
                    }
                }
            }
            if let start = startTime {
                Text(start, style: .date)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    private var timerView: some View {
        HStack {
            Image(systemName: "clock")
            Text(formatDuration(duration))
        }
        .font(.title2)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func workoutPlanButton(_ name: String, systemImage: String) -> some View {
        Button(action: { startPlanWorkout(name) }) {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 30))
                Text(name)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    private func startEmptyWorkout() {
        workoutName = "New Workout"
        exercises = []
        showingWorkoutPicker = false
    }
    
    private func startPlanWorkout(_ plan: String) {
        workoutName = plan
        exercises = viewModel.getWorkoutPlan(plan)
        showingWorkoutPicker = false
    }
    
    private func startWorkout() {
        startTime = Date()
        duration = 0
        isWorkoutActive = true
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
        guard let start = startTime else { return }
        let workout = Workout(
            name: workoutName,
            date: start,
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
        startTime = nil
        duration = 0
        isWorkoutActive = false
        showingWorkoutPicker = true
    }
}

struct ExerciseCard: View {
    @Binding var exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exercise.name)
                .font(.headline)
            
            if !exercise.instructions.isEmpty {
                Text(exercise.instructions[0])
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // AI Recommendations
            if let recommendedReps = exercise.recommendedReps {
                HStack {
                    Image(systemName: "brain")
                    Text("Recommended: \(recommendedReps) reps")
                    if let notes = exercise.notes {
                        Button(action: {}) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                        }
                        .help(notes)
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.vertical, 4)
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
                exercise.sets.append(WorkoutSet(weight: 0, reps: 0))
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
    @Binding var set: WorkoutSet
    
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

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search exercises...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ExercisePicker: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var searchText = ""
    @State private var selectedMuscleGroup: MuscleGroup = .all
    @State private var selectedEquipment: Equipment = .all
    @State private var showingFilters = false
    let onSelect: (Exercise) -> Void
    
    var filteredExercises: [DatabaseExercise] {
        var filtered = viewModel.databaseExercises
        
        // Apply muscle group filter
        if selectedMuscleGroup != .all {
            filtered = filtered.filter { exercise in
                let muscles = selectedMuscleGroup.muscles()
                return !Set(exercise.primaryMuscles).isDisjoint(with: Set(muscles))
            }
        }
        
        // Apply equipment filter
        if selectedEquipment != .all {
            filtered = filtered.filter { exercise in
                Equipment.match(exercise.equipment) == selectedEquipment
            }
        }
        
        // Apply search text
        if !searchText.isEmpty {
            filtered = filtered.filter { exercise in
                exercise.name.localizedCaseInsensitiveContains(searchText) ||
                exercise.primaryMuscles.contains { muscle in
                    muscle.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Filter Bar
                filterBar
                
                if showingFilters {
                    filterView
                }
                
                // Exercise List
                if filteredExercises.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(filteredExercises) { dbExercise in
                            Button(action: {
                                let workoutExercise = viewModel.createWorkoutExercise(from: dbExercise)
                                onSelect(workoutExercise)
                                dismiss()
                            }) {
                                ExerciseRow(exercise: dbExercise)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Exercise")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private var filterBar: some View {
        HStack {
            Button(action: { withAnimation { showingFilters.toggle() } }) {
                HStack {
                    Image(systemName: showingFilters ? "chevron.up" : "line.3.horizontal.decrease")
                    Text("Filters")
                }
                .foregroundColor(.primary)
            }
            
            Spacer()
            
            if selectedMuscleGroup != .all || selectedEquipment != .all {
                Button(action: resetFilters) {
                    Text("Reset")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var filterView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Muscle Groups")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MuscleGroup.allCases, id: \.self) { group in
                        muscleGroupButton(group)
                    }
                }
                .padding(.horizontal)
            }
            
            Text("Equipment")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Equipment.allCases, id: \.self) { equipment in
                        equipmentButton(equipment)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private func muscleGroupButton(_ group: MuscleGroup) -> some View {
        Button(action: { selectedMuscleGroup = group }) {
            HStack {
                Image(systemName: group.icon)
                Text(group.rawValue)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selectedMuscleGroup == group ? Color.blue : Color.clear)
            .foregroundColor(selectedMuscleGroup == group ? .white : .primary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selectedMuscleGroup == group ? Color.blue : Color.secondary.opacity(0.5), lineWidth: 1)
            )
        }
    }
    
    private func equipmentButton(_ equipment: Equipment) -> some View {
        Button(action: { selectedEquipment = equipment }) {
            Text(equipment.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selectedEquipment == equipment ? Color.blue : Color.clear)
                .foregroundColor(selectedEquipment == equipment ? .white : .primary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedEquipment == equipment ? Color.blue : Color.secondary.opacity(0.5), lineWidth: 1)
                )
        }
    }
    
    private func resetFilters() {
        withAnimation {
            selectedMuscleGroup = .all
            selectedEquipment = .all
        }
    }
} 
