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

class ViewController: UIViewController {
    
    @objc fileprivate func fetchPosts() {
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
        
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(fetchPosts), for: .valueChanged)
        tableView.refreshControl = rc
        
        //fetchPosts()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Posts"
        navigationItem.rightBarButtonItem = .init(title: "Create Post", style: .plain, target: self, action: #selector(handleCreatePost))
        
        navigationItem.leftBarButtonItem = .init(title: "Login", style: .plain, target: self, action: #selector(handleLogin))
    }
    @objc fileprivate func handleLogin() {
        print("perform login and fetch posts")
        
        guard let url = URL(string: "http://localhost:8081/api/v1/entrance/login") else {return}
       
        var loginReq = URLRequest(url: url)
        loginReq.httpMethod = "PUT"
        do {
            let params = ["emailAddress":"testuser@gmail.com", "password":"1234"]
            loginReq.httpBody = try JSONSerialization.data(withJSONObject: params, options: .init())
            URLSession.shared.dataTask(with: loginReq) { data, resp, err in
                if let err = err {
                    print("failed to login: ", err)
                    return
                }
                print("successful login")
                self.fetchPosts()
            }.resume()
        } catch {
            print("failed to serialize data: ", error)
        }

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
