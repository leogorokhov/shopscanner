//
//  ShopScannerApp.swift
//  ShopScanner
//
//  Created by Leonid on 02.02.2023.
//

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
