import SwiftUI
import FirebaseCore

@main
struct ShopScannerApp: App {
    
    @ObservedObject private var vm = AppViewModel()
    var body: some Scene {
        WindowGroup {
            ContentViewScanner()
                .background(.black)
                .environmentObject(vm)
                .task {
                    FirebaseApp.configure()
                    await vm.requestDataScannerAccessStatus()
                }
        }
    }
}
