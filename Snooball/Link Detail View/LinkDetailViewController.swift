//
//  LinkDetailViewController.swift
//  Snooball
//
//  Created by Justin Hill on 3/13/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import AsyncDisplayKit
import reddift

fileprivate let SECTION_HEADER = 0
fileprivate let SECTION_COMMENTS = 1

class LinkDetailViewController: ASViewController<ASDisplayNode>, ASTableDelegate, ASTableDataSource {
    
    let link: Link
    
    init(link: Link) {
        self.link = link
        super.init(node: ASTableNode())
        self.applyLink(link: link)
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
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 2
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_HEADER {
            return 1
        } else if section == SECTION_COMMENTS {
            return 0
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
        }
        
        return ASCellNode()
    }
    
    func tableNode(_ tableNode: ASTableNode, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_HEADER {
            return false
        }
        
        return true
    }
}
