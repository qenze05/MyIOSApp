//
//  ViewController.swift
//  MyApp
//
//  Created by Oleksandr Kataskin on 20.02.2024.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var PostView:UIView!
    @IBOutlet weak var PostImage: UIImageView!
    @IBOutlet weak var HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var BookmarkButton: UIImageView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var UserInfoLabel: UILabel!
    @IBOutlet weak var TitleLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ButtonsPanel: UIView!
    @IBOutlet weak var ShareButton: UIButton!
    @IBOutlet weak var CommentButton: UIButton!
    @IBOutlet weak var UpvotesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await loadPost()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        //TODO: Add scroll view to make the content look nice in landscape mode
        TitleLabelHeight.constant = getTitleHeight(string: TitleLabel.text ?? "", width: PostView.frame.size.width-16, font: TitleLabel.font)
        HeightConstraint.constant = 410 + TitleLabelHeight.constant - getTitleHeight(string: "", width: 100, font: TitleLabel.font)
    }

    
    private func loadPost() async {
        let data:APILoader? = APILoader(urlString: "https://www.reddit.com/", subreddit: "ios", limit: 1)
        let fullURL = data?.getFullUrl()
        
        guard let url = fullURL, let posts = await data?.fetchURLData(url: url), !posts.isEmpty
        else {return}
        
        let post = posts[0]
        
        UserInfoLabel.text = "u/\(post.data.authorFullname) • \(getTimeInHours(post.data.created))h ago • \(post.data.domain)"
        
        TitleLabel.text = post.data.title
        
        //to be changed
        if post.data.saved {
            BookmarkButton.tintColor = UIColor.systemYellow
        } else {
            BookmarkButton.tintColor = UIColor.label
        }
        
        UpvotesButton.titleLabel?.text = getFormattedNumber(post.data.score)
        CommentButton.titleLabel?.text = getFormattedNumber(post.data.numComments)
        
        PostImage.loadImage(urlString: posts[0].data.url)
    }
    
    private func getTimeInHours(_ seconds:Int) -> Int {
        let timeInSeconds = Int(Date().timeIntervalSince1970) - seconds
        return timeInSeconds/3600
    }
    
    private func getFormattedNumber(_ num:Int) -> String {
        
        if num < 1000 { return String(num) }
        else { return String(format: "%.1f", Double(num)/1000)}
    }
    
    private func getTitleHeight(string:String, width: CGFloat, font: UIFont) -> CGFloat {
        
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = string.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    
}


