//
//  ViewController.swift
//  DataAndNetworkLayer
//
//  Created by 梁世仪 on 2023/6/5.
//

import UIKit

class ViewController: UIViewController {
    
    var movieGenres = [MovieGenre]()
    @IBOutlet weak var labelGeneral: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getUpcomingMovieList()
        genreList()
        getGenresList()
        getGenreListWithSerialization()
//        login()
        
    }
    private func getUpcomingMovieList() {
        let url = URL(string: "\(BaseURL)/movie/upcoming?language=en-US&page=1&region=")
        var urlRequest = URLRequest(url: url!)
        urlRequest.addValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let data = data {
                let upcomingMovieList = try! JSONDecoder().decode(UpcomingMovieList.self, from: data)
                DispatchQueue.main.async {
                    self.labelGeneral.text = upcomingMovieList.results?.map{
                        $0.title ?? "undefined"
                    }.reduce("", { partialResult, value2 in
                        if partialResult.isEmpty {
                            return value2
                        } else {
                            return "\(partialResult), \(value2)"
                        }
                    })
                }
            }
        }
        .resume()
    }
    private func genreList() {
        
        let url = URL(string: "\(BaseURL)/genre/movie/list?language=en")
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
        }
        
        task.resume()
        
    }
    private func login() {
        let url = URL(string: "\(BaseURL)/authentication/token/validate_with_login")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("\(accessToken)", forHTTPHeaderField: "Authorization")
//        let requestBody = [
//            "username": "XiaoHwam",
//            "password": "Warner2021?",
//            "request_token": ""
//        ]
//        let bodyData = try! JSONSerialization.data(withJSONObject: requestBody, options: .init())
//        urlRequest.httpBody = bodyData
        let requestObject = LoginRequest(username: tmdbUserName, password: tmdbPassword, request_token: requestToken1)
        urlRequest.httpBody = try! JSONEncoder().encode(requestObject)
        
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { data, response, error in
            let statusCode = (response as! HTTPURLResponse).statusCode
            let successRange = 200..<300
            let decoder = JSONDecoder()
            
            if successRange.contains(statusCode){
                let res = try! decoder.decode(LoginSuccess.self, from: data!)
                print(res.success!)
                print(res.expires_at!)
                print(res.request_token!)
            } else {
                let res = try! decoder.decode(LoginFailed.self, from: data!)
                print(res.success!)
                print(res.statusCode!)
                print(res.statusMessage!)
            }
        }
        .resume()
    }
    private func getGenresList() {
        let url = URL(string: "\(BaseURL)/genre/movie/list?language=en")
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            let genreList = try! JSONDecoder().decode(MovieGenreList.self, from: data!)
            print(genreList.genres)
        }
        .resume()
    }
    private func getGenreListWithSerialization() {
        let url = URL(string: "\(BaseURL)/genre/movie/list?language=en")
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            let dataDict = try! JSONSerialization.jsonObject(with: data!, options: .init()) as! [String: Any]
            let genreList = dataDict["genres"] as! [[String: Any]]
            self.movieGenres = genreList.map({ genre in
                let id = genre["id"] as! Int
                let name = genre["name"] as! String
                return MovieGenre(id: id, name: name)
            })
            print(self.movieGenres.count)
        }
        .resume()
    }
}

