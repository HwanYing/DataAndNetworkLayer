//
//  SecondViewController.swift
//  DataAndNetworkLayer
//
//  Created by 梁世仪 on 2023/6/6.
//

import UIKit
import Alamofire

class SecondViewController: UIViewController {
    
    let headers: HTTPHeaders = [
        "Authorization": "\(accessToken)",
        "Accept": "application/json"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
//        getRequestToken()
//        getGenresList()
//        getUpcomingMovieList()
        searchMovies(name: "The")
    }
    
    private func getUpcomingMovieList() {
        /**
         1) url
         2) method
         3) headers
         4) body
         */
        let url = URL(string: "\(BaseURL)/movie/upcoming?language=en-US&page=1&region=")!
        
        AF.request(url, headers: headers).responseDecodable(of: UpcomingMovieList.self){ resp in
            switch resp.result {
            case .success(let upcomingMovieList):
                debugPrint("Upcoming Movies:")
                upcomingMovieList.results?.forEach({
                    debugPrint($0.title!)
                })
            case .failure(let error):
                debugPrint(error.errorDescription!)
            }
        }
    }
    
    private func getGenresList() {
        let url = URL(string: "\(BaseURL)/genre/movie/list?language=en")!
        AF.request(url, headers: headers).responseDecodable(of: MovieGenreList.self){ resp in
            switch resp.result {
            case .success(let data):
                print("Genre Movie List:")
                data.genres.forEach {
                    print($0.name)
                }
            case .failure(let error):
                print(error.errorDescription!)
            }
        }
    }
    
    private func searchMovies(name: String){
        
//       let url = URL(string: "\(BaseURL)/search/movie?query=The&include_adult=false&language=en-US&primary_release_year=2021&page=1&region=&year=2021")
        let url = URL(string: "\(BaseURL)/search/movie")!
        let parameters: [String: Any] = [
            "query": "\(name)",
            "include_adult": false,
            "primary_release": "2021",
            "page": 1,
            "year": "2021"
        ]
        AF.request(url, parameters: parameters, headers: headers).validate(statusCode: 200..<300)
            .responseDecodable(of: SearchMovieResult.self) { resp in
                switch resp.result {
                case .success(let searchList):
                    searchList.results?.forEach({ item in
                        print("Search result....")
                        print(item.title!)
                        print(item.originalTitle!)
                    })
                case .failure(let error):
                    print(error.errorDescription!)
                }
            }
    }
    
    private func getRequestToken() {
        let url = URL(string: "\(BaseURL)/authentication/token/new")!
        AF.request(url, headers: headers).validate(statusCode: 200..<300)
            .responseDecodable(of: RequestTokenResponse.self) { resp in
                switch resp.result {
                case .success(let data):
                    let requestToken = data.requestToken
                    self.login(requestToken: requestToken ?? "")
                case .failure(let error):
                    print(error.errorDescription!)
                }
            }
    }
    
    private func login(requestToken: String) {
        // url
        let url = URL(string: "\(BaseURL)/authentication/token/validate_with_login")!
        // request body
        let requestObject = LoginRequest(username: tmdbUserName, password: tmdbPassword, request_token: requestToken)
        
        // alamofire
        AF.request(url, method: .post, parameters: requestObject, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: LoginSuccess.self){ resp in
            switch resp.result {
            case .success(let data):
                print(data.success!)
                print(data.expires_at!)
                print(data.request_token!)
                
            case .failure(let error):
                print(error.errorDescription!)
            }
        }
    }
}
