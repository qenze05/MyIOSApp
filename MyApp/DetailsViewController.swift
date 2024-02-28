//
//  DetailsViewController.swift
//  MyApp
//
//  Created by Oleksandr Kataskin on 27.02.2024.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet var detailsView: UIView!
    
    public static var cell:PostViewCell?
    public static var apiLoader:APILoader?
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var postAuthorInfo: UILabel!
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePostView()
        self.navigationController?.navigationBar.tintColor = UIColor.systemYellow;
    }
    
    public func updatePostView() {
        
        guard let cell = DetailsViewController.cell,
              let post = cell.post
        else { return }
        
        postAuthorInfo.text = cell.postAuthorInfo.text
        
        postTitle.text = cell.postTitle.text
        titleHeight.constant = FormattingUtils.calculateTitleHeight(string: postTitle.text ?? "Title", width: postTitle.frame.width, font: postTitle.font)
        
        if post.data.saved {
            saveButton.tintColor = UIColor.systemYellow
        } else {
            saveButton.tintColor = UIColor.label
        }
        
        upvoteButton.setTitle(cell.upvoteButton.currentTitle, for: .normal)
        commentsButton.setTitle(cell.commentButton.currentTitle, for: .normal)
        
        configureButtons()
        
        postImage.image = cell.postImage.image
    }
    
    func configureButtons() {
        if let cell = DetailsViewController.cell,
           let post = cell.post,
           let shareConfig = cell.shareButtonConfig,
           let saveConfig = cell.saveButtonConfig {
            shareButton.addAction(
                shareConfig, for: .touchUpInside)
            saveButton.addAction(saveConfig, for: .touchUpInside)
            saveButton.addAction(UIAction { [weak self] _ in
                guard let viewController = self else { return }
                if viewController.saveButton.tintColor == .systemYellow {
                    viewController.saveButton.tintColor = .label
                } else {
                    viewController.saveButton.tintColor = .systemYellow
                }
            }, for: .touchUpInside)
        }
    }

}

