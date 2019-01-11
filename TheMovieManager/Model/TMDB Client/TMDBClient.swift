//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class TMDBClient {
    
    static let apiKey = "d9987f6d38c9c183d75323198a12406c"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        case getWatchlist
        case getFavorites
        case getRequestToken
        case login
        case getSessionId
        case webAuth
        case logout
        case search(String)
        case markWatchlist
        case markFavorite
        case posterImage(String)
        
        var stringValue: String {
            switch self {
                case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                case .getFavorites: return Endpoints.base + "/account/\(Auth.accountId)/favorite/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                case .getRequestToken: return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
                case .login: return "\(Endpoints.base)/authentication/token/validate_with_login\(Endpoints.apiKeyParam)"
                case .getSessionId: return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
                case .webAuth: return "https://www.themoviedb.org/authenticate/\(Auth.requestToken)?redirect_to=skyttemovies:authenticate"
                case .logout: return "\(Endpoints.base)/authentication/session\(Endpoints.apiKeyParam)"
                case .search(let q): return "\(Endpoints.base)/search/movie\(Endpoints.apiKeyParam)&query=\(q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                case .markWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                case .markFavorite: return Endpoints.base + "/account/\(Auth.accountId)/favorite" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                case .posterImage(let imgPath): return "https://image.tmdb.org/t/p/w500/\(imgPath)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getWatchlist.url, responseType: MovieResults.self) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion([], error)
                return
            }
            completion(responseObject.results, nil)
        }
    }
    
    class func getFavorites(completion: @escaping ([Movie], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getFavorites.url, responseType: MovieResults.self) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion([], error)
                return
            }
            completion(responseObject.results, nil)
        }
    }
    
    class func search(query: String, completion: @escaping ([Movie], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.search(query).url, responseType: MovieResults.self) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion([], error)
                return
            }
            completion(responseObject.results, nil)
        }
    }
    
    class func markWatchlist(movieId: Int, mark: Bool, completion: @escaping (Bool, Error?) -> Void) {
        let body = MarkWatchlist(mediaType: MediaType.movie.rawValue, mediaId: movieId, watchlist: mark)
        taskForPOSTRequest(url: Endpoints.markWatchlist.url, requestBody: body, responseType: TMDBResponse.self) { (responseObject, error) in
            if let responseObject = responseObject {
                completion(
                    responseObject.statusCode == 1 ||
                    responseObject.statusCode == 12 ||
                    responseObject.statusCode == 13, nil)
            }
            else{
                completion(false, error)
            }
        }
    }
    
    class func markFavorite(movieId: Int, mark: Bool, completion: @escaping (Bool, Error?) -> Void) {
        let body = MarkFavorite(mediaType: MediaType.movie.rawValue, mediaId: movieId, favorite: mark)
        taskForPOSTRequest(url: Endpoints.markFavorite.url, requestBody: body, responseType: TMDBResponse.self) { (responseObject, error) in
            if let responseObject = responseObject {
                completion(
                    responseObject.statusCode == 1 ||
                        responseObject.statusCode == 12 ||
                        responseObject.statusCode == 13, nil)
            }
            else{
                completion(false, error)
            }
        }
    }
    
    class func getImage(imgPath: String, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.posterImage(imgPath).url) {
            (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        task.resume()
    }
    
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getRequestToken.url, responseType: RequestTokenResponse.self) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion(false, error)
                return
            }
            Auth.requestToken = responseObject.requestToken
            completion(responseObject.success, nil)
        }
    }
    
    class func login(un: String, pw: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = LoginRequest(username: un, password: pw, requestToken: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.login.url, requestBody: body, responseType: RequestTokenResponse.self) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion(false, error)
                return
            }
            Auth.requestToken = responseObject.requestToken
            completion(responseObject.success, nil)
        }
    }
    
    class func getSessionId(completion: @escaping (Bool, Error?) -> Void) {
        let body = PostSession(requestToken: Auth.requestToken)
        taskForPOSTRequest(url: Endpoints.getSessionId.url, requestBody: body, responseType: SessionResponse.self) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion(false, error)
                return
            }
            Auth.sessionId = responseObject.sessionId
            completion(responseObject.success, nil)
        }
    }
    
    class func logout(completion: @escaping () -> Void) {
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = LogoutRequest(sessionId: Auth.sessionId)
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            Auth.requestToken = ""
            Auth.sessionId = ""
            completion()
        }
        task.resume()
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void){
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(responseType, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, requestBody: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void){
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(responseType, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
}
