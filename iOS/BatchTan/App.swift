import SwiftUI

@main
struct BatchTanApp: App {
    @StateObject private var store = BatchTanStore()
    @StateObject private var purchases = PurchaseManager()
    @AppStorage("batchtan_haptics_enabled") private var hapticsEnabled: Bool = true

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .environmentObject(purchases)
                .preferredColorScheme(.light)
                .onAppear {
                    BTHaptics.enabled = hapticsEnabled
                }
        }
    }
}
