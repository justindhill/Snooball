//
//  LinkType.swift
//  Snooball
//
//  Created by Justin Hill on 3/13/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import reddift

enum LinkType {
    case selfPost
    case image
    case webLink
    
    init?(link: Link) {
        self = .selfPost
    }
}

extension Link {
    var linkType: LinkType? {
        get { return LinkType(link: self) }
    }
}
