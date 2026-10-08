import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "checklist") }
            WeekView()
                .tabItem { Label("Week", systemImage: "chart.bar.fill") }
            WeightView()
                .tabItem { Label("Weight", systemImage: "scalemass.fill") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

/// Segmented switch between the two parents, shared by all tabs.
struct PersonPicker: View {
    @AppStorage(Keys.selectedPerson) private var person = 0
    @AppStorage(Keys.parentName0) private var name0 = Defaults.parentName0
    @AppStorage(Keys.parentName1) private var name1 = Defaults.parentName1

    var body: some View {
        Picker("Parent", selection: $person) {
            Text(name0).tag(0)
            Text(name1).tag(1)
        }
        .pickerStyle(.segmented)
    }
}

/// "‹  Title  ›" header used to move between days or weeks.
struct DateStepper: View {
    let title: String
    let canGoForward: Bool
    let back: () -> Void
    let forward: () -> Void

    var body: some View {
        HStack {
            Button(action: back) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(title).font(.headline)
            Spacer()
            Button(action: forward) {
                Image(systemName: "chevron.right")
            }
            .disabled(!canGoForward)
        }
        .buttonStyle(.borderless)
    }
}
