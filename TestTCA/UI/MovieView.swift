import SwiftUI
import ComposableArchitecture

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
