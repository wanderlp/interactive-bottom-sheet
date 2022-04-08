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
open class BottomSheetContainerViewController<Content: UIViewController, BottomSheet: UIViewController>: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Initialization
    public init(contentViewController: Content,
                bottomSheetViewController: BottomSheet,
                bottomSheetConfiguration: BottomSheetConfiguration) {
        self.contentViewController = contentViewController
        self.bottomSheetViewController = bottomSheetViewController
        self.configuraton = bottomSheetConfiguration
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: - Children
    let contentViewController: Content
    let bottomSheetViewController: BottomSheet
    
    // MARK: - Configuration
    // BottomSheetConfiguration struct has the total height
    // and the initial offset of the bottom sheet.
    public struct BottomSheetConfiguration {
        let height: CGFloat
        let initialOffset: CGFloat
    }
    
    private let configuraton: BottomSheetConfiguration
    
    // MARK: - State
    // BottomSheetState manages the state of the bottom
    // sheet.
    public enum BottomSheetState {
        case initial
        case full
    }
    
    var state: BottomSheetState = .initial
    
    
    // MARK: - Properties that handle interaction and animation.
    lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.delegate = self
        return pan
    }()
    
    // The bottom sheet view controller will move around the
    // screen, so we need to get a hold of the top constraint
    // of its view. For this reason, we have the topConstraint
    // property, which we will repeatedly change and animate
    // accordingly.
    private var topConstraint = NSLayoutConstraint()
    
    // MARK: - UIGestureRecognizer Delegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
