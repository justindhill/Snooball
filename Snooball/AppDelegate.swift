//
//  AppDelegate.swift
//  Snooball
//
//  Created by Justin Hill on 2/25/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import UIKit
import reddift

/// Posted when the OAuth2TokenRepository object succeed in saving a token successfully into Keychain.
public let OAuth2TokenRepositoryDidSaveTokenName = Notification.Name(rawValue: "OAuth2TokenRepositoryDidSaveToken")

/// Posted when the OAuth2TokenRepository object failed to save a token successfully into Keychain.
public let OAuth2TokenRepositoryDidFailToSaveTokenName = Notification.Name(rawValue: "OAuth2TokenRepositoryDidFailToSaveToken")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var session: Session?
    
    class var shared: AppDelegate { get { return UIApplication.shared.delegate as! AppDelegate } }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = UINavigationController(rootViewController: LinkListViewController())
        window?.makeKeyAndVisible()
        
        if let name = UserDefaults.standard.string(forKey: "name") {
            do {
                let token = try OAuth2TokenRepository.token(of: name)
                session = Session(token: token)
            } catch { print(error) }
        } else {
            do {
                try OAuth2Authorizer.sharedInstance.challengeWithAllScopes()
            } catch {
                print(error)
            }
        }
        
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return OAuth2Authorizer.sharedInstance.receiveRedirect(url, completion: {(result) -> Void in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let token):
                DispatchQueue.main.async(execute: { [weak self] () -> Void in
                    do {
                        try OAuth2TokenRepository.save(token: token, of: token.name)
                        UserDefaults.standard.set(token.name, forKey: "name")
                        self?.session = Session(token: token)
                        NotificationCenter.default.post(name: OAuth2TokenRepositoryDidSaveTokenName, object: nil, userInfo: nil)
                    } catch {
                        NotificationCenter.default.post(name: OAuth2TokenRepositoryDidFailToSaveTokenName, object: nil, userInfo: nil)
                        print(error)
                    }
                })
            }
        })
    }
}

