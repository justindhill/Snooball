//
//  LinkListViewController.swift
//  Snooball
//
//  Created by Justin Hill on 2/25/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import reddift

class LinkListViewController: ASViewController<ASDisplayNode>, ASTableDelegate, ASTableDataSource {
    
    var subreddit: Subreddit
    var listingFetcher: ListingFetcher<Link>
    
    init() {
        self.subreddit = Subreddit(subreddit: "popular")
        self.listingFetcher = ListingFetcher(subreddit: self.subreddit, sortOrder: .hot)
        super.init(node: ASTableNode())
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        self.tableNode.view.separatorStyle = .none
        
        self.title = self.subreddit.displayName
    }
    
    var tableNode: ASTableNode {
        get { return self.node as! ASTableNode }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.listingFetcher.things.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cell = LinkCellNode(link: self.listingFetcher.things[indexPath.row])
        
        return cell
    }
    
    func tableNode(_: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        let priorCount = self.listingFetcher.things.count
        self.listingFetcher.fetchMore { [weak self] (error, newLinkCount) in
            if let error = error {
                print(error)
                context.completeBatchFetching(false)
                return
            }
            
            var indexPaths = [IndexPath]()
            for index in (priorCount..<priorCount + newLinkCount) {
                indexPaths.append(IndexPath(row: index, section: 0))
            }
            
            if priorCount == 0 {
                self?.tableNode.reloadData()
            } else {
                self?.tableNode.insertRows(at: indexPaths, with: .none)
            }
            
            context.completeBatchFetching(true)
        }
    }
    
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return (self.listingFetcher.moreAvailable && !self.listingFetcher.fetching)
    }
}

