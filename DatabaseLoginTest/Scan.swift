//
//  Scan.swift
//  DatabaseLoginTest
//
//  Created by Leonid on 15.02.2023.
//

import SwiftUI

struct Scan: Identifiable, Equatable {
    var id: String
    var price: String
    var information: String
    var cbzh: String
    var energyprice: String
    var extraqr: Bool
    var extraqrcode: String
}

struct Cart: Identifiable, Equatable, Hashable {
    var id: String
    var price: String
    var information: String
    var cbzh: String
    var energyprice: String
    var extraqr: Bool
    var extraqrcode: String
    var quantity: Int
}
