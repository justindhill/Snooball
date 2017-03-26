//
//  CommentCell.swift
//  Snooball
//
//  Created by Justin Hill on 3/26/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import AsyncDisplayKit
import reddift
import TSMarkdownParser

class CommentCell: ASCellNode {
    let usernameLabel = ASTextNode()
    let upvoteCountLabel = ASTextNode()
    let upvoteIconImage = ASImageNode()
    let timeAgoLabel = ASTextNode()
    let commentBodyLabel = ASTextNode()
    let separatorNode = ASDisplayNode()
    
    init(comment: Comment) {
        super.init()
        self.automaticallyManagesSubnodes = true
        self.upvoteIconImage.image = UIImage(named: "score")
        self.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        
        self.separatorNode.backgroundColor = UIColor.lightGray
        self.separatorNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionAuto, height: ASDimensionMake(0.5))
        
        self.apply(comment: comment)
    }
    
    func apply(comment: Comment) {
        let usernameAttributes = [NSFontAttributeName: UIFont.snb_preferredFont(forTextStyle: .caption1, weight: UIFontWeightSemibold)]
        self.usernameLabel.attributedText = NSAttributedString(string: comment.author, attributes: usernameAttributes)
        
        let upvoteCountAttributes = [
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: .caption1),
            NSForegroundColorAttributeName: UIColor.lightGray
        ]
        self.upvoteCountLabel.attributedText = NSAttributedString(string: String(comment.ups), attributes: upvoteCountAttributes)
        self.timeAgoLabel.attributedText = NSAttributedString(string: "7h", attributes: usernameAttributes)
        
        self.commentBodyLabel.attributedText = TSMarkdownParser.standard().attributedString(fromMarkdown: comment.body)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stretchy = ASDisplayNode()
        stretchy.style.flexGrow = 1
        // stfu AsyncDisplayKit.
        stretchy.style.preferredSize = CGSize(width: 5, height: 5)
        
        let commentMetadataStack = ASStackLayoutSpec(direction: .horizontal, spacing: 3, justifyContent: .start, alignItems: .start, children: [
            self.usernameLabel,
            self.upvoteIconImage,
            self.upvoteCountLabel,
            stretchy,
            self.timeAgoLabel
        ])
        
        let mainVerticalStack = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [
            commentMetadataStack,
            self.commentBodyLabel
        ])
        
        return ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [
            self.separatorNode,
            ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: Constants.verticalPageMargin / 2,
                left: Constants.horizontalPageMargin,
                bottom: Constants.verticalPageMargin / 2,
                right: Constants.horizontalPageMargin),
            child: mainVerticalStack)
        ])
    }
}
