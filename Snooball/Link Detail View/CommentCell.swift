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
    
    let depth: Int
    let contentNode: ASDisplayNode
    let colorRail = ASDisplayNode()
    var unhighlightedBackgroundColor: UIColor?
    
    let colorSequence = [
        UIColor.black,                                                       // dummy color
        UIColor(red: 239/255, green: 69/255, blue: 61/255, alpha: 1.0),      // r
        UIColor(red: 253/255, green: 145/255, blue: 60/255, alpha: 1.0),     // o
        UIColor(red: 248/255, green: 207/255, blue: 79/255, alpha: 1.0),     // y
        UIColor(red: 47/255, green: 112/255, blue: 77/255, alpha: 1.0),      // g
        UIColor(red: 26/255, green: 118/255, blue: 217/255, alpha: 1.0),     // b
        UIColor(red: 36/255, green: 72/255, blue: 133/255, alpha: 1.0),      // i
        UIColor(red: 99/255, green: 62/255, blue: 147/255, alpha: 1.0),      // v
    ]
    
    init(contentNode: ASDisplayNode, depth: Int) {
        self.depth = depth
        self.contentNode = contentNode

        super.init()

        self.automaticallyManagesSubnodes = true

        self.backgroundColor = UIColor(red: 237.0/255.0, green: 238.0/255.0, blue: 240.0/255.0, alpha: 1)
        
        self.contentNode.style.flexShrink = 1.0
        self.contentNode.style.flexGrow = 1.0
        
        self.colorRail.backgroundColor = self.colorSequence[depth % self.colorSequence.count]
        self.colorRail.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(3.0), height: ASDimensionAuto)
        
        self.selectionStyle = .none
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let hStack = ASStackLayoutSpec.horizontal()
        
        if (self.depth > 0) {
            hStack.children?.append(self.colorRail)
        }
        
        hStack.children?.append(self.contentNode)
        hStack.style.flexGrow = 1.0
        
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: CGFloat(self.depth * 6),
            bottom: 0,
            right: 0),
        child: hStack)
        insetSpec.style.flexGrow = 1.0
        insetSpec.style.flexShrink = 1.0
        
        return insetSpec
    }
    
    override var isHighlighted: Bool {
        didSet(value) {
            if value {
                self.unhighlightedBackgroundColor = self.contentNode.backgroundColor
                self.contentNode.backgroundColor = self.contentNode.backgroundColor?.darkened(byPercent: 0.1)
            } else if let unhighlightedBackgroundColor = self.unhighlightedBackgroundColor {
                self.unhighlightedBackgroundColor = nil
                self.contentNode.backgroundColor = unhighlightedBackgroundColor
            }
        }
    }
}
