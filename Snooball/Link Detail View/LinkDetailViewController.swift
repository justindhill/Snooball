//
//  LinkDetailViewController.swift
//  Snooball
//
//  Created by Justin Hill on 3/13/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import AsyncDisplayKit
import reddift
import TSMarkdownParser
import DRPLoadingSpinner

fileprivate let SECTION_HEADER = 0
fileprivate let SECTION_COMMENTS = 1

class LinkDetailViewController: ASViewController<ASDisplayNode>, ASTableDelegate, ASTableDataSource {
    
    let link: Link
    var commentTableAdapter: CommentThreadTableAdapter? = nil
    
    let refreshControl = DRPRefreshControl()
    
    init(link: Link) {
        self.link = link
        super.init(node: ASTableNode())
        self.applyLink(link: link)
        
        self.loadThread()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tableNode: ASTableNode {
        get { return self.node as! ASTableNode }
    }
    
    func loadThread() {
        do {
            try AppDelegate.shared.session?.getArticles(link, sort: .top, comments: nil, depth: 8, limit: 120, context: nil, completion: { [weak self] (result) in
                if let comments = result.value?.1.children {
                    let commentAdapter = CommentThreadTableAdapter(comments: comments)
                    self?.commentTableAdapter = commentAdapter
                    
                    DispatchQueue.main.async {
                        self?.tableNode.reloadData(completion: { 
                            self?.refreshControl.endRefreshing()
                        })
                    }
                }
            })
        } catch {
            self.refreshControl.endRefreshing()
            // TODO: empty/error state
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        self.tableNode.view.separatorStyle = .none
        
        self.refreshControl.loadingSpinner.drawCycleDuration = 0.65;
        self.refreshControl.loadingSpinner.rotationCycleDuration = 1.15;
        self.refreshControl.loadingSpinner.drawTimingFunction = DRPLoadingSpinnerTimingFunction.sharpEaseInOut()
        self.refreshControl.add(to: self.tableNode) { [weak self] in
            self?.loadThread()
        }
    }
    
    func applyLink(link: Link) {
        self.title = "\(link.numComments) comments"
    }
    
    private func commentIndexPathWith(tableIndexPath indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row, section: indexPath.section - 1)
    }
//    
//    func insertCommentsFrom(adapter: CommentThreadTableAdapter) {
//        let indices = 0..<adapter.numberOfComments
//        let indexPaths = indices.map { (index) -> IndexPath in
//            return IndexPath(row: index, section: SECTION_COMMENTS)
//        }
//        
//        self.tableNode.performBatch(animated: false, updates: { 
//            self.tableNode.insertRows(at: indexPaths, with: .fade)
//        }, completion: nil)
//    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1 + (self.commentTableAdapter?.numberOfRootComments ?? 0)
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_HEADER {
            return 1
        } else {
            return self.commentTableAdapter?.numberOfChildrenForRootCommentAtIndex(index: section - 1) ?? 0
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if indexPath.section == SECTION_HEADER {
            guard let linkType = link.linkType else {
                fatalError("This link did not yield a valid link type")
            }
            
            switch linkType {
            case .selfPost:
                return SelfLinkDetailHeader(link: self.link)
            default:
                fatalError("Link type \(linkType) is not supported")
            }
        } else {
            guard let adapter = self.commentTableAdapter else {
                fatalError("Somehow got a request for a comment node even though we have no comments...")
            }
            
            let comment = adapter.commentAt(indexPath: commentIndexPathWith(tableIndexPath: indexPath))
            
            if let rawComment = comment.comment as? Comment {
                let isCollapsed = self.commentTableAdapter?.isCommentHidden(rawComment) ?? false
                let commentContent = CommentCellContentWrapperNode(comment: rawComment, collapsed: isCollapsed)
                return CommentCell(contentNode: commentContent, depth: comment.depth)
                
            } else if let more = comment.comment as? More {
                let textNode = ASTextCellNode()
                textNode.text = "\(more.count) more comments"
                return CommentCell(contentNode: textNode, depth: comment.depth)
            }
        }
        
        return ASCellNode()
    }
    
    func tableNode(_ tableNode: ASTableNode, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_HEADER {
            return false
        }
        
        return true
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        
        guard let changesets = self.commentTableAdapter?.toggleHidingForCommentAt(indexPath: commentIndexPathWith(tableIndexPath: indexPath)) else {
            return
        }
        
        tableNode.performBatch(animated: true, updates: {
            for changeset in changesets {
                let adjustedIndexPaths = changeset.indexPaths.map({ (indexPath) -> IndexPath in
                    return IndexPath(row: indexPath.row, section: indexPath.section + 1)
                })
                
                switch changeset.type {
                    case .delete: tableNode.deleteRows(at: adjustedIndexPaths, with: .fade)
                    case .insert: tableNode.insertRows(at: adjustedIndexPaths, with: .fade)
                    case .update: tableNode.reloadRows(at: adjustedIndexPaths, with: .fade)
                }
            }
        }, completion: nil)
    }
}
