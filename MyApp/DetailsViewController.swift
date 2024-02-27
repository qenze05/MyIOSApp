//
//  DetailsViewController.swift
//  MyApp
//
//  Created by Oleksandr Kataskin on 27.02.2024.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet var detailsView: UIView!
    
    public static var post:Child?
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var saveButton: UIImageView!
    @IBOutlet weak var postAuthorInfo: UILabel!
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePostView()
    }
    
    public func updatePostView() {
        
        guard let post = DetailsViewController.post
        else { return }
        
        postAuthorInfo.text = "u/\(post.data.authorFullname) • \(FormattingUtils.UTCtoHoursInterval(post.data.created))h ago • \(post.data.domain)"
        
        postTitle.text = post.data.title
        titleHeight.constant = FormattingUtils.calculateTitleHeight(string: postTitle.text ?? "Title", width: postTitle.frame.width, font: postTitle.font)
        
        
        //is saved ?
//        if post.data.saved {
//            BookmarkButton.tintColor = UIColor.systemYellow
//        } else {
//            BookmarkButton.tintColor = UIColor.label
//        }
        
        upvoteButton.setTitle(FormattingUtils.formatNumber(post.data.score), for: .normal)
        commentsButton.setTitle(FormattingUtils.formatNumber(post.data.numComments), for:.normal)
        
        postImage.loadImage(urlString: post.data.url)
    }

}

