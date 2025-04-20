//
//  ContentView.swift
//  ODOS
//
//  Created by Brent Chaker on 20/4/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    
    var body: some View {
        TabView {
            WorkoutView(viewModel: viewModel)
                .tabItem {
                    Label("Workout", systemImage: "dumbbell.fill")
                }
            
            HistoryView(viewModel: viewModel)
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            ExerciseInventoryView(viewModel: viewModel)
                .tabItem {
                    Label("Inventory", systemImage: "list.bullet")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
