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

fileprivate let SECTION_HEADER = 0
fileprivate let SECTION_COMMENTS = 1

class LinkDetailViewController: ASViewController<ASDisplayNode>, ASTableDelegate, ASTableDataSource {
    
    let link: Link
    var commentTableAdapter: CommentThreadTableAdapter? = nil
    
    init(link: Link) {
        self.link = link
        super.init(node: ASTableNode())
        self.applyLink(link: link)
        
        do {
            try AppDelegate.shared.session?.getArticles(link, sort: .top, comments: nil, depth: 3, limit: 120, context: nil, completion: { [weak self] (result) in
                if let comments = result.value?.1.children {
                    let commentAdapter = CommentThreadTableAdapter(comments: comments)
                    self?.commentTableAdapter = commentAdapter
                    
                    DispatchQueue.main.async {
                        self?.insertCommentsFrom(adapter: commentAdapter)
                    }
                }
            })
        } catch {
            // TODO: empty/error state
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tableNode: ASTableNode {
        get { return self.node as! ASTableNode }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        self.tableNode.view.separatorStyle = .none
    }
    
    func applyLink(link: Link) {
        self.title = "\(link.numComments) comments"
    }
    
    func insertCommentsFrom(adapter: CommentThreadTableAdapter) {
        let indices = 0..<adapter.numberOfComments
        let indexPaths = indices.map { (index) -> IndexPath in
            return IndexPath(row: index, section: SECTION_COMMENTS)
        }
        
        self.tableNode.performBatch(animated: false, updates: { 
            self.tableNode.insertRows(at: indexPaths, with: .fade)
        }, completion: nil)
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 2
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_HEADER {
            return 1
        } else if section == SECTION_COMMENTS {
            return self.commentTableAdapter?.numberOfComments ?? 0
        }
        
        return 0
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
        } else if indexPath.section == SECTION_COMMENTS {
            guard let adapter = self.commentTableAdapter else {
                fatalError("Somehow got a request for a comment node even though we have no comments...")
            }
            
            let comment = adapter.commentAt(index: indexPath.row)
            
            if let rawComment = comment.comment as? Comment {
                return CommentCell(comment: rawComment)
            } else if let more = comment.comment as? More {
                let node = ASTextCellNode()
                node.text = "\(more.count) more comments"
                return node
            }
        }
        
        return ASCellNode()
    }
    
    func tableNode(_ tableNode: ASTableNode, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
