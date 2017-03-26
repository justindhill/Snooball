//
//  CommentThreadTableAdapter.swift
//  Snooball
//
//  Created by Justin Hill on 3/18/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import reddift

struct CommentWrapper {
    let comment: Thing
    let depth: Int
    let children: [CommentWrapper]
    let indexPath: IndexPath
    
    init(comment: Thing, indexPath: IndexPath, depth: Int = 0, children: [CommentWrapper] = []) {
        self.depth = depth
        self.comment = comment
        self.children = children
        self.indexPath = indexPath
    }
}

class CommentThreadTableAdapter {
    let comments: [Thing]
    var flattenedComments: [CommentWrapper]
    var hiddenPaths = Set<IndexPath>() {
        didSet {
            
        }
    }
    
    init(comments: [Thing]) {
        self.comments = comments
        self.flattenedComments = CommentThreadTableAdapter.flattenedComments(with: comments)
    }
    
    private class func flattenedComments(with comments: [Thing], hiddenPaths: Set<IndexPath>? = nil) -> [CommentWrapper] {
        var flattened = [CommentWrapper]()
        for (index, comment) in comments.enumerated() {
            flattened.append(CommentWrapper(comment: comment, indexPath: IndexPath(indexes: [index])))
        }
        
        return flattened
    }
    
    var numberOfComments: Int {
        get { return self.flattenedComments.count }
    }
    
    func commentAt(index: Int) -> CommentWrapper {
        return self.flattenedComments[index]
    }
}
