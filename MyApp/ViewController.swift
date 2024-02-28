//
//  ViewController.swift
//  MyApp
//
//  Created by Oleksandr Kataskin on 20.02.2024.
//

import UIKit

class ViewController: UIViewController {
    
    var searchBar = UISearchTextField()
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var savedPostsButton: UIButton!
    @IBOutlet weak var topPostsButton: UIButton!
    @IBOutlet weak var viewTitle: UINavigationItem!
    @IBOutlet var tableView: UITableView!
    
    private var savedPostsMode:Bool = false
    private var loadedPosts:[Child] = []
    private var savedPosts:[Child] = []
    private var filteredPosts:[Child]?
    private let cellIdentifier = "post_cell"
    private let segueIdentifier = "view_details"
    private var apiLoader:APILoader?
    
    private var areNewPostsLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedPosts()
        configureButtons()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(savePostsToJSON),
                                               name: Notification.Name("AppWillTerminate"),
                                               object: nil)
        Task {
            await loadPosts()
        }
    }
    
    
    public func isPostSaved( post: Child) -> Bool {
        for p in savedPosts {
            if post == p {
                return true
            }
        }
        return false
    }
    
    public func getPostID( post: Child) -> Int {
        if savedPostsMode {
            for i in 0..<savedPosts.count {
                if post == savedPosts[i] {
                    return i
                }
            }
        } else {
            for i in 0..<loadedPosts.count {
                if post == loadedPosts[i] {
                    return i
                }
            }
        }
        return 0
    }
    public func addToSaved(post:Child) {
        let id = getPostID(post: post)
        loadedPosts[id].data.saved = true
        savedPosts.append(loadedPosts[id])
    }
    
    public func deleteFromSaved(post:Child) {
        for i in 0..<savedPosts.count {
            if savedPosts[i] == post {
                savedPosts.remove(at: i)
                break
            }
        }
        for i in 0..<loadedPosts.count {
            if loadedPosts[i] == post {
                loadedPosts[i].data.saved = false
                break
            }
        }
        
    }
    
    @objc
    private func savePostsToJSON() {
        let jsonData = try? JSONEncoder().encode(savedPosts)
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let filePath = documentsDirectory.appending(path: "saved_posts.json")
        if !FileManager.default.fileExists(atPath: filePath.absoluteString) {
            FileManager.default.createFile(atPath: filePath.absoluteString, contents: nil)
        }
        
        do {
            try jsonData?.write(to: filePath)
        } catch {
            print("Failed to save data")
        }
        
        
        print("save posts func")
    }
    
    private func loadSavedPosts() {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let filePath = documentsDirectory.appending(path: "saved_posts.json")
        if !FileManager.default.fileExists(atPath: filePath.absoluteString) {
            FileManager.default.createFile(atPath: filePath.absoluteString, contents: nil)
        }
        
        guard let dataString = try? String(contentsOf: filePath, encoding: .utf8),
              let data = dataString.data(using: .utf8),
              let decodedData = try? JSONDecoder().decode([Child].self, from: data)
        else {
            print("Failed to load saved posts")
            return
        }

        savedPosts = decodedData
        
    }
    
    private func loadPosts() async {
        areNewPostsLoading = true
        if apiLoader == nil {
            apiLoader = APILoader(urlString: "https://www.reddit.com/", subreddit: "ios", limit: 10)
            viewTitle.title? += apiLoader?.subreddit ?? ""
        }
        
        let fullURL = apiLoader?.getFullUrl()
        
        guard let url = fullURL, let posts = await apiLoader?.fetchURLData(url: url), !posts.1.isEmpty
        else {return}
        
        if !posts.0.isEmpty {
            apiLoader?.after = posts.0
        }

        
        loadedPosts += posts.1
        
        for i in (loadedPosts.count-posts.1.count..<loadedPosts.count) {
            loadedPosts[i].data.saved = isPostSaved(post: loadedPosts[i])
        }
        
        tableView.reloadData()
        areNewPostsLoading = false
    }
    
    func configureButtons() {
        savedPostsButton.addAction(
            UIAction { [weak self] _ in
                guard let viewController = self else { return }
                viewController.savedPostsMode = true
                viewController.savedPostsButton.backgroundColor = .clearColorBG
                viewController.topPostsButton.backgroundColor = .clear
                viewController.addSearchBar()
                viewController.tableView.reloadData()
            }, for: .touchUpInside)
        
        topPostsButton.addAction(
            UIAction { [weak self] _ in
                guard let viewController = self else { return }
                viewController.savedPostsMode = false
                viewController.topPostsButton.backgroundColor = .clearColorBG
                viewController.savedPostsButton.backgroundColor = .clear
                viewController.removeSearchBar()
                viewController.tableView.reloadData()
            }, for: .touchUpInside)
        
        searchBar.addAction(UIAction { [weak self] _ in
            guard let viewController = self else { return }
            print("editing")
            viewController.filterPosts(filter:viewController.searchBar.text)
            print(viewController.filteredPosts == nil)
            viewController.tableView.reloadData()
        }, for: .editingDidEndOnExit)
    }
    
    private func filterPosts(filter:String?) {
        if let filter, !filter.isEmpty {
            filteredPosts = []
            for post in savedPosts {
                if(post.data.title.lowercased().contains(filter.lowercased())) {
                    filteredPosts?.append(post)
                }
            }
        } else {
            filteredPosts = nil
        }
    }
    private func addSearchBar() {
    
        self.view.addSubview(searchBar)
        tableViewTopConstraint.constant = 48
        searchBar.keyboardType = .default
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        searchBar.returnKeyType = .done
        
        searchBar.backgroundColor = .clearColorBG
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = searchBar.topAnchor.constraint(equalTo: savedPostsButton.bottomAnchor)
        topConstraint.constant = 2
        topConstraint.isActive = true
        
        let trailingConstraint = searchBar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        trailingConstraint.constant = -2
        trailingConstraint.isActive = true
        
        let leadingConstraint = searchBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor)
        leadingConstraint.constant = 2
        leadingConstraint.isActive = true
        
        let heightConstaint = searchBar.heightAnchor.constraint(equalToConstant: 44.0)
        heightConstaint.isActive = true
    }
    
    private func removeSearchBar() {
        tableViewTopConstraint.constant = 2
        searchBar.removeFromSuperview()
    }
}

