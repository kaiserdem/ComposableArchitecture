//
//  CounterView.swift
//  TestTCA
//
//  Created by Yaroslav Golinskiy on 12/05/2025.
//

import SwiftUI
import ComposableArchitecture


struct CounterSimpleView: View {
    
    let store: StoreOf<CounterSimpleReducer>

    var body: some View {
        WithViewStore(store, observe:  { $0 }) { viewStore in
            VStack {
                Text("\(viewStore.count)")
                HStack {
                    Button("+") {
                        store.send(.incredent)
                    }
                    .padding()
                    .border(.black)
                    
                    Button("-") {
                        store.send(.decrement)
                    }
                    .padding()
                    .border(.black)
                    
                }
            }
        }
    }
}

struct CounterSimpleReducer: Reducer {
    
    struct Stete: Equatable {
        var count: Int = 0
    }
    enum Action {
        case incredent, decrement
    }
    
    
    func reduce(into state: inout Stete, action: Action) -> Effect<Action> {
        switch action {
        case .incredent:
            state.count += 1
            return .none
        case .decrement:
            state.count -= 1
            return .none
        }
    }
}
