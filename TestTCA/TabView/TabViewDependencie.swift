
import SwiftUI
import ComposableArchitecture

struct TabStateD: Equatable {
    var selectedTab: Tab = .counter
    var counterState: CounterTabReducerD.State = CounterTabReducerD.State()
    var historyState: HistoryTabReducerD.State = HistoryTabReducerD.State()

}

                                                      /// Перечислення, що визначає всі можливі дії в додатку
enum TabActionD {
    case setSelectedTab(Tab)
    case counter(CounterTabReducerD.Action)
    case history(HistoryTabReducerD.Action)
}

                                                      /// Головний reducer додатку, що обробляє всі дії та оновлює стан
struct TabReducerD: Reducer {
    var body: some Reducer<TabStateD, TabActionD> {
        Reduce { state, action in
            switch action {
            case .setSelectedTab(let tab):
                                                       // Оновлюємо активну вкладку
                state.selectedTab = tab
                return .none
                
            case .counter(let counterAction):
                                                        // Створюємо reducer лічильника і обробляємо його дію
                let effect = CounterTabReducerD(effect: CounterTabEffectD())
                    .reduce(into: &state.counterState, action: counterAction)
                                                        // Перетворюємо ефект з дії лічильника в дію вкладки
                return effect.map { @Sendable in TabActionD.counter($0) }
            }
        }
    }
}

                                                     /// Головний view додатку, що відображає вкладки та їх вміст
struct TabViewD: View {
                                                     /// Store, що містить стан та обробляє дії
    let store: StoreOf<TabReducerD>
    
    var body: some View {
                                                      // Використовуємо WithViewStore для доступу до стану та відправки дій
        WithViewStore(store, observe: { $0 }) { viewStore in
                                                      // Створюємо TabView з можливістю перемикання вкладок
            SwiftUI.TabView(selection: viewStore.binding(
                get: \.selectedTab,
                send: { .setSelectedTab($0) }
            )) {
                CounterTabViewD(
                    store: store.scope(
                        state: \.counterState,
                        action: { TabActionD.counter($0) }
                    )
                )
                .tabItem {
                    Label("Лічильник", systemImage: "number")
                }
                .tag(Tab.counter)
                
                CounterTabListViewD(
                    store: store.scope(
                        state: \.historyState,
                        action: { TabActionD.history($0) }
                    )
                )
                .tabItem {
                    Label("Історія", systemImage: "clock")
                }
                .tag(Tab.history)
            }
        }
    }
}


struct MyButtonStuleD: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
    }
}


struct CounterTabViewD: View {
    let store: StoreOf<CounterTabReducerD>
    
    var body: some View {
        NavigationStack {
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
                        
                        Button("Go To History View") {
                            viewStore.send(.setHistoryView(true))
                        }
                        
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
                        Text("\(viewStore.history)")
                        Text("\(viewStore.state.count)")
                            .font(.title)
                        
                        
                        HStack {
                            Button("+") {
                                viewStore.send(.incrementTapped)
                            }
                            .buttonStyle(MyButtonStuleD())
                            
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
                .navigationDestination(isPresented: viewStore.binding(
                    get: \.showHistoryView,
                    send: {.setHistoryView($0)}
                )) {
                    CounterTabListViewD(store: Store(initialState: HistoryTabReducerD.State(), reducer: {
                        HistoryTabReducerD()
                    }))
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
}

struct HistoryTabReducerD: Reducer {
    
    struct State: Equatable {
        var history: [Int] = []
    }
    
    enum Action {
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
    }
}

struct CounterTabReducerD: Reducer {
    
    struct State: Equatable {
        var count: Int = 0
        var isLoading: Bool = false
        var step: Int = 1
        var showErrorAlert: Bool = false
        var errorMessage: String? = nil
        var showHistoryView: Bool = false
        var history: [Int] = []
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
        case setHistoryView(Bool)
        case addToHistory(Int)
    }
    
    let effect: CounterTabEffectProtocolD
    
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
            return .send(.addToHistory(value))
            
        case .decrementAsync(let value):
            state.isLoading = false
            state.count = value
            return .send(.addToHistory(value))

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
            
        case .setHistoryView(let isPresented):
            state.showHistoryView = isPresented
            return .none
            
        case .addToHistory(let value):
            state.history.append(value)
            return .none
        }
    }
}



protocol CounterTabEffectProtocolD {
    func increment(_ step: Int, _ currentCount: Int) async throws -> Int
    func decrement(_ step: Int, _ currentCount: Int) async throws -> Int
}

struct CounterTabEffectD: CounterTabEffectProtocolD {
    let errorProbability: Double = 0.25
    func increment(_ step: Int, _ currentCount: Int) async throws -> Int {
        try await Task.sleep(for: .seconds(0))
        if Double.random(in: 0...1) < errorProbability {
            throw NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey : "Error increment"])
        }
        return currentCount + step
    }
    func decrement(_ step: Int, _ currentCount: Int) async throws -> Int {
        try await Task.sleep(for: .seconds(0))
        if Double.random(in: 0...1) < errorProbability {
            throw NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey : "Error decrement"])
        }
        return currentCount - step
    }
}

struct CounterTabListViewD: View {
    let store: StoreOf<HistoryTabReducerD>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.history, id: \.self) { item in
                    HStack {
                        Text("\(item)")
                    }
                }
            }
        }
    }
}

