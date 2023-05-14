import SwiftUI
import VisionKit
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentViewScanner: View {
    @EnvironmentObject var vm: AppViewModel
    @State var presentSheet = true
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    let captureDevice = AVCaptureDevice.default(for: .video)
    @State private var isTorchOn = false
    @State private var isEmpty = true
    @State private var lastScannedBarcode: String = ""
    @State private var selectedScan: Scan?
    @State private var isShowingDialog = false
    
    func generateQR() -> Data? {
        let filter = CIFilter.qrCodeGenerator()
        let text = String(Int.random(in: 1000000000...9999999999))
        guard let data = text.data(using: .ascii, allowLossyConversion: false) else { return nil }
        filter.message = data
        guard let ciimage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciimage.transformed(by: transform)
        let uiimage = UIImage(ciImage: scaledCIImage)
        return uiimage.pngData()!
    }
    
   
    func toggleTorch() {
        do {
            try captureDevice?.lockForConfiguration()
            if captureDevice?.torchMode == .on {
                captureDevice?.torchMode = .off
                isTorchOn = false
            } else {
                try captureDevice?.setTorchModeOn(level: 1.0)
                isTorchOn = true
            }
            captureDevice?.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    private var bottomContainerView: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack(alignment: .center) {
                        Button(action: {
                            toggleTorch()
                        }) {
                            Image(systemName: "flashlight.off.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing)
                        Spacer()
                        NavigationLink {
                            cartView
                        } label: {
                            Label("Корзина", systemImage: "cart") .labelStyle(.iconOnly)
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing)
                    }
                    .padding(.leading)
                    .padding(.top)
                }
                ScrollView {
                    if vm.dataManager.scans.isEmpty {
                        Text("Отсканируйте первый товар")
                            .font(.title3)
                            .padding([.leading, .trailing, .top])
                            .foregroundColor(.gray)
                    } else {
                        ForEach(vm.dataManager.scans) { scan in
                            VStack{
                                LazyVStack(alignment: .leading, spacing: 20) {
                                    Text(scan.id)
                                        .font(.system(size: 20, weight: .bold))
                                    Text(scan.information)
                                    Text("БЖУ: " + scan.cbzh)
                                        .font(.caption)
                                    Text("Энергетическая ценность: " + scan.energyprice)
                                        .font(.caption)
                                }
                                .padding(.bottom, 10)
                                HStack {
                                    Text("Цена ")
                                        .font(.system(size: 25, weight: .bold))
                                    Spacer()
                                    Text(scan.price)
                                        .font(.title)
                                    Text("₽/шт")
                                        .font(.title)
                                }.padding(.trailing)
                                    .padding(.bottom, 30)
                                Button(action: {
                                    checkExtraQRCode(scan: scan)
                                }) {
                                    Text("Добавить в корзину")
                                }
                                .alert(isPresented: $showAlert) {
                                    Alert(title: Text(alertTitle),
                                          message: Text(alertMessage),
                                          dismissButton: .default(Text("OK"), action: {
                                        if scan.extraqr {
                                            vm.shouldShowQRScanner = true
                                        }
                                    }))
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.bottom, 30)
                            }
                            .padding([.leading, .trailing, .top])
                            .background(Color(UIColor.systemGray5), in: RoundedRectangle(cornerRadius: 30))
                        }.padding(.all)
                    }
                }
            }
        }
        .navigationTitle("Отсканированные товары")
    }
    
    func handleScannedCode() {
        if let scan = selectedScan,
           let lastScanned = vm.recognizedItems.last {
            switch lastScanned {
            case let .barcode(info):
                if let scannedCode = info.payloadStringValue {
                    vm.dataManager.checkExtraQRCode(scannedCode, for: scan.extraqrcode)
                    showAlert = true
                    if vm.dataManager.extraCodeValid == true {
//                        vm.dataManager.addToCart(scan: scan)
                        alertTitle = "Дополнительный код верный"
                        alertMessage = "Дополнительный код верный, товар добавлен в корзину"
                    } else {
                        alertTitle = "Требуется QR-код"
                        alertMessage = "Отсканируйте дополнительный QR-код, чтобы добавить товар в корзину"
                    }
                    selectedScan = nil
                }
            default:
                break
            }
        }
    }
    
    func checkExtraQRCode(scan: Scan) {
        if scan.extraqr {
            showAlert = true
            alertTitle = "Требуется QR-код"
            alertMessage = "Отсканируйте дополнительный QR-код, чтобы добавить товар в корзину"
            selectedScan = scan
            handleScannedCode()
        } else {
            vm.dataManager.addToCart(scan: scan)
            showAlert = true
            alertTitle = "Успешно добавлено в корзину"
            alertMessage = "Продукт добавлен в корзину"
        }
        
        if let extraCodeValid = vm.dataManager.extraCodeValid {
            showAlert = true
            if extraCodeValid {
                vm.dataManager.addToCart(scan: scan)
                alertTitle = "Дополнительный код верный"
                alertMessage = "Дополнительный код верный, товар добавлен в корзину"
            } else {
                alertTitle = "Требуется QR-код"
                alertMessage = "Отсканируйте дополнительный QR-код, чтобы добавить товар в корзину"
            }
        }
    }
    
    var body: some View {
        switch vm.dataScannerAccessStatus {
        case .scannerAvailable:
            mainView
        case .cameraNotAvailable:
            Text("Your device doesn't have a camera")
        case .scannerNotAvailable:
            Text("Your device doesn't have support for scanning barcode with this app")
        case .cameraAccessNotGranted:
            Text("Please provide access to the camera in settings")
        case .notDetermined:
            Text("Requesting camera access")
        }
    }
    
    private var cartView: some View {
        NavigationStack{
            VStack{
                ScrollView{
                    if vm.dataManager.cartItems.isEmpty {
                        Text("Корзина пуста.")
                            .font(.title3)
                            .padding([.leading, .trailing, .top])
                            .foregroundColor(.gray)
                    } else {
                        cartItemView
                    }
                    
                }
                Divider()
                VStack{
                    HStack{
                        Text("Итоговая стоимость")
                            .font(.title3)
                        Spacer()
                        Text(String(format: "%.2f", vm.dataManager.totalprice) + "₽")
                    } .padding(.all)
                    NavigationLink {
                        paymentView
                    } label: {
                        Label("Перейти к оплате", systemImage: "card") .labelStyle(.titleOnly)
                            .font(.system(size: 20))
                            .padding(.all)
                            .foregroundColor(.white)
                            .background(Color(UIColor.systemBlue), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .navigationTitle("Корзина")
            }
    
    private var paymentView: some View {
        NavigationStack{
            ZStack{
                Image(uiImage: UIImage(data: generateQR()!)!)
                                    .resizable()
                                    .frame(width: 200, height: 200)
            }
        }
        .navigationTitle("Отсканируйте QR-код на кассе")
    }
    
    private var cartItemView: some View {
        ForEach(vm.dataManager.cartItems, id: \.index) { cartItem in
            ZStack {
                VStack {
                    HStack {
                        Text(cartItem.id)
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        Button(action: {
                            isShowingDialog = true
                        }) {
                            Label("Удалить", systemImage: "trash")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                        }
                        .confirmationDialog(
                            Text("Вы действительно хотите удалить товар из корзины?"),
                            isPresented: $isShowingDialog) {
                                Button("Удалить", role: .destructive) {
                                    vm.dataManager.deleteFromCart(cartItem: cartItem)
                                }
                        }
                    }.padding([.trailing, .bottom])
                    HStack {
                        Text("Цена")
                            .font(.system(size: 25, weight: .bold))
                        Spacer()
                        Text(cartItem.price)
                            .font(.title)
                        Text("₽/шт")
                            .font(.title)
                    }.padding(.trailing)
                        .padding(.bottom)

                }
                .padding(.all)
                .background(Color(UIColor.systemGray5), in: RoundedRectangle(cornerRadius: 30))
            }
        }
        .padding(.all)
    }




    private var mainView: some View {
            DataScannerView(
                recognizedItems: $vm.recognizedItems,
                recognizedDataType: vm.recognizedDataType)
            .background {Color.gray.opacity(0.3)}
            .ignoresSafeArea()
            .id(vm.dataScannerViewId)
            .sheet(isPresented: .constant(true)) {
                    bottomContainerView
                        .backgroundStyle(.thinMaterial)
                        .presentationDetents([.large, .medium, .fraction(0.25)])
                        .presentationDragIndicator(.visible)
                        .interactiveDismissDisabled()
                        .onReceive(vm.recognizedItems.publisher.last().compactMap { $0 }) { _ in
                            handleScannedCode()
                        }
            }
    }
    
    private var headerView: some View {
        VStack {
            HStack{
                Text(vm.headerText)
                    .padding()
            }
        }.padding(.horizontal)
    }
}
