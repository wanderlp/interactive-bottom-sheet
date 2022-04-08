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
    
    // Works directly with the UIPanGestureRecognizer.
    // Allows move the bottom sheet with our finger up and down.
    // When we stop moving it, take into account the current BottomSheetState,
    // translation, and velocity in the y direction. If the state is .full, check if
    // we have the botom sheet translation of at least half of its height. If this is
    // true, we run the hideBottomSheet(animated:) method. Otherwise, we return
    // it to the full height. Also, we need to chek if the magnitude of the velocity
    // is greater than 1,000. If this give us true, hide the bottom sheet. In other
    // cases, revert it to the full height. Similarly, if the state is .initial, check
    // the translation and velocity mangnitudes and react accordingly.
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: bottomSheetViewController.view)
        let velocity = sender.velocity(in: bottomSheetViewController.view)
        
        let yTranslationMagnitude = translation.y.magnitude
        
        switch sender.state {
            case .began, .changed:
                if self.state == .full {
                    // 1 - Assert that the user scroll downward. The bottom
                    //     sheet is already at its full height; no upward
                    //     scrolling is allowed
                    guard translation.y > 0 else { return }
                    
                    // 2 - Change the topConstraint's constant to match the
                    //     current position of the user's finger. For example,
                    //     if the total height of the bottom sheet is 500 points
                    //     and the user has scrolled 100 points, we substract 100
                    //     from 5000 and obtain 400 points. So we set the constant
                    //     to -400, because this is an offset from the bottom of
                    //     the contaiiner's view
                    topConstraint.constant = -(configuration.height - yTranslationMagnitude)
                    
                    // 3 - Update the root view to show the constraint's change
                    self.view.layoutIfNeeded()
                } else {
                    // 4 - Calculate the new constant by using the BottomSheetConfiguration's
                    //     initialOffset and the translation magnitude. For example,
                    //     if the initial offset was 80 points and the user has scrolled
                    //     200 points, we obtain 280 points. This means we would need
                    //     to place the bottom sheet 280 points from the bottom of the
                    //     container's view
                    let newConstant = -(configuration.initialOffset + yTranslationMagnitude)
                    
                    // 5 - Assert that the user scrolls upward. Because the bottom
                    //     sheet is at its initial point, no downward scrolling is
                    //     allowed
                    guard translation.y < 0 else { return }
                    
                    // 6 - Assert that the magnitude of the newConstant is less than
                    //     the full height of the bottom sheet. This is to prevent
                    //     the bottom sheet from moving further than its maximum
                    //     height point
                    guard newConstant.magnitude < configuration.height else {
                        self.showBottomSheet()
                        return
                    }
                    
                    // 7 - Set the resulting constant
                    topConstraint.constant = newConstant
                    
                    // 8 - Update the root view to show the constraint's change
                    self.view.layoutIfNeeded()
                }
            case .ended {
                if self.state == .full {
                    // 1 - Check if the user has tried to move the bottom sheet
                    //     upwards. If this is true, bottom sheet should remain
                    //     shown
                    if velocity.y < 0 {
                        selft.showBottomSheet()
                    } else if yTranslationMagnitude >= configuration.height / 2 || velocity.y > 1000 {
                        // 2 - If the user moved the bottom sheet more than half
                        //     or its maximum height, or the y velocity is higher
                        //     than 1,000, then we hide the bottom sheet
                        self.hideBottomSheet()
                    }
                    else {
                        // 3 - In all other cases, keep the sheet shown
                        self.showBottomSheet()
                    }
                }
                else {
                    // 4 - Check if the user has moved the bottom sheet at least
                    //     half of its maximum height, or the y velocity is less
                    //     than -1,000
                    if yTranslationMagnitude >= configuration.height / 2 || velocity.y < -1000 {
                        // 5 - If is true, show the bottom sheet
                        self.showBottomSheet()
                    }
                    else {
                        // 6 - Otherwise, hide the bottom sheet
                        self.hideBottomSheet()
                    }
                }
            }
            case .failed {
                if self.stat == .full {
                    self.showBottomSheet()
                }
                else {
                    self.hideBottomSheet()
                }
            }
            default: break
        }
    }
}
