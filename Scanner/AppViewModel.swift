/*Данный код описывает класс `AppViewModel`, который является моделью представления приложения и содержит логику и состояние, связанные с сканированием данных.
 
 1. Определяются перечисления `ScanType` и `DataScannerAccessStatusType`, которые представляют тип сканирования (штрих-код или текст) и статус доступа к сканеру данных соответственно.

 2. Объявляется класс `AppViewModel`, который является финальным (не может быть подклассом) и наследуется от `ObservableObject` для поддержки наблюдаемых свойств.

 3. Внутри класса объявляются следующие свойства с аннотацией `@Published`, которые являются наблюдаемыми и могут автоматически обновлять связанные представления при изменении их значений:
    - `dataScannerAccessStatus`: Тип доступа к сканеру данных.
    - `recognizedItems`: Массив распознанных элементов.
    - `scanType`: Тип сканирования (штрих-код или текст).
    - `textContentType`: Тип содержимого текста.
    - `recognizesMultipleItems`: Флаг, указывающий, можно ли распознавать несколько элементов.
    - `dataManager`: Экземпляр класса `DataManager`, который отвечает за управление данными.

 4. Также объявляются следующие свойства:
    - `shouldShowQRScanner`: Флаг, указывающий, нужно ли отображать сканер QR-кода.
    - `isQRCodeValid`: Флаг, указывающий, является ли QR-код действительным.
    - `recognizedDataType`: Тип распознаваемых данных в сканере (штрих-код или текст).
    - `headerText`: Текст заголовка, который зависит от наличия распознанных элементов.
    - `dataScannerViewId`: Идентификатор представления сканера данных.
    - `isScannerAvailable`: Флаг, указывающий, доступен ли сканер данных.

 5. В классе определены следующие методы:
    - `requestDataScannerAccessStatus()`: Асинхронно запрашивает статус доступа к камере и устанавливает соответствующий статус доступа к сканеру данных.
    - `fetchLastScanned()`: Извлекает последний распознанный элемент, проверяет его на соответствие с другими элементами и выполняет соответствующие операции с помощью экземпляра `dataManager`. Затем выводит номер штрих-кода в консоль.

 Общая задача `AppViewModel` состоит в управлении доступом к сканеру данных, обработке распознаваемых элементов и взаимодействии с `DataManager` для получения и обновления данных.*/
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
