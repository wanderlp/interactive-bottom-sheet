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
    
    private let configuration: BottomSheetConfiguration
    
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
    
    // Children view controllers
    private func setupUI() {
        // 1
        self.addChild(contentViewController)
        self.addChild(bottomSheetViewController)
        
        // 2
        self.view.addSubview(contentViewController.view)
        self.view.addSubview(bottomSheetViewController.view)
        
        // 3
        bottomSheetViewController.view.addGestureRecognizer(panGesture)
        
        // 4
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        bottomSheetViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 5
        NSLayoutConstraint.activate([
            contentViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            contentViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            contentViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        // 6
        contentViewController.didMove(toParent: self)
        
        // 7
        topConstraint = bottomSheetViewController.view.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -configuration.initialOffset)
        
        // 8
        NSLayoutConstraint.activate([
            bottomSheetViewController.view.heightAnchor.constraint(equalToConstant: configuration.height),
            bottomSheetViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            bottomSheetViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            topConstraint
        ])
        
        // 9
        bottomSheetViewController.didMove(toParent: self)
    }
}
