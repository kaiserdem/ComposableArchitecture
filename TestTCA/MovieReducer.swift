import SwiftUI
import ComposableArchitecture

struct MovieReducer: Reducer {
    struct State: Equatable {
        var movies: [Movie] = []
        var isLoading = false
        var error: String?
    }
    
    enum Action {
        case loadMovies
        case moviesResponse(TaskResult<[Movie]>)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadMovies:
            state.isLoading = true
            return .run { send in
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
