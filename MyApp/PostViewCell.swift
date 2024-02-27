//
//  PostViewCell.swift
//  MyApp
//
//  Created by Oleksandr Kataskin on 26.02.2024.
//

import UIKit


class PostViewCell: UITableViewCell {

    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var bookmartButton: UIImageView!
    @IBOutlet weak var postAuthorInfo: UILabel!
    
    @IBOutlet weak var postContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(post:Child) {
        postAuthorInfo.text = "u/\(post.data.authorFullname) • \(FormattingUtils.UTCtoHoursInterval(post.data.created))h ago • \(post.data.domain)"
        
        postTitle.text = post.data.title
        titleHeight.constant = min(FormattingUtils.calculateTitleHeight(string: postTitle.text ?? "Title", width: postTitle.frame.width, font: postTitle.font), FormattingUtils.calculateTitleHeight(string: "a \n a \n a", width: postTitle.frame.width, font: postTitle.font))
        
        
        //is saved ?
//        if post.data.saved {
//            BookmarkButton.tintColor = UIColor.systemYellow
//        } else {
//            BookmarkButton.tintColor = UIColor.label
//        }
        
        upvoteButton.setTitle(FormattingUtils.formatNumber(post.data.score), for: .normal)
        commentButton.setTitle(FormattingUtils.formatNumber(post.data.numComments), for:.normal)
        
        postImage.loadImage(urlString: post.data.url)
        
        
    }

}
