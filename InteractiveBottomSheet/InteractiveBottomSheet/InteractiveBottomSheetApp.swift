//
//  InteractiveBottomSheetApp.swift
//  InteractiveBottomSheet
//
//  Created by Wanderson López on 8/04/22.
//

//import SwiftUI
//
//@main
//struct InteractiveBottomSheetApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.rootViewController = WelcomeContainerViewController (
            contentViewController: HelloViewController(),
            bottomSheetViewController: MyCustomViewController(),
            bottomSheetConfiguration: .init(
                height: UIScreen.main.bounds.height * 0.8,
                initialOffset: 60 + window!.safeAreaInsets.bottom
            )
        )
        window?.makeKeyAndVisible()
        
        return true
    }
}
