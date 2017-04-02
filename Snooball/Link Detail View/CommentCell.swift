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
    let contentNode: CommentCellContentWrapperNode
    
    init(comment: Comment, depth: Int) {
        self.depth = depth
        self.contentNode = CommentCellContentWrapperNode(comment: comment, depth: depth)

        super.init()

        self.automaticallyManagesSubnodes = true

        self.backgroundColor = UIColor(red: 237.0/255.0, green: 238.0/255.0, blue: 240.0/255.0, alpha: 1)
        self.contentNode.backgroundColor = UIColor.white
        self.contentNode.apply(comment: comment)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: CGFloat(self.depth * 6),
            bottom: 0,
            right: 0),
        child: self.contentNode)
    }
}
