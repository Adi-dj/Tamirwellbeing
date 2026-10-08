import SwiftUI
import SwiftData

@main
struct TamirWellbeingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: DailyEntry.self)
    }
}
