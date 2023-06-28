//
//  Utilities.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 17.05.2023.
//

import UIKit

final class Utilities {
    static let shared = Utilities()
    
    private init() {}
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller: UIViewController? = {
            if let controller = controller {
                return controller
            } else {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    return nil
                }
                return windowScene.windows.filter { $0.isKeyWindow }.first?.rootViewController
            }
        }()
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
}
