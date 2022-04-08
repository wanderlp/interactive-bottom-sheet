//
//  BottomsheetContainerViewController.swift
//  InteractiveBottomSheet
//
//  Created by Wanderson López on 8/04/22.
//

import UIKit

// Content and BottomSheet types have to be
// UIViewControllers, which means we will be
// abe to specify any custom UIViewController.
open class BottomSheetContainerViewController<Content: UIViewController, BottomSheet: UIViewController>: UIViewController {
    
    // MARK: - Initialization
    public init(contentViewController: Content,
                bottomSheetViewController: BottomSheet,
                bottomSheetconfiguration: BottomSheetConfiguration) {
        self.contentViewController = contentViewController
        self.bottomSheetViewController = bottomSheetViewController
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: - Children
    let contentViewController: Content
    let bottomSheetViewController: BottomSheet
    
    // MARK: - Configuration
    public struct BottomSheetConfiguration {
        let height: CGFloat
        let initialOffset: CGFloat
    }
    
    private let configuraton: BottomSheetConfiguration
}
