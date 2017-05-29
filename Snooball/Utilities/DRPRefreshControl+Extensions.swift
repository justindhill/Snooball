//
//  DRPRefreshControl+Extensions.swift
//  Snooball
//
//  Created by Justin Hill on 5/29/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import DRPLoadingSpinner

extension DRPRefreshControl {
    class func customizedRefreshControl() -> DRPRefreshControl {
        let refreshControl = DRPRefreshControl()
        refreshControl.loadingSpinner.drawCycleDuration = 0.65;
        refreshControl.loadingSpinner.rotationCycleDuration = 1.15;
        refreshControl.loadingSpinner.drawTimingFunction = DRPLoadingSpinnerTimingFunction.sharpEaseInOut()
        
        return refreshControl
    }
}
