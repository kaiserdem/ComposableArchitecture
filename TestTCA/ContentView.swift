
import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("TestTCA Store work")
            MovieView(store: Store(
                initialState: MovieReducer.State(),
                reducer: { MovieReducer() }
            ))
        }
    }
}

struct TestView: View {
    @State private var movies: [Movie] = []
    @State private var isLoading = false
    @State private var error: String?
    
    var body: some View {
        VStack {
            
            Text("TestTCA TestView")
            if isLoading {
                ProgressView()
            } else if let error = error {
                Text("Помилка: \(error)")
                    .foregroundColor(.red)
            } else {
                List(movies) { movie in
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
                loadMovies()
            }
            .padding()
        }
    }
    
    func loadMovies() {
        isLoading = true
        error = nil
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=7b6b44608b3d5f7efb2bd09bca9d5ff8")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self.error = "Немає даних"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(MovieResponse.self, from: data)
                    self.movies = response.results
                } catch {
                    self.error = "Помилка декодування: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
}


struct Movie: Equatable, Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
}


struct MovieThemoviedb: Equatable, Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(posterPath)")
    }
}
