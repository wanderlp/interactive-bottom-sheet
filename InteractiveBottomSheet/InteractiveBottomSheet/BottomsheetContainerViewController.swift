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
        self.configuration = bottomSheetConfiguration
        
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
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {}
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.delegate = self
        pan.addTarget(self, action: #selector(handlePan)) // Connect the panGesture
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
        // 1 - Add both the contentViewController and bottomSheetViewController
        //     to the container using addChild() method
        self.addChild(contentViewController)
        self.addChild(bottomSheetViewController)
        
        // 2 - Add the root views of contentViewController and bottomSheetViewController
        //     to the root view of the container
        self.view.addSubview(contentViewController.view)
        self.view.addSubview(bottomSheetViewController.view)
        
        // 3 - Add the panGesture to the root view of the bottomSheetViewController
        bottomSheetViewController.view.addGestureRecognizer(panGesture)
        
        // 4 - Apply translateAutoresizingMaskIntoConstraint = false. This is required
        //     because we are creating our UI programmatically using constraints.
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        bottomSheetViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 5 - Set constraints for the contentViewControllers's view
        NSLayoutConstraint.activate([
            contentViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            contentViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            contentViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        // 6 - Call the didMove(to:) method to inform the contentViewController that it
        //     was added to the parent. The parent is the BottomSheetContainerViewController
        contentViewController.didMove(toParent: self)
        
        // 7 - Set the top constraint of the bottom sheet to be aligned to the bottomAnchor
        //     of the container's view. We also add an offset of the BottomSheetConfiguration
        //     to make the bottom sheet a little bit visible in the bottom of the screen
        topConstraint = bottomSheetViewController.view.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -configuration.initialOffset)
        
        // 8 - Set all the bottom sheet's constraints and activate them
        NSLayoutConstraint.activate([
            bottomSheetViewController.view.heightAnchor.constraint(equalToConstant: configuration.height),
            bottomSheetViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            bottomSheetViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            topConstraint
        ])
        
        // 9 - Call the didMove(to:) method on the bottomSheetViewController to inform it
        //     that it was added to the bottomSheetContainerviewController
        bottomSheetViewController.didMove(toParent: self)
    }
    
    // MARK: - Bottom Sheet Actions
    // Moves the bottom sheet to its full height and sets the
    // BottomSheetState to .full. If animated is set to true,
    // it performs the movement with animation.
    public func showBottomSheet(animated: Bool = true) {
        self.topConstraint.constant = -configuration.height
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.state = .full
            })
        } else {
            self.view.layoutIfNeeded()
            self.state = .full
        }
    }
    
    // This method moves the bottom sheet to its initial point
    // and sets the BottomSheetState to .initial. If animated, it
    // performs a nice spring animation.
    public func hideBottomSheet(animated: Bool = true) {
        self.topConstraint.constant = -configuration.initialOffset
        
        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: [.curveEaseOut],
                           animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.state = .initial
            })
        } else {
            self.view.layoutIfNeeded()
            self.state = .initial
        }
    }
}
