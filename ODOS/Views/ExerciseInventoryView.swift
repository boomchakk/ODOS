import SwiftUI

struct ExerciseInventoryView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var newExercise = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.exerciseInventory, id: \.self) { exercise in
                        Text(exercise)
                    }
                    .onDelete(perform: deleteExercise)
                }
                
                HStack {
                    TextField("New Exercise", text: $newExercise)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: addExercise) {
                        Text("Add")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Exercise Inventory")
        }
    }
    
    private func addExercise() {
        guard !newExercise.isEmpty else { return }
        viewModel.addExerciseToInventory(newExercise)
        newExercise = ""
    }
    
    private func deleteExercise(at offsets: IndexSet) {
        viewModel.exerciseInventory.remove(atOffsets: offsets)
    }
} 