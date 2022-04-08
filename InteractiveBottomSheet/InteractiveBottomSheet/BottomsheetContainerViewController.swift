//
//  BottomsheetContainerViewController.swift
//  InteractiveBottomSheet
//
//  Created by Wanderson López on 8/04/22.
//

import UIKit

open class BottomSheetContainerViewController<Content: UIViewController, BottomSheet: UIViewController>: UIViewController {

    // MARK: - Children
    let contentViewController: Content
    let bottomSheetViewController: BottomSheet
}
