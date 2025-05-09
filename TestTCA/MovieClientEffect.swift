import Foundation
import Dependencies

//Клієнт для роботи з фільмами через API
struct MovieClientEffect {
    
    var getMovies: @Sendable() async throws -> [Movie] // це кложур саінхронний, може беспечно повертати значення на різних потоках в данному випадку масив, не блокує поток, видає помилки,
    
    var getMovieDetails: @Sendable (Int) async throws -> MovieThemoviedb
}

//Реєстрація MovieClient як залежності для TCA
extension MovieClientEffect: DependencyKey {
    static let liveValue = MovieClientEffect( // метод тіпу а не екземпляту для того щоб можна будо до нього звернутися не створюючи екзмпляр, (типу маденький сінглтон), тегко можна тестувати способом підстановки данних або перевікористовувати і має статичну диспетчерезацію
        getMovies: {
            let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=\("7b6b44608b3d5f7efb2bd09bca9d5ff8")")!
            print("🌐 Запит до API (фільми): \(url)")
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Статус відповіді: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let movieResponse = try decoder.decode(MovieResponse.self, from: data)
            return movieResponse.results
        },
        getMovieDetails: { id in
            let url = URL(string: "https://api.themoviedb.org/3/movie/\(id)?api_key=\("7b6b44608b3d5f7efb2bd09bca9d5ff8")")!
            print("🌐 Запит до API (деталі фільму): \(url)")
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Статус відповіді: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(MovieThemoviedb.self, from: data)
        }
    )
}

/// Розширення для доступу до MovieClient через систему залежностей TCA
extension DependencyValues { // який відповідає за інжекцію залежностей
    var movieClientEffect: MovieClientEffect { // компютед проперті що пріймає і повертає, тіп який це реалізує, зручно отримати або оновити movieClient в будь якому місці
        get { self[MovieClientEffect.self] }
        set { self[MovieClientEffect.self] = newValue }
    }
}
