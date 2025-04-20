import SwiftUI

struct ExerciseInventoryView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var searchText = ""
    @State private var selectedMuscleGroup: MuscleGroup = .all
    @State private var selectedEquipment: Equipment = .all
    @State private var showingFilters = false
    
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
                // Search and Filter Header
                VStack(spacing: 12) {
                    searchBar
                    filterBar
                }
                .background(Color(UIColor.systemBackground))
                
                if showingFilters {
                    filterView
                        .transition(.move(edge: .top))
                }
                
                // Exercise List
                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading exercises...")
                    } else if let error = viewModel.error {
                        ErrorView(error: error)
                    } else {
                        exerciseList
                    }
                }
            }
            .navigationTitle("Exercise Inventory")
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search exercises", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
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
    
    private var exerciseList: some View {
        Group {
            if filteredExercises.isEmpty {
                EmptyStateView()
            } else {
                List {
                    ForEach(filteredExercises) { exercise in
                        ExerciseRow(exercise: exercise)
                    }
                }
            }
        }
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

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No exercises found")
                .font(.headline)
            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack {
            Text("Error loading exercises")
                .foregroundColor(.red)
            Text(error.localizedDescription)
                .foregroundColor(.secondary)
        }
    }
}

struct ExerciseRow: View {
    let exercise: DatabaseExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name)
                .font(.headline)
            
            HStack {
                if let equipment = exercise.equipment {
                    Label(equipment, systemImage: "dumbbell")
                        .font(.caption)
                }
                
                Label(exercise.level, systemImage: "chart.bar")
                    .font(.caption)
            }
            
            if !exercise.primaryMuscles.isEmpty {
                Text("Primary: \(exercise.primaryMuscles.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
} 