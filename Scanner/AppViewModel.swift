import AVKit
import Foundation
import SwiftUI
import VisionKit

enum ScanType: String {
    case barcode, text
}

enum DataScannerAccessStatusType {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

@MainActor
final class AppViewModel: ObservableObject {
    
    @Published var dataScannerAccessStatus: DataScannerAccessStatusType = .notDetermined
    @Published var recognizedItems: [RecognizedItem] = [] {
        didSet { fetchLastScanned() }
    }
    @Published var scanType: ScanType = .barcode
    @Published var textContentType: DataScannerViewController.TextContentType?
    @Published var recognizesMultipleItems = true
    @ObservedObject var dataManager = DataManager()
    
    @Published var shouldShowQRScanner = false
    @Published var isQRCodeValid = false

    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        scanType == .barcode ? .barcode() : .text(textContentType: textContentType)
    }
    var headerText: String {
        if recognizedItems.isEmpty {
            return "Scanning \(scanType.rawValue)"
        } else {
            return "Recognized item:"
        }
    }
      var dataScannerViewId: Int {
        var hasher = Hasher()
        if let textContentType {
            hasher.combine(textContentType)
        }
        return hasher.finalize()
    }
    private var isScannerAvailable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    func requestDataScannerAccessStatus() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
        case .restricted, .denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            } else {
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
        default: break
        }
    }

    func fetchLastScanned() {
        guard
            let lastScanned = recognizedItems.last,
            case let .barcode(info) = lastScanned,
            let codenumbers = info.payloadStringValue
        else {
            return
        }
        for scan in dataManager.scans {
            if codenumbers == scan.extraqrcode {
                print("Коды совпадают")
                print("Совместимый код: \(codenumbers)")
                isQRCodeValid = true
                dataManager.fetchScans(codenumbers: codenumbers, extracode: isQRCodeValid)
                break
            }
        }
            
        dataManager.fetchScans(codenumbers: codenumbers, extracode: isQRCodeValid)
        print("Scanned barcode: \(codenumbers)") // Выводим номер штрих-кода в консоль
    }
}
