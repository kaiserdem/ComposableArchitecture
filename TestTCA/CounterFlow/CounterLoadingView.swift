//
//  CounterLoadingView.swift
//  TestTCA
//
//  Created by Yaroslav Golinskiy on 12/05/2025.
//

import SwiftUI
import ComposableArchitecture
import Dependencies

                                  
struct CounterLoadingView: View {                             // Основний View, що відображає лічильник і прогрес
   
    let store: StoreOf<CounterLoadingReducer>                 // Передаємо store для звʼязку з редюсером
    
    var body: some View {
       
        WithViewStore(store, observe: { $0 }) { viewSore in   // `WithViewStore` — це обгортка для підписки на стан і передачі дій
            VStack {
               
                if viewSore.isLoading  {
                    ProgressView()
                }
                Text("\(viewSore.state.count)")
                
                HStack {
                    Button("+") {
                        viewSore.send(.incrementTapped)
                    }
                    Button("-") {
                        viewSore.send(.decrementTapped)
                    }
                }
            }
        }
    }
}


struct CounterLoadingReducer: Reducer {                        // Редюсер — логіка роботи з станом та асинхронними ефектами
    
    struct State: Equatable {
        var count: Int = 0
        var isLoading: Bool = false
    }
    
    enum Action {
        case incrementTapped
        case decrementTapped
        case incrementResponse(Int)
        case decrementResponse(Int)
    }
    
   // @Dependency(\.counterEffect) var counterEffect              // Впроваджуємо залежність: `counterEffect`
    let counterEffect: CounterEffectProtocol

    func reduce(into state: inout State, action: Action) -> Effect<Action> {     // Функція, що обробляє стан у відповідь на дії

        switch action {
        case .incrementTapped:
            state.isLoading = true
            let currentCount = state.count
           
            return .run { send in                                // Запускаємо асинхронний ефект для Increment
                do {
                    let value = try await counterEffect.incremet(currentCount: currentCount)   // Викликаємо асинхронну функцію, що поверне число
                    await send(.incrementResponse(value))            // Відправляємо відповідь у стан
                } catch {
                    await send(.incrementResponse(currentCount))
                }
            }
            
        case .decrementTapped:
            state.isLoading = true
            let currentCount = state.count
            
            return .run { send in
                do {
                    let value = try  await counterEffect.decrement(currentCount: currentCount)
                    await send(.decrementResponse(value))
                } catch {
                    await send(.decrementResponse(currentCount))
                }
            }
            
        case let .incrementResponse(value):
            state.count = value
            state.isLoading = false
            return .none
            
        case let .decrementResponse(value):
            state.count = value
            state.isLoading = false
            return .none
        }
    }
}

protocol CounterEffectProtocol {
    func incremet(currentCount: Int) async throws -> Int
    func decrement(currentCount: Int) async throws -> Int
}

struct CounterEffect: CounterEffectProtocol {
    
    func incremet(currentCount: Int) async throws -> Int {
        try await Task.sleep(for: .seconds(1))
        return  currentCount + 1
    }
    
    func decrement(currentCount: Int) async throws -> Int {
        try await Task.sleep(for: .seconds(1))
        return currentCount - 1
    }
}

//struct CounterEffect {                                          // Екземпляр для асинхронних ефектів — реалізація поведінки
//    var incremet: @Sendable () async throws -> Int
//    var decrement: @Sendable () async throws -> Int             // Це кложур, що повертають число по `async/await`
//    
//    static let live = Self (                                    // Стандартна "живий" реалізація — із імітацією затримки
//        incremet: {
//            try await Task.sleep(for: .seconds(1))
//            return 1
//        },
//        decrement: {
//            try await Task.sleep(for: .seconds(1))
//            return -1
//        }
//    )
//}
//
//private enum CounterEffectKey: DependencyKey {                   // Задаємо ключ для Dependency — щоб системно зберігати і отримувати
//    static var liveValue = CounterEffect.live                    // Вміст залежності
//}
//
//extension DependencyValues {                                     // Додаємо в DependencyValues розширення для доступу до
//    var counterEffect: CounterEffect {
//        get { self[CounterEffectKey.self] }
//        set { self[CounterEffectKey.self] = newValue }
//    }
//}


