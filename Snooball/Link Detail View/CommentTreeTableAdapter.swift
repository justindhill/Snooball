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
    var flattenedComments: [[CommentWrapper]]
    let comments: [Thing]
    private var hiddenCommentIds = Set<String>()
    
    init(comments: [Thing]) {
        self.comments = comments
        self.flattenedComments = []
        
        var commentTrees = [[CommentWrapper]]()
        for comment in comments {
            if let comment = comment as? Comment {
                commentTrees.append(self.commentTreeFor(rootComment: comment, sectionNumber: commentTrees.count))
            }
        }
        
        self.flattenedComments = commentTrees
    }
    
    private func commentTreeFor(rootComment comment: Comment, sectionNumber: Int) -> [CommentWrapper] {
        var commentTree = [CommentWrapper(comment: comment, indexPath: IndexPath(row: 0, section: sectionNumber))]
        
        if !self.hiddenCommentIds.contains(comment.id) {
            commentTree.append(contentsOf: self.flattenedComments(with: comment.replies.children, hiddenPaths: nil, depth: 1, indexOffset: 1))
        }
        
        return commentTree
    }
    
    private func flattenedComments(with comments: [Thing], hiddenPaths: Set<IndexPath>? = nil, depth: Int = 0, indexOffset: Int = 0) -> [CommentWrapper] {
        var flattened = [CommentWrapper]()
        for (index, comment) in comments.enumerated() {
            flattened.append(CommentWrapper(comment: comment, indexPath: IndexPath(indexes: [index + indexOffset]), depth: depth))
            
            if let comment = comment as? Comment, !self.hiddenCommentIds.contains(comment.id) {
                flattened.append(contentsOf: flattenedComments(with: comment.replies.children, hiddenPaths: hiddenPaths, depth: depth + 1))
            }
        }
        
        return flattened
    }
    
    var numberOfRootComments: Int {
        get { return self.flattenedComments.count }
    }
    
    func numberOfChildrenForRootCommentAtIndex(index: Int) -> Int {
        return self.flattenedComments[index].count
    }
    
    func commentAt(indexPath: IndexPath) -> CommentWrapper {
        return self.flattenedComments[indexPath.section][indexPath.row]
    }
    
    func isCommentHidden(_ comment: Comment) -> Bool {
        return self.hiddenCommentIds.contains(comment.id)
    }
    
    func toggleHidingForCommentAt(indexPath: IndexPath) {
        guard let rootComment = self.commentAt(indexPath: IndexPath(row: 0, section: indexPath.section)).comment as? Comment else {
            assertionFailure("Couldn't find the root comment for the comment we're meant to toggle")
            return
        }
        
        let comment = self.commentAt(indexPath: indexPath)
        
        if self.hiddenCommentIds.contains(comment.comment.id) {
            self.hiddenCommentIds.remove(comment.comment.id)
        } else {
            self.hiddenCommentIds.insert(comment.comment.id)
        }
        
        self.flattenedComments[indexPath.section] = self.commentTreeFor(rootComment: rootComment, sectionNumber: indexPath.section)
    }
}
