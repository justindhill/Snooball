//
//  SelfLinkDetailHeader.swift
//  Snooball
//
//  Created by Justin Hill on 3/13/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import AsyncDisplayKit
import reddift

class SelfLinkDetailHeader: ASCellNode {
    
    let link: Link
    let InterItemVerticalSpacing: CGFloat = 12.0
    let titleLabel = ASTextNode()
    
    let scoreIconNode = ASImageNode()
    let scoreLabel = ASTextNode()
    let upvoteRatioIconNode = ASImageNode()
    let upvoteRatioLabel = ASTextNode()
    let timeAgoIconNode = ASImageNode()
    let timeAgoLabel = ASTextNode()
    let authorInfoLabel = ASTextNode()
    let selfTextLabel = ASTextNode()
    
    let imageNode = ASNetworkImageNode()
    
    
    init(link: Link) {
        self.link = link
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        self.imageNode.backgroundColor = UIColor.black
        self.imageNode.contentMode = .scaleAspectFit
        
        self.scoreIconNode.image = UIImage(named: "score")
        self.upvoteRatioIconNode.image = UIImage(named: "score")
        self.timeAgoIconNode.image = UIImage(named: "clock")
        
        self.applyLink(link)
    }
    
    private func applyLink(_ link: Link) {
        self.titleLabel.attributedText = NSAttributedString(string: link.title, attributes: self.titleFontAttributes())
        self.scoreLabel.attributedText = NSAttributedString(string: String(link.score))
        self.upvoteRatioLabel.attributedText = NSAttributedString(string: String(link.upvoteRatio))
        self.timeAgoLabel.attributedText = NSAttributedString(string: String(link.createdUtc))
        self.selfTextLabel.attributedText = NSAttributedString(string: String(link.selftext), attributes: self.selfTextFontAttributes())
        self.authorInfoLabel.attributedText = NSAttributedString(string: "by \(link.author) in \(link.subreddit)")
        
        if let url = URL(string: link.thumbnail) {
            self.imageNode.url = url
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let headerMargins = UIEdgeInsetsMake(Constants.verticalPageMargin, Constants.horizontalPageMargin, 0, Constants.horizontalPageMargin)
        
        let photoContainer = ASRatioLayoutSpec(ratio: (9/16), child: self.imageNode)
        photoContainer.style.preferredLayoutSize = ASLayoutSizeMake(ASDimensionMake("100%"), ASDimensionAuto)
        
        let postInfoStack = ASInsetLayoutSpec(insets: headerMargins, child:
            ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .start, children: [
                self.titleLabel,
                self.postMetadataLayoutSpec(),
                ASInsetLayoutSpec(insets: UIEdgeInsets(top: InterItemVerticalSpacing, left: 0, bottom: 0, right: 0), child: self.selfTextLabel)
            ])
        )
        
        var mainStackChildren = [ASLayoutElement]()
        
        mainStackChildren.append(photoContainer)
        mainStackChildren.append(postInfoStack)
        
        return ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .start, children: mainStackChildren)
    }
    
    private func postMetadataLayoutSpec() -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: InterItemVerticalSpacing, left: 0, bottom: 0, right: 0), child:
            ASStackLayoutSpec(direction: .vertical, spacing: Constants.verticalPageMargin / 2, justifyContent: .start, alignItems: .start, children: [
                    ASStackLayoutSpec(direction: .horizontal, spacing: 3, justifyContent: .start, alignItems: .center, children: [
                        self.scoreIconNode,
                        self.scoreLabel,
                        ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 0), child: self.upvoteRatioIconNode),
                        self.upvoteRatioLabel,
                        ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 0), child: self.timeAgoIconNode),
                        self.timeAgoLabel
                    ]),
                    self.authorInfoLabel
                ]
            )
        )
    }
    
    private func titleFontAttributes() -> [String: AnyObject] {
        let para = NSMutableParagraphStyle()
        para.lineHeightMultiple = Constants.titleTextLineHeightMultiplier
        
        return [
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline),
            NSParagraphStyleAttributeName: para
        ]
    }
    
    private func selfTextFontAttributes() -> [String: AnyObject] {
        let para = NSMutableParagraphStyle()
        para.lineHeightMultiple = 1.05
        
        return [
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body),
            NSParagraphStyleAttributeName: para
        ]
    }
}
