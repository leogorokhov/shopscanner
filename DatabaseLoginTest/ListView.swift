////
////  ListView.swift
////  DatabaseLoginTest
////
////  Created by Leonid on 15.02.2023.
////
//
//import SwiftUI
//
//struct ListView: View {
//    @EnvironmentObject var dataManager: DataManager
//
//    var body: some View {
//        NavigationView {
//            List(dataManager.scans, id: \.id) { scan in
//                Text(scan.id + ", price: " + scan.price)
//            }
//            .navigationTitle("Scans")
//        }
//    }
//}
//
//struct ListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListView()
//            .environmentObject(DataManager())
//    }
//}
