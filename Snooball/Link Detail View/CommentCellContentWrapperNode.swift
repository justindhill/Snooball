//
//  CommentCellContentWrapperNode.swift
//  Snooball
//
//  Created by Justin Hill on 4/1/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import AsyncDisplayKit
import reddift
import TSMarkdownParser

class CommentCellContentWrapperNode: ASDisplayNode {
    let usernameLabel = ASTextNode()
    let upvoteCountLabel = ASTextNode()
    let upvoteIconImage = ASImageNode()
    let timeAgoLabel = ASTextNode()
    let commentBodyLabel = ASTextNode()
    let separatorNode = ASDisplayNode()
    let collapsed: Bool
    
    
    init(comment: Comment, collapsed: Bool) {
        self.collapsed = collapsed
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.upvoteIconImage.image = UIImage(named: "score")
        
        self.separatorNode.backgroundColor = Constants.separatorColor
        self.separatorNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionAuto, height: ASDimensionMake(0.5))
        
        if !collapsed {
            self.backgroundColor = UIColor.white
        }
        
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
        
        let trimmedBody = comment.body.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.commentBodyLabel.attributedText = TSMarkdownParser.standard().attributedString(fromMarkdown: trimmedBody)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stretchy = ASDisplayNode()
        stretchy.style.flexGrow = 1.0
        // stfu AsyncDisplayKit.
        stretchy.style.preferredSize = CGSize(width: 5, height: 5)
        
        let commentMetadataStack = ASStackLayoutSpec(direction: .horizontal, spacing: 3, justifyContent: .start, alignItems: .start, children: [
            self.usernameLabel,
            self.upvoteIconImage,
            self.upvoteCountLabel,
            stretchy,
            self.timeAgoLabel
            ])
        commentMetadataStack.style.flexGrow = 1.0
        
        let mainVerticalStack = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .start, alignItems: .stretch, children: [
            commentMetadataStack
        ])
        mainVerticalStack.style.flexGrow = 1.0
        mainVerticalStack.style.flexShrink = 1.0
        
        if !self.collapsed {
            mainVerticalStack.children?.append(self.commentBodyLabel)
        }
        
        let insetMainVerticalStack = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(Constants.verticalPageMargin / 1.5, Constants.horizontalPageMargin, Constants.verticalPageMargin / 1.5, Constants.horizontalPageMargin), child: mainVerticalStack)
        insetMainVerticalStack.style.flexShrink = 1.0
        insetMainVerticalStack.style.flexGrow = 1.0
        
        return ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [
            insetMainVerticalStack,
            self.separatorNode
        ])
    }
}
