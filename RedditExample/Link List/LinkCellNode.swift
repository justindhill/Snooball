//
//  ListingCellNode.swift
//  RedditExample
//
//  Created by Justin Hill on 3/12/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import reddift
import AsyncDisplayKit
import OpenGraph

fileprivate let PADDING: CGFloat = 16
fileprivate let PREVIEW_IMAGE_SIDELEN: CGFloat = 75
fileprivate let PREVIEW_CORNER_RADIUS: CGFloat = 3

class LinkCellNode: ASCellNode {
    let titleLabel = ASTextNode()
    let previewImageNode = ASNetworkImageNode()
    let link: Link
    let subredditLabel = ASTextNode()
    let scoreLabel = ASTextNode()
    let commentCountLabel = ASTextNode()
    let domainLabel = ASTextNode()
    let scoreIconNode = ASImageNode()
    let commentsIconNode = ASImageNode()
    let separatorNode = ASDisplayNode()
    
    static var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return formatter
    }()
    
    init(link: Link) {
        self.link = link
        
        super.init()
        self.automaticallyManagesSubnodes = true
        self.titleLabel.maximumNumberOfLines = 0
        self.previewImageNode.imageModificationBlock = { image in
            return LinkCellNode.roundedCroppedImage(image: image, cornerRadius: PREVIEW_CORNER_RADIUS)
        }
        
        self.titleLabel.isLayerBacked = true
        self.previewImageNode.isLayerBacked = true
        self.subredditLabel.isLayerBacked = true
        self.scoreLabel.isLayerBacked = true
        self.commentCountLabel.isLayerBacked = true
        self.scoreIconNode.isLayerBacked = true
        self.commentsIconNode.isLayerBacked = true
        self.separatorNode.isLayerBacked = true
        
        self.commentsIconNode.contentMode = UIViewContentMode.center
        self.commentsIconNode.image = UIImage(named: "comments")
        self.commentsIconNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(.lightGray)

        self.scoreIconNode.contentMode = UIViewContentMode.center
        self.scoreIconNode.image = UIImage(named: "score")
        self.scoreIconNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(.lightGray)
        
        self.previewImageNode.defaultImage = LinkCellNode.placeholderImage

        self.applyLink(link: link)
        self.backgroundColor = UIColor.white
        
        self.separatorNode.backgroundColor = UIColor.lightGray
        self.separatorNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionAuto, height: ASDimensionMake(0.5))
    }
    
    func applyLink(link: Link) {
        let titlePara = NSMutableParagraphStyle()
        titlePara.lineHeightMultiple = 1.2
        self.titleLabel.attributedText = NSAttributedString(string: link.title, attributes: [
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline),
            NSParagraphStyleAttributeName: titlePara
        ])
        
        if (link.thumbnail != "default") {
            if link.thumbnail == "self" {
                self.previewImageNode.url = nil
            } else if let url = URL(string: link.thumbnail) {
                self.previewImageNode.url = url
            }
        } else if let url = URL(string: link.url) {
            // set the url to a dummy url to prevent the image from being hidden during layout if the OpenGraph
            // image URL hasn't been discovered yet
            self.previewImageNode.url = URL(string: "about:blank")
            
            OpenGraph.fetch(url: url, completion: { [weak self] (og, error) in
                if let og = og, let imageUrlString = og[.image], let imageUrl = URL(string: imageUrlString) {
                    self?.previewImageNode.url = imageUrl
                }
            })
        } else {
            self.previewImageNode.url = nil
        }
        
        self.subredditLabel.attributedText = metadataAttributedString(string: link.subreddit, bold: true)
        self.scoreLabel.attributedText = metadataAttributedString(string: LinkCellNode.numberFormatter.string(from: NSNumber(integerLiteral: link.score)) ?? "0")
        self.commentCountLabel.attributedText = metadataAttributedString(string: LinkCellNode.numberFormatter.string(from: NSNumber(integerLiteral: link.numComments)) ?? "0")
        
        self.setNeedsLayout()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let size = CGSize(width: PREVIEW_IMAGE_SIDELEN, height: PREVIEW_IMAGE_SIDELEN)
        self.previewImageNode.style.minSize = size
        self.previewImageNode.style.maxSize = size
        
        let textVerticalStack = ASStackLayoutSpec.vertical()
        textVerticalStack.style.flexGrow = 1.0
        textVerticalStack.style.flexShrink = 1.0
    
        let titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: PADDING)
        textVerticalStack.children = [ASInsetLayoutSpec(insets: titleInsets, child: self.titleLabel)]
        
        let horizontalContentStack = ASStackLayoutSpec.horizontal()
        horizontalContentStack.children = [textVerticalStack]
        
        if self.previewImageNode.url != nil {
            let imageVerticalStack = ASStackLayoutSpec.vertical()
            imageVerticalStack.children = [self.previewImageNode]
            
            horizontalContentStack.children?.append(imageVerticalStack)
            
        } else {
            self.previewImageNode.isHidden = true
        }
        
        let wrapperVerticalStack = ASStackLayoutSpec.vertical()
        wrapperVerticalStack.children = [horizontalContentStack, metadataBarLayoutSpec(), separatorNode]
        
        let cellInsets = UIEdgeInsets(top: PADDING, left: PADDING, bottom: 0, right: PADDING)
        return ASInsetLayoutSpec(insets: cellInsets, child: wrapperVerticalStack)
    }
    
    func metadataBarLayoutSpec() -> ASLayoutSpec {
        let horizontalStack = ASStackLayoutSpec.horizontal()
        horizontalStack.children = [
            self.subredditLabel,
            ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 7, 0, 0), child: scoreIconNode),
            ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 3, 0, 0), child: scoreLabel),
            ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 7, 0, 0), child: commentsIconNode),
            ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 3, 0, 0), child: commentCountLabel)
        ]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: PADDING / 2, left: 0, bottom: PADDING, right: 0), child: horizontalStack)
    }
    
    func metadataAttributedString(string: String, bold: Bool = false) -> NSAttributedString {
        let fontSize = UIFont.preferredFont(forTextStyle: .caption1).pointSize
        let weight = bold ? UIFontWeightSemibold : UIFontWeightRegular
        
        var attributes = [
            NSForegroundColorAttributeName: UIColor.lightGray,
            NSFontAttributeName: UIFont.systemFont(ofSize: fontSize, weight: weight)
        ]
        
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    static var placeholderImage: UIImage? {
        get {
            let size = CGSize(width: PREVIEW_IMAGE_SIDELEN, height: PREVIEW_IMAGE_SIDELEN)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            UIColor.lightGray.setFill()
            let drawingRect = CGRect(origin: CGPoint.zero, size: size)
            
            let maskPath = UIBezierPath(roundedRect: drawingRect, cornerRadius: PREVIEW_CORNER_RADIUS)
            maskPath.addClip()
            
            let context = UIGraphicsGetCurrentContext()
            context?.fill(drawingRect)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image
        }
    }
    
    static func roundedCroppedImage(image: UIImage, cornerRadius radius: CGFloat) -> UIImage {
        var modifiedImage: UIImage?
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: PREVIEW_IMAGE_SIDELEN, height: PREVIEW_IMAGE_SIDELEN), false, 0)
        
        var drawingRect = CGRect(origin: CGPoint.zero, size: image.size)
        let ratio: CGFloat = image.size.width / image.size.height
        if ratio > 1 {
            let width = PREVIEW_IMAGE_SIDELEN * ratio
            drawingRect = CGRect(x: -(width - PREVIEW_IMAGE_SIDELEN) / 2, y: 0, width: width, height: PREVIEW_IMAGE_SIDELEN)
        } else {
            let height = PREVIEW_IMAGE_SIDELEN / ratio
            drawingRect = CGRect(x: 0, y: -(height - PREVIEW_IMAGE_SIDELEN) / 2, width: PREVIEW_IMAGE_SIDELEN, height: height)
        }
        
        let maskPath = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
        maskPath.addClip()
        
        image.draw(in: drawingRect)
        
        modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        assert(modifiedImage != nil)
        
        return modifiedImage ?? image
    }
}
