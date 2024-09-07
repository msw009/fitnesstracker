//
//  ContentView.swift
//  fitnesstracker
//
//  Created by Matthew Whigham on 9/6/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var showingAddWorkout = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.workouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout, viewModel: viewModel)) {
                        Text(workout.date, style: .date)
                    }
                }
                .onDelete(perform: deleteWorkout)
            }
            .navigationTitle("Workouts")
            .toolbar {
                Button(action: { showingAddWorkout = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView(viewModel: viewModel)
            }
        }
    }
    
    private func deleteWorkout(at offsets: IndexSet) {
        offsets.forEach { index in
            viewModel.deleteWorkout(viewModel.workouts[index])
        }
    }
}

struct WorkoutDetailView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    let workout: Workout
    
    var body: some View {
        List {
            ForEach(workout.exercises) { exercise in
                Section(header: Text(exercise.name)) {
                    ForEach(exercise.sets) { set in
                        HStack {
                            Text("\(set.reps) reps")
                            Spacer()
                            Text("\(set.weight, specifier: "%.1f") lbs")
                        }
                    }
                }
            }
        }
        .navigationTitle(workout.date, style: .date)
    }
}

struct AddWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var exerciseName = ""
    @State private var reps = ""
    @State private var weight = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Exercise Name", text: $exerciseName)
                TextField("Reps", text: $reps)
                    .keyboardType(.numberPad)
                TextField("Weight (lbs)", text: $weight)
                    .keyboardType(.decimalPad)
                
                Button("Add Set") {
                    addSet()
                }
            }
            .navigationTitle("Add Workout")
            .toolbar {
                Button("Save") {
                    saveWorkout()
                }
            }
        }
    }
    
    private func addSet() {
        guard let repsInt = Int(reps), let weightDouble = Double(weight) else { return }
        let newSet = Set(reps: repsInt, weight: weightDouble)
        let newExercise = Exercise(name: exerciseName, sets: [newSet])
        let newWorkout = Workout(exercises: [newExercise])
        viewModel.addWorkout(newWorkout)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func saveWorkout() {
        addSet() // This will also save the workout and dismiss the view
    }
}
