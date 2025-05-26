//
//  CounterHistoryView.swift
//  TestTCA
//
//  Created by Yaroslav Golinskiy on 26/05/2025.
//

import ComposableArchitecture
import SwiftUI


struct CounterHistoryView: View {
    let store: StoreOf<CounterHistoryReducer>
    
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
                    
                    Picker("",selection: viewStore.binding(
                        get: \.step,
                        send: {.step($0) }
                    )) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    Text("\(viewStore.state.count)")
                        .font(.title)
                    
                    
                    HStack {
                        Button("+") {
                            viewStore.send(.incrementTapped)
                        }
                        .padding()
                        .border(.black)
                        
                        Button("-") {
                            viewStore.send(.decrementTapped)
                        }
                        .padding()
                        .border(.black)
                    }
                    Button("Reset All") {
                        viewStore.send(.resetAll)
                    }
                    .padding()
                    .border(.black)
                    
                }
            }
            .alert(isPresented: viewStore.binding(
                get: \.showErrorAlert,
                send: { .setShawAlert($0) }
            )) {
                Alert(title:
                        Text("Error"),
                      message:
                        Text("\(viewStore.state.errorMessage ?? "No Error")"),
                      dismissButton: .default(Text("OK")) {
                    viewStore.send(.setShawAlert(false))
                })
            }
        }
    }
}

struct CounterHistoryReducer: Reducer {
    
    struct State: Equatable {
        var count: Int = 0
        var isLoading: Bool = false
        var step: Int = 1
        var showErrorAlert: Bool = false
        var errorMessage: String? = nil
    }
    
    enum Action {
        case incrementTapped
        case decrementTapped
        case incrementAsync(Int)
        case decrementAsync(Int)
        case step(Int)
        case resetAll
        case setShawAlert(Bool)
        case error(String)
    }
    
    let effect: CounterHistoryEffectProtocol
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case .incrementTapped:
            state.isLoading = true
            let currentCount = state.count
            let currentStep = state.step
            
            return Effect.run { send in
                do {
                    let newCount = try await self.effect.increment(currentStep, currentCount)
                    await send(.incrementAsync(newCount))
                } catch {
                    await send(.error(error.localizedDescription))
                }
            }
            
        case .decrementTapped:
            state.isLoading = true
            let currentCount = state.count
            let currentStep = state.step

            return Effect.run { send in
                do {
                    let newCount = try await self.effect.decrement(currentStep, currentCount)
                    await send(.decrementAsync(newCount))
                } catch {
                    await send(.error(error.localizedDescription))
                }
            }
            
        case .incrementAsync(let value):
            state.isLoading = false
            state.count = value
            return .none
            
        case .decrementAsync(let value):
            state.isLoading = false
            state.count = value
            return .none
            
        case .step(let step):
            state.step = step
            return .none
            
        case .resetAll:
            state.step = 1
            state.count = 0
            return .none
            
        case .error(let error):
            state.isLoading = false
            state.errorMessage = error
            state.showErrorAlert = true
            return .none
            
        case .setShawAlert(let show):
            state.isLoading = false
            state.showErrorAlert = show
            if !show {
                state.errorMessage = nil
            }
            return .none
        }
    }
}



protocol CounterHistoryEffectProtocol {
    func increment(_ step: Int, _ currentCount: Int) async throws -> Int
    func decrement(_ step: Int, _ currentCount: Int) async throws -> Int
}

struct CounterHistoryEffect: CounterHistoryEffectProtocol {
    let errorProbability: Double = 0.25
    func increment(_ step: Int, _ currentCount: Int) async throws -> Int {
        try await Task.sleep(for: .seconds(1))
        if Double.random(in: 0...1) < errorProbability {
            throw NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey : "Error increment"])
        }
        return currentCount + step
    }
    func decrement(_ step: Int, _ currentCount: Int) async throws -> Int {
        try await Task.sleep(for: .seconds(1))
        if Double.random(in: 0...1) < errorProbability {
            throw NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey : "Error decrement"])
        }
        return currentCount - step
    }
}


/*
struct CounterHistoryView: View {
    
    let store: StoreOf<CounterHistoryReducer>
    
    var body: some View {
        
        WithViewStore(store, observe: {$0}) { viewStore in
            NavigationView {
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
                        
                        NavigationLink {
                            CounterHistoryListView(store: store)
                        } label: {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("Історія змін")
                            }
                            .padding()
                        }
                        
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
}

struct CounterHistoryItem: Equatable {
    let value: Int
    let timestamp: Date
    let type: ChangeType
    
    enum ChangeType: Equatable {
        case increment
        case decrement
    }
}

struct CounterHistoryReducer: Reducer {
    
    struct State: Equatable {
        var counter: Int = 0
        var isLoading: Bool = false
        var step: Int = 1
        var showErrorAlert: Bool = false
        var errorMessage: String? = nil
        var history: [CounterHistoryItem] = []
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
        case addToHistory(CounterHistoryItem)
        case clearHistory
    }
    
    let effect: CounterHistoryEffectProtocol
    
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
            return .send(.addToHistory(CounterHistoryItem(value: value, timestamp: Date(), type: .increment)))
            
        case .decrementAsync(let value):
            state.isLoading = false
            state.counter = value
            return .send(.addToHistory(CounterHistoryItem(value: value, timestamp: Date(), type: .decrement)))
            
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
            
        case .addToHistory(let item):
            state.history.append(item)
            return .none
            
        case .clearHistory:
            state.history.removeAll()
            return .none
        }
    }
}

protocol CounterHistoryEffectProtocol {
    func increment(_ currentCount: Int,_ step: Int) async throws -> Int
    func decrement(_ currentCount: Int,_ step: Int) async throws -> Int
}

struct CounterHistoryEffect: CounterHistoryEffectProtocol {
    
    private let errorProbability = 0.25
    func increment(_ currentCount: Int,_ step: Int) async throws -> Int {
        try await Task.sleep(for: .seconds(0))
        if Double.random(in: 0...1) < errorProbability {
            print("Error increment")
            throw NSError(domain: "Error increment", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to increment value"])
        }
        return currentCount + step
    }
    
    func decrement(_ currentCount: Int,_ step: Int) async throws -> Int {
        try await Task.sleep(for: .seconds(0))
        if Double.random(in: 0...1) < errorProbability {
            print("Error decrement")
            throw NSError(domain: "Error decrement", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to decrement value"])
        }
        return currentCount - step
    }
}

struct CounterHistoryListView: View {
    let store: StoreOf<CounterHistoryReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.history.sorted(by: { $0.timestamp > $1.timestamp} ), id: \.timestamp) { item in
                    HStack {
                        Image(systemName: item.type == .increment ? "arrow.up" : "arrow.down")
                            .foregroundColor(item.type == .increment ? .green : .red)
                        
                        Text("\(item.value)")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(item.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                if !viewStore.history.isEmpty {
                    Button(action: { viewStore.send(.clearHistory) }) {
                        Text("Очистити історію")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Історія змін")
        }
    }
}
*/
