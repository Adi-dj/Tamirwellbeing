import Foundation
import SwiftData

/// One day of tracking for one parent.
@Model
final class DailyEntry {
    /// Start of the tracked day.
    var day: Date
    /// 0 = first parent, 1 = second parent.
    var person: Int

    // Core metrics
    var waterLiters: Double = 0
    var vegMeals: Int = 0
    var sleepHours: Double = 0
    /// 0 = not set, 1 = low, 2 = moderate, 3 = high.
    var carbLevel: Int = 0

    // Extra metrics
    var fruitServings: Int = 0
    var sweets: Int = 0
    var exerciseMinutes: Int = 0
    var steps: Int = 0
    var mindfulMinutes: Int = 0
    /// 0 = not set, otherwise 1...5.
    var sleepQuality: Int = 0
    var mood: Int = 0
    var energy: Int = 0
    var stress: Int = 0

    var isTreatDay: Bool = false
    var weightKg: Double? = nil
    var notes: String = ""

    init(day: Date, person: Int) {
        self.day = Calendar.current.startOfDay(for: day)
        self.person = person
    }

    /// True when anything at all was recorded for this day.
    var hasData: Bool {
        waterLiters > 0 || vegMeals > 0 || sleepHours > 0 || carbLevel > 0
            || fruitServings > 0 || sweets > 0 || exerciseMinutes > 0 || steps > 0
            || mindfulMinutes > 0 || sleepQuality > 0 || mood > 0 || energy > 0
            || stress > 0 || isTreatDay || weightKg != nil || !notes.isEmpty
    }
}

enum CarbLevel {
    static let labels = ["—", "Low", "Moderate", "High"]

    static func label(for average: Double) -> String {
        switch average {
        case ..<0.5: return "—"
        case ..<1.67: return "Low"
        case ..<2.34: return "Moderate"
        default: return "High"
        }
    }
}

extension ModelContext {
    /// Returns the entry for a person on a given day, creating it if needed.
    func entry(for day: Date, person: Int) -> DailyEntry {
        let start = Calendar.current.startOfDay(for: day)
        let descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate { $0.day == start && $0.person == person }
        )
        if let existing = (try? fetch(descriptor))?.first {
            return existing
        }
        let created = DailyEntry(day: start, person: person)
        insert(created)
        return created
    }
}
