import SwiftUI
import SwiftData
import Charts

struct WeekView: View {
    @Query(sort: \DailyEntry.day) private var allEntries: [DailyEntry]

    @AppStorage(Keys.selectedPerson) private var person = 0
    @AppStorage(Keys.parentName0) private var name0 = Defaults.parentName0
    @AppStorage(Keys.parentName1) private var name1 = Defaults.parentName1
    @AppStorage(Keys.goalWater) private var goalWater = Defaults.goalWater
    @AppStorage(Keys.goalVeg) private var goalVeg = Defaults.goalVeg
    @AppStorage(Keys.goalSleep) private var goalSleep = Defaults.goalSleep
    @AppStorage(Keys.goalExercise) private var goalExercise = Defaults.goalExercise
    @AppStorage(Keys.goalSteps) private var goalSteps = Defaults.goalSteps

    @State private var anchor = Date.now
    @State private var chartMetric = ChartMetric.water

    private var week: DateInterval { anchor.weekInterval }
    private var days: [Date] { (0..<7).map { week.start.adding(days: $0) } }
    private var elapsedDays: Int { max(1, days.filter { $0 <= Date.now }.count) }

    private var title: String {
        let start = week.start.formatted(.dateTime.day().month(.abbreviated))
        let end = week.end.adding(days: -1).formatted(.dateTime.day().month(.abbreviated))
        return "\(start) – \(end)"
    }

    private func entries(for person: Int) -> [DailyEntry] {
        allEntries.filter { $0.person == person && $0.day >= week.start && $0.day < week.end }
    }

    private func entry(on day: Date) -> DailyEntry? {
        entries(for: person).first { $0.day == day.startOfDay }
    }

    var body: some View {
        let stats = WeekStats(entries: entries(for: person))

        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        PersonPicker()
                        DateStepper(
                            title: title,
                            canGoForward: Date.now >= week.end,
                            back: { anchor = anchor.adding(days: -7) },
                            forward: { anchor = anchor.adding(days: 7) }
                        )
                        dayStrip
                    }
                    .card()

