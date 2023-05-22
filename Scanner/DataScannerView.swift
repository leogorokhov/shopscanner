/*Данный код определяет структуру `DataScannerView`, которая представляет сканер данных в виде контроллера пользовательского интерфейса в SwiftUI.
 
 1. В структуре определены следующие свойства:
    - `recognizedItems`: Привязка (`@Binding`) к массиву распознанных элементов.
    - `recognizedDataType`: Тип распознаваемых данных сканера.

 2. Метод `makeUIViewController(context:)` создает экземпляр `DataScannerViewController` и настраивает его параметры, такие как тип распознаваемых данных, уровень качества, возможность распознавания нескольких элементов, наличие инструкций и подсветки элементов. Затем он возвращает этот экземпляр.

 3. Метод `updateUIViewController(_:context:)` устанавливает делегата `DataScannerViewController` в соответствии с контекстом и запускает сканирование с помощью вызова `startScanning()`. Этот метод вызывается при обновлении представления.

 4. Метод `makeCoordinator()` создает экземпляр класса `Coordinator`, который служит делегатом для `DataScannerViewController` и управляет обработкой событий сканера данных. Он также использует привязку к `recognizedItems` для доступа к массиву распознанных элементов.

 5. Статический метод `dismantleUIViewController(_:coordinator:)` останавливает сканирование, вызывая `stopScanning()` у экземпляра `DataScannerViewController`. Этот метод вызывается при удалении представления.

 6. Внутри класса `Coordinator` определены методы делегата `DataScannerViewControllerDelegate`, которые реагируют на различные события сканера данных:
    - `dataScanner(_:didTapOn:)`: Вызывается при нажатии на распознанный элемент. Выводит информацию о нажатом элементе в консоль.
    - `dataScanner(_:didAdd:allItems:)`: Вызывается при добавлении новых распознанных элементов. Генерирует тактильную отзывчивость и добавляет новые элементы в массив `recognizedItems`. Выводит информацию о добавленных элементах в консоль.
    - `dataScanner(_:didRemove:allItems:)`: Вызывается при удалении распознанных элементов. Обновляет массив `recognizedItems`, удаляя удаленные элементы из него. Выводит информацию о удаленных элементах в консоль.
    - `dataScanner(_:becameUnavailableWithError:)`: Вызывается при недоступности сканера данных с ошибкой. Выводит информацию об ошибке в консоль.

 Общая задача `DataScannerView` заключается в связывании сканера данных с SwiftUI и обработке событий, связанных с распознав

 анием элементов и управлением массивом распознанных элементов.*/
import Foundation
import SwiftUI
import VisionKit

struct DataScannerView: UIViewControllerRepresentable {
    
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    
    func makeUIViewController(context: Context) -> DataScannerViewController{
        let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate{
        
        @Binding var recognizedItems: [RecognizedItem]
        
        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("didTapOn \(item)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            recognizedItems.append(contentsOf: addedItems)
            print("didAddItems \(addedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = recognizedItems.filter { item in
                removedItems.contains(where: {$0.id == item.id})
            }
            print("didRemovedItems \(removedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("became unavailable with error \(error.localizedDescription)")
        }
    }
}
