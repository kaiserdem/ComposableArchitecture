//
//  CounterStepErrorView.swift
//  TestTCA
//
//  Created by Yaroslav Golinskiy on 25/05/2025.
//

import ComposableArchitecture
import SwiftUI

struct CounterStepResetErrorView: View {
    
    let store: StoreOf<CounterStepEReducer>
    
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
                    
                    Picker("", selection: viewStore.binding(
                        get: \.step,
                        send: { .setStep($0)}
                    )) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                    }
                    .padding()
                    .pickerStyle(.segmented)
                    
                    Text("\(viewStore.counter)")
                        .font(.title)
                    VStack {
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
                        Button("Reset All") {
                            viewStore.send(.reset)
                        }
                        .padding()
                        .border(.black)
                    }
                }
            }
            .alert(isPresented: viewStore.binding(
                get: \.showErrorAlert,
                send: { .setShowErrorAlert($0) }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewStore.errorMessage ?? "Сталася помилка"),
                    dismissButton: .default(Text("OK")) {
                        viewStore.send(.setShowErrorAlert(false))
                    }
                )
            }
        }
    }
}

struct CounterStepEReducer: Reducer {
    
    struct State: Equatable {
        var counter: Int = 0
        var isLoading: Bool = false
        var step: Int = 1
        var showErrorAlert: Bool = false
        var errorMessage: String? = nil
    }
    
    enum Action {
        case incrementTap
        case decrementTap
        case incrementAsync(Int)
        case decrementAsync(Int)
        case setStep(Int)
        case setShowErrorAlert(Bool)
        case error(String)
        case reset
    }
    
    let effect: CounterStepEEffectProtocol
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case .incrementTap:
            state.isLoading = true
            let currentCount = state.counter
            let step = state.step
            return Effect.run { send in
                do {
                    let newCount = try await effect.increment(currentCount, step)
                    await send(.incrementAsync(newCount))
                } catch {
                    await send(.error(error.localizedDescription))
                }
            }
            
        case .decrementTap:
            state.isLoading = true
            let currentCount = state.counter
            let step = state.step
            return Effect.run { send in
                do {
                    let newCount = try await effect.decrement(currentCount, step)
                    await send(.decrementAsync(newCount))
                } catch {
                    await send(.error(error.localizedDescription))
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
        
        case .error(let error):
            state.isLoading = false
            state.errorMessage = error
            state.showErrorAlert = true
            return .none
            
        case .setShowErrorAlert(let isShow):
            state.showErrorAlert = isShow
            if !isShow {
                state.errorMessage = nil
            }
            return .none
            
        case .reset:
            state.counter = 0
            state.step = 1
            return .none
        }
    }
}

protocol CounterStepEEffectProtocol {
    func increment(_ currentCount: Int,_ step: Int) async throws -> Int
    func decrement(_ currentCount: Int,_ step: Int) async throws -> Int
}

struct CounterStepEEffect: CounterStepEEffectProtocol {
    
    private let errorProbability = 0.25
    func increment(_ currentCount: Int,_ step: Int) async throws -> Int {
        try await Task.sleep(for: .seconds(2))
        if Double.random(in: 0...1) < errorProbability {
            print("Error increment")
            throw NSError(domain: "Error increment", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to increment value"])
        }
        return currentCount + step
    }
    
    func decrement(_ currentCount: Int,_ step: Int) async throws -> Int {
        try await Task.sleep(for: .seconds(2))
        if Double.random(in: 0...1) < errorProbability {
            print("Error decrement")
            throw NSError(domain: "Error decrement", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to decrement value"])
        }
        return currentCount - step
    }
}

