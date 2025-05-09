import SwiftUI
import ComposableArchitecture

struct MovieView: View {
    let store: StoreOf<MovieReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
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
                    viewStore.send(.loadMovies)
                }
                .padding()
            }
        }
    }
}
