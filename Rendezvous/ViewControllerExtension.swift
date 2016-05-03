//
//  ViewControllerExtension.swift
//  Rendezvous
//
//  Created by Steven Zheng on 4/30/16.
//  Copyright © 2016 szzheng. All rights reserved.
//

import UIKit

extension UIViewController {
    
    
    func displayActivityIndicator(activityIndicator: UIActivityIndicatorView) {
        //activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
}
