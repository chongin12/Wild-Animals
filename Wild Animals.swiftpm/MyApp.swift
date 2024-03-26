import SwiftUI
import SwiftData

@main
struct MyApp: App {
    @State var locationDataManager = LocationDataManager.shared
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(locationDataManager)
                .modelContainer(for: Animal.self)
        }
    }
}
