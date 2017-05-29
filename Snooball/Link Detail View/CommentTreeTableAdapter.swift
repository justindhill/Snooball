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
    let indexPath: IndexPath
    
    init(comment: Thing, indexPath: IndexPath, depth: Int = 0) {
        self.depth = depth
        self.comment = comment
        self.indexPath = indexPath
    }
}

class CommentThreadTableAdapter {
    enum ChangeType {
        case delete
        case insert
        case update
    }
    
    struct ChangeSet: CustomStringConvertible {
        let type: ChangeType
        let indexPaths: [IndexPath]
        
        init(type: ChangeType, indexPaths: [IndexPath]) {
            self.type = type
            self.indexPaths = indexPaths
        }
        
        var description: String {
            get {
                return "\(self.type): \(self.indexPaths)"
            }
        }
    }
    
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
    
    private func numberOfVisibleDescendantsInSubtree(root: Comment) -> Int {
        var visibleDescendants = 0
        for child in root.replies.children {
            if let child = child as? Comment, !self.hiddenCommentIds.contains(child.id) {
                visibleDescendants += 1
                visibleDescendants += self.numberOfVisibleDescendantsInSubtree(root: child)
            } else if child is More {
                visibleDescendants += 1
            }
        }
        
        return visibleDescendants
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
    
    func toggleHidingForCommentAt(indexPath: IndexPath) -> [ChangeSet] {
        guard let rootComment = self.commentAt(indexPath: IndexPath(row: 0, section: indexPath.section)).comment as? Comment else {
            assertionFailure("Couldn't find the root comment for the comment we're meant to toggle")
            return []
        }
        
        var changesets = [
            ChangeSet(type: .update, indexPaths: [indexPath])
        ]
        
        guard let comment = self.commentAt(indexPath: indexPath).comment as? Comment else {
            return []
        }
        
        if self.hiddenCommentIds.contains(comment.id) {
            self.hiddenCommentIds.remove(comment.id)
        } else {
            self.hiddenCommentIds.insert(comment.id)
        }
        
        let numberOfAffectedChildren = self.numberOfVisibleDescendantsInSubtree(root: comment)
        
        if numberOfAffectedChildren > 0 {
            let indexOfFirstChild = indexPath.row + 1
            let indexPathRange = (indexOfFirstChild..<indexOfFirstChild + numberOfAffectedChildren).map { (row) -> IndexPath in
                return IndexPath(row: row, section: indexPath.section)
            }
            
            if self.hiddenCommentIds.contains(comment.id) {
                changesets.append(ChangeSet(type: .delete, indexPaths: indexPathRange))
            } else {
                changesets.append(ChangeSet(type: .insert, indexPaths: indexPathRange))
            }
        }
        
        self.flattenedComments[indexPath.section] = self.commentTreeFor(rootComment: rootComment, sectionNumber: indexPath.section)
        
        return changesets
    }
}
