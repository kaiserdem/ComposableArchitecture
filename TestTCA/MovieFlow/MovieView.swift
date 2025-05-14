import SwiftUI
import ComposableArchitecture

/// &language=en-US
/// &page=\(page)

struct MovieView: View {
    let store: StoreOf<MovieReducer>                        /// це типізований Store, який працює з нашим MovieReducer
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in /// View залежить від Store / підписується на зміни в Store /надає доступ до стану через viewStore
            VStack {                                         /// Відображення стану
                if viewStore.isLoading {
                    ProgressView()
                } else if let error = viewStore.error {
                    Text("Помилка: \(error)")
                        .foregroundColor(.red)
                } else {
                    List(viewStore.movies) { movie in
                        VStack(alignment: .leading) {
                            Text(movie.title)
                                .font(.headline)
                            Text(movie.overview)
                                .font(.subheadline)
                                .lineLimit(2)
                        }
                        
                    }
                }
                
                Button("Завантажити фільми") {
                    viewStore.send(.loadMovies) /// viewStore.send() - метод для відправки Action до Store / .loadMovies - конкретна дія Action, яка буде оброблена в Reducer
                }
                .padding()
            }
        }
    }
}
/*
 Ми використовуємо WithViewStore для підключення до Store,
 який надає нам доступ до стану та можливість відправляти дії.
 View автоматично реагує на зміни стану,
 показуючи відповідний UI: індикатор завантаження, помилку або список фільмів.
 Коли користувач натискає кнопку, ми відправляємо дію .loadMovies, яка буде оброблена в Reducer."
 */




// MARK: -                                                                 ButtonStyle

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: configuration.isPressed ? 2 : 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
/*
Button("Натисни мене") {
    // дія
}
.buttonStyle(MyButtonStyle())
*/


// MARK: -                                                                CustomButton

struct CustomButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(radius: 4)
        }
    }
}
/*
 CustomButton(title: "Натисни мене") {
     print("Кнопка натиснута")
 }
 */


// MARK: -                                                        map / flatMap / compactMap / reduce

/*
 let numbers = [1, 2, 3, 4, 5]
 let squares = numbers.map { $0 * $0 }
 print(squares) // [1, 4, 9, 16, 25]
 
 let arrays = [[1, 2], [3, 4], [5]]
 let flattened = arrays.flatMap { $0 }
 print(flattened) // [1, 2, 3, 4, 5]
 
 let strings = ["1", "two", "3", "four"]
 let numbers = strings.compactMap { Int($0) }
 print(numbers) // [1, 3]
 
 let total = [1, 2, 3, 4, 5].reduce(0, +)
 print(total) // 15
 
 let evenNumbers = [1, 2, 3, 4, 5, 6].filter { $0 % 2 == 0 }
 print(evenNumbers) // [2, 4, 6]
 */

// MARK: -                                                        Приклад створення lazі-колекції:
/*
let numbers = Array(1...1000000).lazy

// Виконуємо операцію map — обчислюється тільки при реальному доступі
let squaredNumbers = numbers.map { $0 * $0 }

// Реально обчислюємо тільки перші 10
for number in squaredNumbers.prefix(10) {
    print(number)
}
*/

// MARK: -                                                              Collection

struct MyCollection<Element>: Collection {
    private var elements: [Element]
    
    init(_ elements: [Element]) {
        self.elements = elements
    }
    
    // Всі необхідні властивості:
    var startIndex: Int { elements.startIndex }
    var endIndex: Int { elements.endIndex }

    func index(after i: Int) -> Int { i + 1 }

    subscript(position: Int) -> Element {
        elements[position]
    }
}
/*
 // Створюємо нашу колекцію з масиву чисел
 let myCollection = MyCollection([10, 20, 30, 40, 50])


 // Виводимо всі індекси
 for index in myCollection.startIndex..<myCollection.endIndex {
     print("Індекс \(index): \(myCollection[index])")
 }
 */

// MARK: -                                                        State  // Локальний стан лічильника, оновлюється при натисканні

struct CounterView1: View {
    @State private var count: Int = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Лічильник: \(count)")

            Button("Збільшити") {
                count += 1
            }
        }
    }
}


// MARK: -                                                              @Binding + @State

struct ContentView2: View {
    @State private var isOn = false // стан, що зберігається у цьому View

    var body: some View {
        ToggleView(isOn: $isOn) // передаємо привʼязку
        Text("Статус: \(isOn ? "Вкл" : "Вимк")")
    }
}

struct ToggleView: View {
    @Binding var isOn: Bool // отримуємо привʼязку від батька

    var body: some View {
        Toggle("Включити", isOn: $isOn)
            .padding()
    }
}

// MARK: -                                                              @Published

class MyViewModel: ObservableObject {
    @Published var name: String = ""
}

struct ContentView3: View {
    @StateObject var viewModel = MyViewModel()

    var body: some View {
        TextField("Введіть імʼя", text: $viewModel.name)
        // при зміні `name` — UI оновиться автоматично
    }
}

// MARK: -                                                              animation

struct ContentView: View {
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 20) {
            // Кнопка з анімацією
            Button("Натисни мене") {
                withAnimation(.spring()) {
                    isPressed.toggle()
                }
            }
            .padding()
            .background(isPressed ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(25)
            .scaleEffect(isPressed ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: isPressed)
        }
        .padding()
    }
}

// MARK: -                                                               функція async / await
func fetchData() async -> String {
    
    // Емуляція затримки (наприклад, мережевий запит)
    await Task.sleep(2 * 1_000_000_000) // 2 секунди (в nanosecond)
    return "Дані отримані успішно"
}

