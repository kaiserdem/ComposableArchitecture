import SwiftUI
import ComposableArchitecture

struct MovieReducer: Reducer {                           /// Відповідає за обробку дій та оновлення стану
    
    struct State: Equatable {                            /// State представляє поточний стан вашого модуля /  Equatable дозволяє порівнювати стани
        var movies: [Movie] = []
        var isLoading = false
        var error: String?
    }
    
    enum Action {                                       /// всі можливі дії модуля
        case loadMovies                                 /// дія при появі екрану ->  запускається ефект,
        case moviesResponse(TaskResult<[Movie]>)
    }
                                   
    func reduce(into state: inout State, action: Action) -> Effect<Action> { /// обробляє дії та оновлює стан, або поветає ефект для асинхронних операцій
                                                                             /// inout дозволяэ оновлювати значення полів State, без  inout не працювало б, бо state був би константою
        switch action {
        case .loadMovies:
            state.isLoading = true
            return .run { send in  /// run  Щоб запустити асинхронний запит чи будь-який побічний ефект
                await send(.moviesResponse(TaskResult {
                    let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=7b6b44608b3d5f7efb2bd09bca9d5ff8")!
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(MovieResponse.self, from: data)
                    return response.results
                }))
            }
            
        case let .moviesResponse(.success(movies)):
            state.movies = movies
            state.isLoading = false
            return .none
            
        case let .moviesResponse(.failure(error)):
            state.error = error.localizedDescription
            state.isLoading = false
            return .none
        }
    }
}

/*
 Reducer - це серце TCA архітектури.
 Він містить три основні компоненти: State для даних, Action для подій та функцію reduce для обробки цих подій.
 Коли користувач натискає кнопку 'Завантажити фільми',
 View відправляє дію .loadMovies. Reducer обробляє цю дію,
 запускає асинхронний запит та оновлює стан відповідно до результату.
 Це створює чіткий, передбачуваний потік даних у додатку."
 */
