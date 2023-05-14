import SwiftUI
import Firebase

public class DataManager: ObservableObject {
    
    @Published var cartItems: [Cart] = []
    @Published var scans: [Scan] = []
    @Published var totalprice: Double = 0.0
    @Published var extraCodeValid: Bool? = nil
    
    func fetchScans(codenumbers: String, extracode: Bool) {
        print("extracode: \(extracode)")
        let db = Firestore.firestore()
        let ref = db.collection("Scans").document(codenumbers)
        ref.getDocument { [self] document, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let data = document?.data() else {
                error.map { print($0.localizedDescription) }
                return
            }
            
            let id = data["id"] as? String ?? ""
            guard !id.isEmpty else {
                print("Empty id")
                return
            }
            let price = data["price"] as? String ?? ""
            let information = data["information"] as? String ?? ""
            let cbzh = data["cbzh"] as? String ?? ""
            let energyprice = data["energyprice"] as? String ?? ""
            let extraqr = data["extraqr"] as? Bool ?? false
            let extraqrcode = data["extraqrcode"] as? String ?? ""
            
            if let existingScanIndex = scans.firstIndex(where: { $0.id == id }) {
                print("Scan already exists: \(scans[existingScanIndex])")
                return
            }
            
            let scan = Scan(id: id, price: price, information: information, cbzh: cbzh, energyprice: energyprice, extraqr: extraqr, extraqrcode: extraqrcode)
            self.scans.append(scan)
            print(scan)
        }
    }
    
    func checkExtraQRCode(_ scannedCode: String, for extraqrcode: String) {
        if scannedCode == extraqrcode {
            extraCodeValid = true
        } else {
            extraCodeValid = false
        }
    }
    
    func addToCart(scan: Scan) {
        let item = Cart(id: scan.id, price: scan.price, information: scan.information, cbzh: scan.cbzh, energyprice: scan.energyprice, extraqr: scan.extraqr, extraqrcode: scan.extraqrcode)
        self.cartItems.append(item)
        totalprice += Double(item.price) ?? 0.0
        print("total price: \(totalprice)")
    }


    func deleteFromCart(cartItem: Cart) {
        if let index = self.cartItems.firstIndex(of: cartItem) {
            totalprice -= Double(cartItem.price) ?? 0.0
            self.cartItems.remove(at: index)
        }
    }
    
}
