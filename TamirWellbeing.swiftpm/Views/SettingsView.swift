import SwiftUI

struct SettingsView: View {
    @AppStorage(Keys.parentName0) private var name0 = Defaults.parentName0
    @AppStorage(Keys.parentName1) private var name1 = Defaults.parentName1
    @AppStorage(Keys.goalWater) private var goalWater = Defaults.goalWater
    @AppStorage(Keys.goalVeg) private var goalVeg = Defaults.goalVeg
    @AppStorage(Keys.goalSleep) private var goalSleep = Defaults.goalSleep
    @AppStorage(Keys.goalExercise) private var goalExercise = Defaults.goalExercise
    @AppStorage(Keys.goalSteps) private var goalSteps = Defaults.goalSteps

    var body: some View {
        NavigationStack {
            Form {
                Section("Parents") {
                    TextField("First parent", text: $name0)
                    TextField("Second parent", text: $name1)
                }

                Section {
                    Stepper("Water: \(goalWater.compact) L", value: $goalWater, in: 0.5...6, step: 0.25)
                    Stepper("Meals with veggies: \(goalVeg)", value: $goalVeg, in: 1...6)
                    Stepper("Sleep: \(goalSleep.compact) h", value: $goalSleep, in: 4...12, step: 0.5)
                    Stepper("Exercise: \(goalExercise) min", value: $goalExercise, in: 5...180, step: 5)
                    Stepper("Steps: \(goalSteps.formatted())", value: $goalSteps, in: 1000...30000, step: 500)
                } header: {
                    Text("Daily goals")
                } footer: {
                    Text("Goals are used for the check marks on the daily log and the weekly summary.")
                }

                Section("About") {
                    LabeledContent("App", value: "Tamir Family Wellbeing")
                    LabeledContent("Version", value: "1.0")
                    Text("All data is stored privately on this iPhone.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
