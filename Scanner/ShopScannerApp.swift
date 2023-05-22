/*Данный код описывает основной входной файл приложения `ShopScannerApp` с использованием SwiftUI и Firebase.
 
 1. Импортируются необходимые модули: `SwiftUI` для работы с пользовательским интерфейсом и `FirebaseCore` для работы с Firebase.

 2. Аннотация `@main` указывает, что структура `ShopScannerApp` является точкой входа в приложение.

 3. В структуре `ShopScannerApp` объявляется свойство `vm`, которое является экземпляром `AppViewModel`. `@ObservedObject` используется для наблюдения за изменениями состояния этого объекта.

 4. Определяется вычисляемое свойство `body`, которое описывает главную сцену приложения.

 5. Внутри сцены создается `WindowGroup`, который является контейнером для содержимого окна приложения.

 6. Внутри `WindowGroup` создается экземпляр `ContentViewScanner`, который является представлением с функциональностью сканирования.

 7. Над `ContentViewScanner` применяется модификатор `.background(.black)`, который устанавливает черный фон для данного представления.

 8. Также над `ContentViewScanner` применяется модификатор `.environmentObject(vm)`, который внедряет экземпляр `AppViewModel` в окружение представления, чтобы его можно было использовать внутри этого представления и его дочерних представлений.

 9. Внутри `WindowGroup` определен `task`, который выполняется асинхронно. Внутри этого `task` происходит настройка Firebase с помощью `FirebaseApp.configure()`, чтобы приложение могло использовать сервисы Firebase.

 10. Затем вызывается метод `requestDataScannerAccessStatus()` на экземпляре `AppViewModel`, который выполняет запрос на доступ к сканеру данных.

 В целом, данный код создает и настраивает главную сцену приложения, включая представление с функциональностью сканирования, устанавливает черный фон для этого представления, внедряет экземпляр `AppViewModel` в окружение представления и выполняет настройку Firebase. Затем, приложение выполняет асинхронный запрос на доступ к сканеру данных.*/

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
