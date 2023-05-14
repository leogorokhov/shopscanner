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

struct Cart: Identifiable, Equatable{
    var index = UUID()
    var id: String
    var price: String
    var information: String
    var cbzh: String
    var energyprice: String
    var extraqr: Bool
    var extraqrcode: String

}


