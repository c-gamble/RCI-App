//
//  ViewController.swift
//  RCIiOS
//
//  Created by Cooper Gamble on 5/2/22.
//

import UIKit

struct Post:Decodable {
    let id: Int;
    let title, postBody: String
}
class Service: NSObject {
    static let shared = Service()
    func fetchPosts(completion: @escaping (Result<[Post],Error>) -> ()) {
        guard let url = URL(string: "http://localhost:1337/posts") else {return}
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
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
        guard let url = URL(string: "http://localhost:1337/post") else {return}
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
        guard let url = URL(string: "http://localhost:1337/post/\(id)") else {return}
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
class ViewController: UIViewController {
    
    fileprivate func fetchPosts() {
        Service.shared.fetchPosts { (res) in
            switch res {
            case .failure(let err):
                print("failed to fetch post: ", err)
            case .success (let posts):
                self.posts = posts
                self.tableView.reloadData()
            }
        }
    }
    
    var posts = [Post]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPosts()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Posts"
        
        navigationItem.rightBarButtonItem = .init(title:"Create Post", style: .plain, target: self, action: #selector(handleCreatePost))
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let post = self.posts[indexPath.row]
            Service.shared.deletePost(id: post.id) { (err) in
                if let err = err {
                 print("failed to delete post: ", err)
                 return
             }
             print("post deleted successfully")
                 self.posts.remove(at: indexPath.row)
                 self.tableView.deleteRows(at: [indexPath], with: .automatic)
         }
    }
    }
    @objc fileprivate func handleCreatePost() {
        print("creating post..")
        Service.shared.createPost(title: "IOS TITLE", postBody: "IOS POST BODY") { (err) in
            if let err = err {
                print("failed to create post: ", err)
                return
            }
            print("post created successfully")
            self.fetchPosts()
        }
    }

}
extension ViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let post = posts[indexPath.row]
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = post.postBody
        return cell
    }
}
extension ViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
