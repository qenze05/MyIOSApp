//
//  ViewController.swift
//  MyApp
//
//  Created by Oleksandr Kataskin on 20.02.2024.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    private var loadedPosts:[Child] = []
    private let cellIdentifier = "post_cell"
    private let segueIdentifier = "view_details"
    private var apiLoader:APILoader?
    
    private var areNewPostsLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await loadPosts()
        }
    }
    
    override func viewDidLayoutSubviews() {
    }

    
    private func loadPosts() async {
        areNewPostsLoading = true
        if apiLoader == nil {
            apiLoader = APILoader(urlString: "https://www.reddit.com/", subreddit: "ios", limit: 10)
        }
        
        let fullURL = apiLoader?.getFullUrl()
        
        guard let url = fullURL, let posts = await apiLoader?.fetchURLData(url: url), !posts.1.isEmpty
        else {return}
        
        if !posts.0.isEmpty {
            apiLoader?.after = posts.0
        }
        loadedPosts += posts.1
        tableView.reloadData()
        areNewPostsLoading = false
    }
}

extension ViewController:UITableViewDataSource, UITableViewDelegate {
    
    public static var selectedPost:Child?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PostViewCell
        cell.configure(post: loadedPosts[indexPath.row])
        
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        DetailsViewController.post = loadedPosts[indexPath.row]
        return indexPath
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.contentSize.height
        let offset = scrollView.contentOffset.y

        if offset >= height - 544*3 && !areNewPostsLoading {
            
            print("Loading posts")
            Task {
                await loadPosts()
            }
        }
    }
    
    
}


