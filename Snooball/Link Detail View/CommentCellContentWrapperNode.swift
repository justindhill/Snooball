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
    
    let depth: Int
    
    init(comment: Comment, depth: Int) {
        self.depth = depth
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.upvoteIconImage.image = UIImage(named: "score")
        
        self.separatorNode.backgroundColor = Constants.separatorColor
        self.separatorNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionAuto, height: ASDimensionMake(0.5))
        
        self.apply(comment: comment)
    }
    
    let colorSequence = [
        UIColor.black,                                                       // dummy color
        UIColor(red: 215/255, green: 85/255, blue: 72/255, alpha: 1.0),      // r
        UIColor(red: 235/255, green: 152/255, blue: 72/255, alpha: 1.0),     // o
        UIColor(red: 241/255, green: 206/255, blue: 102/255, alpha: 1.0),    // y
        UIColor(red: 64/255, green: 108/255, blue: 81/255, alpha: 1.0),      // g
        UIColor(red: 59/255, green: 117/255, blue: 209/255, alpha: 1.0),     // b
        UIColor(red: 45/255, green: 72/255, blue: 130/255, alpha: 1.0),      // i
        UIColor(red: 93/255, green: 65/255, blue: 140/255, alpha: 1.0),      // v
    ]
    
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
            commentMetadataStack,
            self.commentBodyLabel
            ])
        mainVerticalStack.style.flexGrow = 1.0
        mainVerticalStack.style.flexShrink = 1.0
        
        let insetMainVerticalStack = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(Constants.verticalPageMargin / 1.5, Constants.horizontalPageMargin, Constants.verticalPageMargin / 1.5, Constants.horizontalPageMargin), child: mainVerticalStack)
        insetMainVerticalStack.style.flexShrink = 1.0
        insetMainVerticalStack.style.flexGrow = 1.0
        
        var contentStack: ASLayoutSpec?
        if self.depth > 0 {
            let colorRail = ASDisplayNode()
            colorRail.backgroundColor = self.colorSequence[depth % self.colorSequence.count]
            colorRail.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(3.0), height: ASDimensionAuto)
            
            let horizontalWrapper = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [
                colorRail,
                insetMainVerticalStack
                ])
            horizontalWrapper.style.flexGrow = 1.0
            
            
            let wrapperVerticalStack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [
                horizontalWrapper,
                self.separatorNode
            ])
            wrapperVerticalStack.style.flexGrow = 1.0
            
            contentStack = horizontalWrapper
            
        } else {
            contentStack = insetMainVerticalStack
        }
        
        guard let unwrappedContentStack = contentStack else {
            fatalError("This will never happen :D")
        }
        
        return ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [
            unwrappedContentStack,
            self.separatorNode
        ])
    }
}
