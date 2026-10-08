import Foundation

/// Aggregates for one parent over one week.
struct WeekStats {
    let entries: [DailyEntry]

    private func average(_ values: [Double]) -> Double? {
        values.isEmpty ? nil : values.reduce(0, +) / Double(values.count)
    }

    private func ratingAverage(_ keyPath: KeyPath<DailyEntry, Int>) -> Double? {
        average(entries.map { Double($0[keyPath: keyPath]) }.filter { $0 > 0 })
    }

    var loggedDays: Int { entries.filter(\.hasData).count }
    var treatDays: Int { entries.filter(\.isTreatDay).count }

    var waterAverage: Double? { average(entries.map(\.waterLiters).filter { $0 > 0 }) }
    var vegTotal: Int { entries.reduce(0) { $0 + $1.vegMeals } }
    var vegAverage: Double? { average(entries.filter(\.hasData).map { Double($0.vegMeals) }) }
    var sleepAverage: Double? { average(entries.map(\.sleepHours).filter { $0 > 0 }) }
    var carbAverage: Double? { ratingAverage(\.carbLevel) }
    var fruitTotal: Int { entries.reduce(0) { $0 + $1.fruitServings } }
    var sweetsTotal: Int { entries.reduce(0) { $0 + $1.sweets } }
    var exerciseTotal: Int { entries.reduce(0) { $0 + $1.exerciseMinutes } }
    var stepsAverage: Double? { average(entries.map { Double($0.steps) }.filter { $0 > 0 }) }
    var mindfulTotal: Int { entries.reduce(0) { $0 + $1.mindfulMinutes } }
    var sleepQualityAverage: Double? { ratingAverage(\.sleepQuality) }
    var moodAverage: Double? { ratingAverage(\.mood) }
    var energyAverage: Double? { ratingAverage(\.energy) }
    var stressAverage: Double? { ratingAverage(\.stress) }

    /// Change between the first and last weigh-in of the week.
    var weightChange: Double? {
        let weights = entries.sorted { $0.day < $1.day }.compactMap(\.weightKg)
        guard let first = weights.first, let last = weights.last, weights.count > 1 else { return nil }
        return last - first
    }

    var latestWeight: Double? {
        entries.sorted { $0.day < $1.day }.compactMap(\.weightKg).last
    }

    func days(where condition: (DailyEntry) -> Bool) -> Int {
        entries.filter(condition).count
    }
}

enum Format {
    static func value(_ value: Double?, _ suffix: String = "") -> String {
        value.map { "\($0.compact)\(suffix)" } ?? "—"
    }

    static func rating(_ value: Double?) -> String {
        value.map { "\($0.compact) / 5" } ?? "—"
    }

    static func signedKg(_ value: Double?) -> String {
        guard let value else { return "—" }
        return value.formatted(.number.precision(.fractionLength(1)).sign(strategy: .always())) + " kg"
    }
}