                    goalsCard(stats)
                    chartCard
                    statsGrid(stats)
                    familyCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Week Summary")
        }
    }

    // MARK: Day strip

    private var dayStrip: some View {
        HStack {
            ForEach(days, id: \.self) { day in
                let dayEntry = entry(on: day)
                let isToday = day == Date.now.startOfDay
                VStack(spacing: 6) {
                    Text(day.formatted(.dateTime.weekday(.narrow)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ZStack {
                        Circle()
                            .fill(dayEntry?.hasData == true ? Color.accentColor.opacity(0.25) : Color.clear)
                        Circle()
                            .strokeBorder(isToday ? Color.accentColor : Color.secondary.opacity(0.3),
                                          lineWidth: isToday ? 2 : 1)
                        if dayEntry?.isTreatDay == true {
                            Text("🍰")
                        } else {
                            Text(day.formatted(.dateTime.day()))
                                .font(.footnote.monospacedDigit())
                        }
                    }
                    .frame(width: 36, height: 36)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Goals

    private func goalsCard(_ stats: WeekStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Goals reached").font(.headline)
                Spacer()
                Text("\(stats.loggedDays) days logged · \(stats.treatDays) 🍰")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            GoalRow(title: "Water ≥ \(goalWater.compact) L", icon: "drop.fill", color: .blue,
                    days: stats.days { $0.waterLiters >= goalWater }, total: elapsedDays)
            GoalRow(title: "Veggie meals ≥ \(goalVeg)", icon: "carrot.fill", color: .green,
                    days: stats.days { $0.vegMeals >= goalVeg }, total: elapsedDays)
            GoalRow(title: "Sleep ≥ \(goalSleep.compact) h", icon: "bed.double.fill", color: .indigo,
                    days: stats.days { $0.sleepHours >= goalSleep }, total: elapsedDays)
            GoalRow(title: "Exercise ≥ \(goalExercise) min", icon: "figure.run", color: .mint,
                    days: stats.days { $0.exerciseMinutes >= goalExercise }, total: elapsedDays)
            GoalRow(title: "Steps ≥ \(goalSteps.formatted())", icon: "shoeprints.fill", color: .teal,
                    days: stats.days { $0.steps >= goalSteps }, total: elapsedDays)
        }
        .card()
    }

    // MARK: Chart

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Metric", selection: $chartMetric) {
                ForEach(ChartMetric.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            Chart {
                ForEach(days, id: \.self) { day in
                    let dayEntry = entry(on: day)
                    BarMark(
                        x: .value("Day", day, unit: .day),
                        y: .value(chartMetric.rawValue, dayEntry.map(chartMetric.value) ?? 0)
                    )
                    .foregroundStyle(dayEntry?.isTreatDay == true ? Color.pink : chartMetric.color)
                    .cornerRadius(4)
                }
                RuleMark(y: .value("Goal", goal(for: chartMetric)))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.secondary)
                    .annotation(position: .top, alignment: .leading) {
                        Text("Goal").font(.caption2).foregroundStyle(.secondary)
                    }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                }
            }
            .frame(height: 180)

            Text("\(chartMetric.unit) per day · pink bars are treat days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .card()
    }

    private func goal(for metric: ChartMetric) -> Double {
        switch metric {
        case .water: return goalWater
        case .sleep: return goalSleep
        case .veggies: return Double(goalVeg)
        case .exercise: return Double(goalExercise)
        case .steps: return Double(goalSteps)
        }
    }

    // MARK: Stats grid

    private func statsGrid(_ stats: WeekStats) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatTile(icon: "drop.fill", color: .blue, title: "Water / day",
                     value: Format.value(stats.waterAverage, " L"))
            StatTile(icon: "carrot.fill", color: .green, title: "Veggie meals",
                     value: "\(stats.vegTotal)")
            StatTile(icon: "bed.double.fill", color: .indigo, title: "Sleep / night",
                     value: Format.value(stats.sleepAverage, " h"))
            StatTile(icon: "moon.stars.fill", color: .indigo, title: "Sleep quality",
                     value: Format.rating(stats.sleepQualityAverage))
            StatTile(icon: "fork.knife", color: .orange, title: "Carbs level",
                     value: stats.carbAverage.map(CarbLevel.label(for:)) ?? "—")
            StatTile(icon: "basket.fill", color: .red, title: "Fruit servings",
                     value: "\(stats.fruitTotal)")
            StatTile(icon: "takeoutbag.and.cup.and.straw.fill", color: .brown, title: "Sweets",
                     value: "\(stats.sweetsTotal)")
            StatTile(icon: "figure.run", color: .mint, title: "Exercise",
                     value: "\(stats.exerciseTotal) min")
            StatTile(icon: "shoeprints.fill", color: .teal, title: "Steps / day",
                     value: stats.stepsAverage.map { Int($0).formatted() } ?? "—")
            StatTile(icon: "leaf.fill", color: .green, title: "Mindfulness",
                     value: "\(stats.mindfulTotal) min")
            StatTile(icon: "face.smiling", color: .yellow, title: "Mood",
                     value: Format.rating(stats.moodAverage))
            StatTile(icon: "bolt.fill", color: .orange, title: "Energy",
                     value: Format.rating(stats.energyAverage))
            StatTile(icon: "waveform.path.ecg", color: .red, title: "Stress",
                     value: Format.rating(stats.stressAverage))
            StatTile(icon: "scalemass.fill", color: .purple, title: "Weight change",
                     value: Format.signedKg(stats.weightChange))
        }
    }

    // MARK: Family comparison

    private var familyCard: some View {
        let a = WeekStats(entries: entries(for: 0))
        let b = WeekStats(entries: entries(for: 1))

        return VStack(alignment: .leading, spacing: 12) {
            Text("Family this week").font(.headline)
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                GridRow {
                    Text("")
                    Text(name0).bold().gridColumnAlignment(.trailing)
                    Text(name1).bold().gridColumnAlignment(.trailing)
                }
                Divider()
                compareRow("Water / day", Format.value(a.waterAverage, " L"), Format.value(b.waterAverage, " L"))
                compareRow("Veggie meals", "\(a.vegTotal)", "\(b.vegTotal)")
                compareRow("Sleep / night", Format.value(a.sleepAverage, " h"), Format.value(b.sleepAverage, " h"))
                compareRow("Carbs", a.carbAverage.map(CarbLevel.label(for:)) ?? "—",
                           b.carbAverage.map(CarbLevel.label(for:)) ?? "—")
                compareRow("Exercise", "\(a.exerciseTotal) min", "\(b.exerciseTotal) min")
                compareRow("Mood", Format.rating(a.moodAverage), Format.rating(b.moodAverage))
                compareRow("Treat days", "\(a.treatDays)", "\(b.treatDays)")
                compareRow("Weight", Format.value(a.latestWeight, " kg"), Format.value(b.latestWeight, " kg"))
            }
            .font(.subheadline)
        }
        .card()
    }

    private func compareRow(_ title: String, _ first: String, _ second: String) -> some View {
        GridRow {
            Text(title).foregroundStyle(.secondary)
            Text(first).monospacedDigit()
            Text(second).monospacedDigit()
        }
    }
}

enum ChartMetric: String, CaseIterable, Identifiable {
    case water = "Water"
    case sleep = "Sleep"
    case veggies = "Veggies"
    case exercise = "Exercise"
    case steps = "Steps"

    var id: Self { self }

    var color: Color {
        switch self {
        case .water: return .blue
        case .sleep: return .indigo
        case .veggies: return .green
        case .exercise: return .mint
        case .steps: return .teal
        }
    }

    var unit: String {
        switch self {
        case .water: return "Liters"
        case .sleep: return "Hours"
        case .veggies: return "Meals with veggies"
        case .exercise: return "Minutes"
        case .steps: return "Steps"
        }
    }

    func value(_ entry: DailyEntry) -> Double {
        switch self {
        case .water: return entry.waterLiters
        case .sleep: return entry.sleepHours
        case .veggies: return Double(entry.vegMeals)
        case .exercise: return Double(entry.exerciseMinutes)
        case .steps: return Double(entry.steps)
        }
    }
}

struct GoalRow: View {
    let title: String
    let icon: String
    let color: Color
    let days: Int
    let total: Int

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: icon).foregroundStyle(color).frame(width: 22)
                Text(title).font(.subheadline)
                Spacer()
                Text("\(days)/\(total)").font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
            }
            ProgressView(value: Double(min(days, total)), total: Double(total))
                .tint(color)
        }
    }
}

struct StatTile: View {
    let icon: String
    let color: Color
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold().monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

extension View {
    func card() -> some View {
        padding()
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
