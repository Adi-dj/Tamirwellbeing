import Foundation

/// UserDefaults keys used with @AppStorage.
enum Keys {
    static let selectedPerson = "selectedPerson"
    static let parentName0 = "parentName0"
    static let parentName1 = "parentName1"
    static let goalWater = "goalWater"
    static let goalVeg = "goalVeg"
    static let goalSleep = "goalSleep"
    static let goalExercise = "goalExercise"
    static let goalSteps = "goalSteps"
}

enum Defaults {
    static let parentName0 = "Parent 1"
    static let parentName1 = "Parent 2"
    static let goalWater = 2.5
    static let goalVeg = 3
    static let goalSleep = 7.0
    static let goalExercise = 30
    static let goalSteps = 8000
}

extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// The calendar week containing this date (first weekday follows the device locale).
    var weekInterval: DateInterval {
        Calendar.current.dateInterval(of: .weekOfYear, for: self)
            ?? DateInterval(start: startOfDay, duration: 7 * 24 * 3600)
    }
}

extension Double {
    /// "2.5" or "3" — drops a trailing ".0".
    var compact: String {
        formatted(.number.precision(.fractionLength(0...1)))
    }
}
