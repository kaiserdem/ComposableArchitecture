import SwiftUI
import ComposableArchitecture

// @main - атрибут, який вказує, що це головна точка входу в додаток
@main
struct TestTCAApp: App {
    var body: some Scene {                            /// Визначає структуру сцени додатку
        
        WindowGroup {                                 /// WindowGroup - контейнер для вікна додатку
            
//            MovieView(store: Store(                   /// Store - контейнер, який зберігає стан та керує логікою для конкретного модуля/екрану
//                initialState: MovieReducer.State(),   /// створюємо початковий стан
//                reducer: { MovieReducer() }           /// reducer - функція, яка обробляє дії та оновлює стан
//            ))
            
//            StrongFirstView()
//              StrongView1()
            
//            CounterSimpleView(store: Store(initialState: CounterSimpleReducer.State(), reducer: {
//                CounterSimpleReducer()
//            }))
            
//            CounterLoadingView(store: Store(initialState: CounterLoadingReducer.State(),
//                                            reducer: {
//                CounterLoadingReducer(counterEffect: CounterEffect())
//            }))
            
//            CounterStepResetErrorView(store: Store(initialState: CounterStepEReducer.State(), reducer: {
//                CounterStepEReducer(effect: CounterStepEEffect())
//            }))
            
//            CounterHistoryView(store: Store(initialState: CounterHistoryReducer.State(), reducer: {
//                CounterHistoryReducer(effect: CounterHistoryEffect())
//            }))
            
            CounterView(store: Store(initialState: CounterReducer1.State(), reducer: {
                CounterReducer1(effect: CounterEffect1())
            }))
        }
    }
}
/*
 Я створюю головний файл додатку MovieView, який використовує архітектуру TCA.
 Спочатку імпортую необхідні фреймворки.
 Потім створюю структуру додатку з атрибутом @main, щоб вказати точку входу.
 У body я створюю WindowGroup, який містить наш головний view - MovieView.
 Для MovieView я створюю Store, який буде зберігати стан додатку та обробляти всі дії через reducer.
 */
