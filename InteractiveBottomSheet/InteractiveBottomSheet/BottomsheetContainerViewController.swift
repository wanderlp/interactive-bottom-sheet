//
//  BottomsheetContainerViewController.swift
//  InteractiveBottomSheet
//
//  Created by Wanderson López on 8/04/22.
//

import UIKit

open class BottomSheetContainerViewController<Content: UIViewController, BottomSheet: UIViewController>: UIViewController {
    
    // MARK: - Initialization
    public init(contentViewController: Content, bottomSheetViewController: BottomSheet) {
        self.contentViewController = contentViewController
        self.bottomSheetViewController = bottomSheetViewController
        
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Children
    let contentViewController: Content
    let bottomSheetViewController: BottomSheet
}
