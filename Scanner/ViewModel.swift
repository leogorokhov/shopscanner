import SwiftUI

struct ViewModel: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showAlert = false
    @State private var extraQRCode = ""
    
    func checkExtraQRCode(scan: Scan) {
        if scan.extraqr {
            showAlert = true
            extraQRCode = scan.extraqrcode
        } else {
            dataManager.addToCart(scan: scan)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Добавлено в корзину")
            }
        }
    }
    
    struct ViewModel_Previews: PreviewProvider {
        static var previews: some View {
            ViewModel()
                .environmentObject(DataManager())
                .environmentObject(AppViewModel())
        }
    }
}
