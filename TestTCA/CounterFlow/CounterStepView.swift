//
//  CounterStepView.swift
//  TestTCA
//
//  Created by Yaroslav Golinskiy on 25/05/2025.
//

import ComposableArchitecture
import SwiftUI

struct CounterStepView: View {
    
    let store: StoreOf<CounterStepReducer>
    
    var body: some View {
        
        WithViewStore(store, observe: {$0}) { viewStore in
            ZStack {
                
                VStack {
                    Spacer()
                    if viewStore.isLoading {
                        ProgressView()
                    }
                    Spacer()
                    Spacer()
                }
                
                VStack {
                    Picker("Step", selection: viewStore.binding(
                        get: \.step, send: { .setStep($0) }
                    )) {
                        Text("1").tag(1)
                        Text("5").tag(5)
                        Text("10").tag(10)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    
                    Text("\(viewStore.counter)")
                        .font(.title)
                    
                    HStack {
                        Button("+") {
                            viewStore.send(.incrementTap)
                        }
                        .padding()
                        .border(.black)
                        
                        Button("-") {
                            viewStore.send(.decrementTap)
                        }
                        .padding()
                        .border(.black)
                    }
                }
            }
        }
    }
}

struct CounterStepReducer: Reducer {
    
    struct State: Equatable {
        var counter: Int = 0
        var isLoading: Bool = false
        var step: Int = 1
    }
    
    enum Action {
        case incrementTap
        case decrementTap
        case incrementAsync(Int)
        case decrementAsync(Int)
        case setStep(Int)
    }
    
    let effect: CounterStepEffectProtocol
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case .incrementTap:
            state.isLoading = true
            let currentCount = state.counter
            let step = state.step
            return Effect.run { send in
                do {
                    let newCount =  try await effect.increment(currentCount,step)
                    await send(.incrementAsync(newCount))
                } catch {
                    await send(.incrementAsync(currentCount))
                }
            }
            
        case .decrementTap:
            state.isLoading = true
            let currentCount = state.counter
            let step = state.step
            return Effect.run { send in
                do {
                    let newCount =  try await effect.increment(currentCount,step)
                    await send(.decrementAsync(newCount))
                } catch {
                    await send(.decrementAsync(currentCount))
                }
            }
            
        case .incrementAsync(let value):
            state.isLoading = false
            state.counter = value
            return .none
            
        case .decrementAsync(let value):
            state.isLoading = false
            state.counter = value
            return .none
            
        case .setStep(let value):
            state.step = value
            return .none
            
        }
    }
}

protocol CounterStepEffectProtocol {
    func increment(_ currentCount: Int,_ step: Int) async throws -> Int
    func decrement(_ currentCount: Int,_ step: Int) async throws -> Int
}

struct CounterStepEffect: CounterStepEffectProtocol {
    func increment(_ currentCount: Int,_ step: Int) async throws -> Int {
        try await Task.sleep(for: .seconds(2))
        return currentCount + step
    }
    func decrement(_ currentCount: Int,_ step: Int) async throws -> Int {
        try await Task.sleep(for: .seconds(2))
        return currentCount - step
    }
}