// MARK: -                                                              Дженерік

func fetchResource<T>() async throws -> T {
    // Тут уявна логіка: наприклад, мережевий запит, зчитування з файлу тощо.
    fatalError("Це — шаблон, реалізація залежить від контексту")
}
/*
Task {
    do {
        let result: String = try await fetchResource()
        print("Отримано строку: \(result)")
    } catch {
        print("Сталася помилка: \(error)")
    }
}
*/

// MARK: -                                                              closure @escaping (Int)

func performTaskWithResult(completion: @escaping (Int) -> Void) {
    DispatchQueue.global().async {
        // виконуємо довгу роботу
        let result = 42 // наприклад, результат обчислень
        // викликаємо замикання, передаючи результат
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
/*
// Викликаємо:
performTaskWithResult { result in
    print("Обробка результату: \(result)")
}
*/

// MARK: -                                                              closure @escaping ()

func performAsyncTask(completion: @escaping () -> Void) {
    DispatchQueue.global().async {
        // Можна виконати через якийсь час
        print("Затримка у 1 секунду")
        // і потім викликаємо completion() пізніше
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion()
        }
    }
}
/*
// Використання:
performAsyncTask {
    print("Це викликається через 1 секунду після завершення")
}
*/

// MARK: -                                                              closure non escaping

func performImmediateTask(task: () -> Void) {
    // викликаємо прямо
    task()
}
/*
// Використання:
performImmediateTask {
    print("Це викликається миттєво")
}
*/


// MARK: -                                                              Counter

import SwiftUI
import ComposableArchitecture


struct TCA__CounterApp: App {
    
    var body: some Scene {
        WindowGroup {
            CounterView(store: Store(initialState: CounterReducer.State(),
                                     reducer: { CounterReducer() }
                                    ))
        }
    }
}

struct CounterView: View {
    let store: StoreOf<CounterReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text("\(viewStore.count)")
                HStack {
                    Button("+") {
                        viewStore.send(.increment)
                    }
                    
                    Button("-") {
                        viewStore.send(.decrement)
                    }
                }
            }
        }
    }
}

struct CounterReducer: Reducer {
    
        struct State: Equatable {
            var count = 0
        }
    
        enum Action {
            case increment
            case decrement
        }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .increment :
            state.count += 1
            return .none
        case .decrement :
            state.count -= 1
            return .none
        }
    }
}

// MARK: -                                                         Counter + Effect
/*

struct CounterView: View {
    let store: StoreOf<CounterReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                VStack {
                    Text("\(viewStore.count)")
                        .font(.largeTitle)
                        .padding()
                    HStack {
                        Button("+") {
                            viewStore.send(.incrementTapped)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("-") {
                            viewStore.send(.decrementTapped)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(height: 200)
                VStack {
                    if viewStore.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding(.top, 200)
                            Spacer()
                    }
                }
            }
        }
    }
}

struct CounterReducer: Reducer {
    struct State: Equatable {
        var count = 0
        var isLoading = false
    }
    
    enum Action {
        case incrementTapped
        case decrementTapped
        case incrementResponse(Int)
        case decrementResponse(Int)
    }
    
    @Dependency(\.movieClient) var movieClient
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .incrementTapped:
            state.isLoading = true
            return .run { send in
                let value = try await movieClient.increment()
                await send(.incrementResponse(value))
            }
            
        case .decrementTapped:
            state.isLoading = true
            return .run { send in
                let value = try await movieClient.decrement()
                await send(.decrementResponse(value))
            }
            
        case let .incrementResponse(value):
            state.count += value
            state.isLoading = false
            return .none
            
        case let .decrementResponse(value):
            state.count += value
            state.isLoading = false
            return .none
        }
    }
}
 struct MovieClientEffect {
     var increment: @Sendable () async throws -> Int
     var decrement: @Sendable () async throws -> Int
     
     static let live = Self(
         increment: {
             try await Task.sleep(for: .seconds(1))
             return 1
         },
         decrement: {
             try await Task.sleep(for: .seconds(1))
             return -1
         }
     )
 }
 
private enum MovieClientKey: DependencyKey {
    static let liveValue = MovieClientEffect.live
}

extension DependencyValues {
    var movieClient: MovieClientEffect {
        get { self[MovieClientKey.self] }
        set { self[MovieClientKey.self] = newValue }
    }
}
*/

// MARK: -                                                       Приклад: клас з сильним посиланням
/*
struct StrontContentView: View {
   
    @State var path: [String] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("NEXT") {
                    path.append("TestView")
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "TestView" {
                    StringTestView()
                }
            }
            
        }
    }
}

class Parent {
    var pet: Pet?
    
    deinit {
        print("Parent was deinit")
    }
}

class Pet {
   weak var parent: Parent?
    var parent: Parent?
    
    deinit {
        print("Pet was deinit")
    }
}




struct StringTestView: View {
    
    var parent: Parent = Parent()
    var pet: Pet? = Pet()
    
    //var dismiss: () -> Void
    var body: some View {
        VStack {
           
        }
        .onAppear {
            parent.pet = pet
            pet?.parent = parent
        }
        .onDisappear {
            
        }
    }
}
*/

// MARK: -                                                      _
// MARK: -                                                      _
// MARK: -                                                      _
// MARK: -                                                      _
// MARK: -                                                      _
// MARK: -                                                      _
// MARK: -                                                      _
// MARK: -                                                      _
// MARK: -                                                      _
// MARK: -                                                      _
// MARK: -                                                      _
// MARK: -                                                      _
// MARK: -                                                      _
// MARK: -                                                      _

