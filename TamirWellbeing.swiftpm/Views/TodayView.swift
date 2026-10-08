import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @AppStorage(Keys.selectedPerson) private var person = 0
    @State private var day = Date.now.startOfDay
    @State private var entry: DailyEntry?

    private var isToday: Bool { day == Date.now.startOfDay }

    private var title: String {
        if isToday { return "Today" }
        if day == Date.now.startOfDay.adding(days: -1) { return "Yesterday" }
        return day.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PersonPicker()
                    DateStepper(
                        title: title,
                        canGoForward: !isToday,
                        back: { day = day.adding(days: -1) },
                        forward: { day = day.adding(days: 1) }
                    )
                }
                if let entry {
                    DayEditor(entry: entry)
                }
            }
            .navigationTitle("Daily Log")
            .toolbar {
                if !isToday {
                    Button("Today") { day = Date.now.startOfDay }
                }
            }
            .task(id: "\(person)-\(day.timeIntervalSince1970)") {
                entry = context.entry(for: day, person: person)
            }
        }
    }
}

/// The editable fields of a single day. Rendered as Form sections.
struct DayEditor: View {
    @Bindable var entry: DailyEntry

    @AppStorage(Keys.goalWater) private var goalWater = Defaults.goalWater
    @AppStorage(Keys.goalVeg) private var goalVeg = Defaults.goalVeg
    @AppStorage(Keys.goalSleep) private var goalSleep = Defaults.goalSleep
    @AppStorage(Keys.goalExercise) private var goalExercise = Defaults.goalExercise
    @AppStorage(Keys.goalSteps) private var goalSteps = Defaults.goalSteps

    @State private var weightText = ""

    var body: some View {
        Section {
            Toggle(isOn: $entry.isTreatDay) {
                Label("Treat day", systemImage: "birthday.cake.fill")
                    .foregroundStyle(entry.isTreatDay ? Color.pink : Color.primary)
            }
        } footer: {
            Text("A planned day off — enjoy it guilt‑free.")
        }

        Section("Food & drink") {
            Stepper(value: $entry.waterLiters, in: 0...8, step: 0.25) {
                MetricLabel(icon: "drop.fill", color: .blue, title: "Water",
                            value: "\(entry.waterLiters.compact) L",
                            goalMet: entry.waterLiters >= goalWater)
            }
            Stepper(value: $entry.vegMeals, in: 0...10) {
                MetricLabel(icon: "carrot.fill", color: .green, title: "Meals with veggies",
                            value: "\(entry.vegMeals)",
                            goalMet: entry.vegMeals >= goalVeg)
            }
            Stepper(value: $entry.fruitServings, in: 0...10) {
                MetricLabel(icon: "basket.fill", color: .red, title: "Fruit servings",
                            value: "\(entry.fruitServings)")
            }
            VStack(alignment: .leading, spacing: 8) {
                MetricLabel(icon: "fork.knife", color: .orange, title: "Carbs level", value: "")
                Picker("Carbs level", selection: $entry.carbLevel) {
                    ForEach(0..<CarbLevel.labels.count, id: \.self) { level in
                        Text(CarbLevel.labels[level]).tag(level)
                    }
                }
                .pickerStyle(.segmented)
            }
            Stepper(value: $entry.sweets, in: 0...10) {
                MetricLabel(icon: "takeoutbag.and.cup.and.straw.fill", color: .brown,
                            title: "Sweets / sugary drinks", value: "\(entry.sweets)")
            }
        }

        Section("Sleep") {
            Stepper(value: $entry.sleepHours, in: 0...14, step: 0.5) {
                MetricLabel(icon: "bed.double.fill", color: .indigo, title: "Hours slept",
                            value: "\(entry.sleepHours.compact) h",
                            goalMet: entry.sleepHours >= goalSleep)
            }
            RatingRow(title: "Sleep quality", symbols: ["😫", "🥱", "😐", "🙂", "😴"],
                      value: $entry.sleepQuality)
        }

        Section("Movement") {
            Stepper(value: $entry.exerciseMinutes, in: 0...300, step: 5) {
                MetricLabel(icon: "figure.run", color: .mint, title: "Exercise",
                            value: "\(entry.exerciseMinutes) min",
                            goalMet: entry.exerciseMinutes >= goalExercise)
            }
            HStack {
                MetricLabel(icon: "shoeprints.fill", color: .teal, title: "Steps", value: "",
                            goalMet: entry.steps >= goalSteps)
                TextField("0", value: $entry.steps, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 110)
            }
        }

        Section("Mind") {
            RatingRow(title: "Mood", symbols: ["😞", "🙁", "😐", "🙂", "😄"], value: $entry.mood)
            RatingRow(title: "Energy", symbols: ["🪫", "😪", "😐", "💪", "⚡️"], value: $entry.energy)
            RatingRow(title: "Stress", symbols: ["😌", "🙂", "😐", "😟", "🤯"], value: $entry.stress)
            Stepper(value: $entry.mindfulMinutes, in: 0...180, step: 5) {
                MetricLabel(icon: "leaf.fill", color: .green, title: "Mindfulness / quiet time",
                            value: "\(entry.mindfulMinutes) min")
            }
        }

        Section("Weight") {
            HStack {
                MetricLabel(icon: "scalemass.fill", color: .purple, title: "Weight", value: "")
                TextField("kg", text: $weightText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 90)
                Text("kg").foregroundStyle(.secondary)
            }
        }
        .task(id: entry.persistentModelID) {
            weightText = entry.weightKg.map { $0.compact } ?? ""
        }
        .onChange(of: weightText) { _, text in
            let normalized = text.replacingOccurrences(of: ",", with: ".")
            let parsed = Double(normalized).flatMap { $0 > 0 ? $0 : nil }
            // Skip writes when only the display formatting differs.
            if parsed?.compact != entry.weightKg?.compact {
                entry.weightKg = parsed
            }
        }

        Section("Notes") {
            TextField("How was the day?", text: $entry.notes, axis: .vertical)
                .lineLimit(2...6)
        }
    }
}

struct MetricLabel: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    var goalMet: Bool? = nil

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(title)
            if goalMet == true {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
            Spacer()
            if !value.isEmpty {
                Text(value)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Five tappable symbols; tapping the selected one again clears it.
struct RatingRow: View {
    let title: String
    let symbols: [String]
    @Binding var value: Int

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            ForEach(1...5, id: \.self) { level in
                Button {
                    value = (value == level) ? 0 : level
                } label: {
                    Text(symbols[level - 1])
                        .font(.title3)
                        .opacity(value == level ? 1 : 0.3)
                        .scaleEffect(value == level ? 1.2 : 1)
                }
                .buttonStyle(.borderless)
            }
        }
        .animation(.snappy, value: value)
    }
}
