import SwiftUI

@main
struct MyApp: App {
    @State var locationDataManager = LocationDataManager.shared
    @State var animalStorage = AnimalStorage()
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(locationDataManager)
                .environment(animalStorage)
        }
    }
}

