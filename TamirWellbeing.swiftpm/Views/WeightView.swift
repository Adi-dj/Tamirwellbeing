import SwiftUI
import SwiftData
import Charts

struct WeightView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DailyEntry.day, order: .reverse) private var allEntries: [DailyEntry]
    @AppStorage(Keys.selectedPerson) private var person = 0

    @State private var date = Date.now
    @State private var weightText = ""
    @FocusState private var weightFocused: Bool

    /// Newest first.
    private var weighIns: [DailyEntry] {
        allEntries.filter { $0.person == person && $0.weightKg != nil }
    }

    private var parsedWeight: Double? {
        Double(weightText.replacingOccurrences(of: ",", with: ".")).flatMap { $0 > 0 ? $0 : nil }
    }

    var body: some View {
        NavigationStack {
            List {
                Section { PersonPicker() }

                Section("Add weigh-in") {
                    DatePicker("Date", selection: $date, in: ...Date.now, displayedComponents: .date)
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("0.0", text: $weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($weightFocused)
                            .frame(maxWidth: 100)
                        Text("kg").foregroundStyle(.secondary)
                    }
                    Button("Save", action: save)
                        .disabled(parsedWeight == nil)
                }

                if weighIns.isEmpty {
                    ContentUnavailableView(
                        "No weigh-ins yet",
                        systemImage: "scalemass",
                        description: Text("Add your weight above to start tracking progress.")
                    )
                } else {
                    Section("Progress") {
                        summary
                        chart
                    }
                    Section("History") {
                        let list = weighIns
                        ForEach(list.indices, id: \.self) { index in
                            historyRow(list[index], previous: index + 1 < list.count ? list[index + 1] : nil)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Weight")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { weightFocused = false }
                }
            }
        }
    }

    private var summary: some View {
        let latest = weighIns.first?.weightKg
        let start = weighIns.last?.weightKg
        let change = (latest != nil && start != nil && weighIns.count > 1) ? latest! - start! : nil

        return HStack {
            summaryItem("Current", Format.value(latest, " kg"))
            Divider()
            summaryItem("Starting", Format.value(start, " kg"))
            Divider()
            summaryItem("Change", Format.signedKg(change))
        }
    }

    private func summaryItem(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline.monospacedDigit())
        }
        .frame(maxWidth: .infinity)
    }

    private var chart: some View {
        let points: [WeightPoint] = weighIns.reversed().compactMap { entry in
            entry.weightKg.map { WeightPoint(day: entry.day, kg: $0) }
        }
        let lowest = points.map(\.kg).min() ?? 0
        let highest = points.map(\.kg).max() ?? 0

        return Chart(points) { point in
            LineMark(x: .value("Date", point.day, unit: .day), y: .value("kg", point.kg))
                .interpolationMethod(.catmullRom)
            PointMark(x: .value("Date", point.day, unit: .day), y: .value("kg", point.kg))
        }
        .chartYScale(domain: (lowest - 1)...(highest + 1))
        .foregroundStyle(.purple)
        .frame(height: 200)
        .padding(.vertical, 8)
    }

    private func historyRow(_ entry: DailyEntry, previous: DailyEntry?) -> some View {
        HStack {
            Text(entry.day.formatted(date: .abbreviated, time: .omitted))
            Spacer()
            if let kg = entry.weightKg, let prev = previous?.weightKg {
                let diff = kg - prev
                Text(Format.signedKg(diff))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(diff > 0 ? Color.orange : (diff < 0 ? Color.green : Color.secondary))
            }
            Text(Format.value(entry.weightKg, " kg"))
                .monospacedDigit()
                .bold()
        }
    }

    private func save() {
        guard let kg = parsedWeight else { return }
        context.entry(for: date, person: person).weightKg = kg
        weightText = ""
        weightFocused = false
    }

    private func delete(at offsets: IndexSet) {
        let current = weighIns
        for index in offsets {
            current[index].weightKg = nil
        }
    }
}

struct WeightPoint: Identifiable {
    let day: Date
    let kg: Double
    var id: Date { day }
}
