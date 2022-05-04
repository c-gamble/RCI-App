//
//  Service.swift
//  RCIiOS
//
//  Created by Cooper Gamble on 5/4/22.
//

import Foundation

class Service: NSObject {
    static let shared = Service()
    
    let baseURL = "http://localhost:8081/"
    
    func fetchPosts(completion: @escaping (Result<[Post],Error>) -> ()) {
        guard let url = URL(string: "\(baseURL)home") else {return}
       
        var fetchPostsReq = URLRequest(url: url)
        fetchPostsReq.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        URLSession.shared.dataTask(with: fetchPostsReq) { (data, resp, err) in
            DispatchQueue.main.async {
                if let err = err{
                    print("failed to fetch posts:", err)
                    return
                }
                guard let data = data else {return}
                do {
                    let posts = try JSONDecoder().decode([Post].self, from: data)
                    completion(.success(posts))
                } catch {
                    completion(.failure(error))
                }
            }
            
        }.resume()
    }
    func createPost(title: String, postBody: String, completion: @escaping (Error?) -> ()) {
        guard let url = URL(string: "\(baseURL)post") else {return}
        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "POST"
        let params = ["title":title, "postBody":postBody]
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .init())
            urlReq.httpBody = data
            urlReq.setValue("application/json", forHTTPHeaderField: "content-type")
            URLSession.shared.dataTask(with: urlReq) { (data, resp, err) in
                DispatchQueue.main.async {
                    if let err = err {
                        completion(err)
                        return
                    }
                    if let resp = resp as? HTTPURLResponse, resp.statusCode != 200 {
                        let errorString = String(data: data ?? Data(), encoding: .utf8) ?? ""
                        completion(NSError(domain: "", code: resp.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString]))
                        return
                    }
                    completion(nil)
                }
            }.resume()
        } catch {
            completion(error)
        }
    }
    
    func deletePost(id: Int, completion: @escaping (Error?) -> ()) {
        guard let url = URL(string: "\(baseURL)post/\(id)") else {return}
        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: urlReq) { (data, resp, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(err)
                    return
                }
                if let resp = resp as? HTTPURLResponse, resp.statusCode != 200 {
                    let errorString = String(data: data ?? Data(), encoding: .utf8) ?? ""
                    completion(NSError(domain: "", code: resp.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString]))
                    return
                }
                completion(nil)
            }
        }.resume()
    }
}