extension ViewController:UITableViewDataSource, UITableViewDelegate {
    
    public static var selectedPost:Child?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if savedPostsMode {
            if let filteredPosts {
                return filteredPosts.count
            } else {
                return savedPosts.count
            }
        } else {
            return loadedPosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PostViewCell
        
        if savedPostsMode {
            if let filteredPosts {
                cell.configure(post: filteredPosts[indexPath.row])
            } else {
                cell.configure(post: savedPosts[indexPath.row])
            }
            configureCellButtons(cell: cell)
        } else {
            cell.configure(post: loadedPosts[indexPath.row])
            configureCellButtons(cell: cell)
        }
        
        return cell
    }
    
    func configureCellButtons(cell:PostViewCell) {
        if cell.buttonsConfigured { return }
        cell.buttonsConfigured = true
        
        let shareAction = UIAction { [weak self] _ in
            guard let viewController = self,
            let post = cell.post
            else { return }
            viewController.present(UIActivityViewController(activityItems: [APILoader.getShareURL(domain: viewController.apiLoader?.url, post: post.data.permalink) ?? ""], applicationActivities: nil), animated: true)
        }
        cell.shareButtonConfig = shareAction
        cell.shareButton.addAction(shareAction, for: .touchUpInside)
        
        let saveAction = UIAction { [weak self] _ in
            guard let viewController = self,
                  let post = cell.post
            else { return }
            if viewController.savedPostsMode
                || viewController.isPostSaved(post: post) {
                print("removing")
                viewController.deleteFromSaved(post:post)
                viewController.tableView.reloadData()
            } else {
                print("saving")
                viewController.addToSaved(post:post)
                viewController.tableView.reloadData()
            }
            
        }
        cell.saveButtonConfig = saveAction
        cell.saveButton.addAction(saveAction, for: .touchUpInside)
    }
    
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        DetailsViewController.cell = tableView.cellForRow(at: indexPath) as? PostViewCell
        DetailsViewController.apiLoader = apiLoader
        return indexPath
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.contentSize.height
        let offset = scrollView.contentOffset.y

        if !areNewPostsLoading && !savedPostsMode && offset >= height - 544*3 {
            
            print("Loading posts")
            Task {
                await loadPosts()
            }
        }
    }
    
    
}


