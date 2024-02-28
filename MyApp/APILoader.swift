//
//  APILoader.swift
//  MyApp
//
//  Created by Oleksandr Kataskin on 20.02.2024.
//

import Foundation

class APILoader {
    
    var url:URL
    var subreddit:String
    var limit:Int
    var after:String?
    
    init() {
        url = URL(string:"https://www.reddit.com/")!
        subreddit = ""
        limit = 0
    }
    
    convenience init?(urlString:String) {
        guard let url = URL(string:urlString)
        else { return nil }
        self.init()
        self.url = url
    }
    
    convenience init?(urlString:String, subreddit:String) {
        self.init(urlString: urlString)
        self.subreddit = subreddit
    }
    
    convenience init?(urlString:String, subreddit:String, limit:Int) {
        self.init(urlString: urlString, subreddit: subreddit)
        self.limit = limit
    }
    
    func getFullUrl() -> URL? {
        var fullURL:URL = self.url
        
        if subreddit.isEmpty { return nil }
        
        fullURL.append(path:"r/\(subreddit)/top.json")
        if limit > 0 {
            fullURL.append(queryItems: [URLQueryItem(name: "limit", value: String(limit))])
        }
        if after != nil {
            fullURL.append(queryItems: [URLQueryItem(name: "after", value: after)])

        }
        print(fullURL)
        return fullURL
    }
    
    func fetchURLData(url:URL) async -> (String, [Child])? {
        
        let data = try? await URLSession.shared.data(from:url)

        guard let data, let decoded = try? JSONDecoder().decode(Welcome.self, from:data.0)
        else {
            print("Failed to load data from URL \(url)")
            return nil
        }
        
        return (decoded.data.after, decoded.data.children)
    }
    
    static func getShareURL(domain:URL?, post:String) -> URL? {
        return domain?.appending(path:post[post.index(post.startIndex, offsetBy: 1)..<post.endIndex])
    }
    
}

struct Welcome: Codable {
    let data: WelcomeData
}

// MARK: - WelcomeData
struct WelcomeData: Codable {
    let after:String
    let children: [Child]
}

// MARK: - Child
struct Child: Codable, Equatable {
    static func == (lhs: Child, rhs: Child) -> Bool {
        return lhs.data.permalink == rhs.data.permalink
           && lhs.data.authorFullname == rhs.data.authorFullname
           && lhs.data.created == rhs.data.created
           && lhs.data.domain == rhs.data.domain
    }
    
    var data: ChildData
}

// MARK: - ChildData
struct ChildData: Codable {
    let authorFullname: String
    var saved: Bool = false
    let title: String
    let ups, score: Int
    let thumbnail: String
    let created: Int
    let domain: String
    let numComments: Int
    let url: String
    let permalink:String

    enum CodingKeys: String, CodingKey {
        case authorFullname = "author_fullname"
        case numComments = "num_comments"
        case saved, title, ups, score, thumbnail, created, domain, permalink, url
    }
}
