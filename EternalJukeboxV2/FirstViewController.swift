//
//  FirstViewController.swift
//  EternalJukeboxV2
//
//  Created by Bryce Harty on 1/28/20.
//  Copyright © 2020 OrangeTeam. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    fileprivate let SpotifyClientID = "d9f3190f802641938b898e9a418faf9e"
    fileprivate let SpotifyRedirectURI = URL(string: "EternalJukeboxV2://SpotifyAuthentication")!
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI)
        
        configuration.playURI = ""
        
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        
        return configuration
    }()
    
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
    }()

    fileprivate var lastPlayerState: SPTAppRemotePlayerState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    // MARK: -UI Element Links to Function
    @IBAction func LoginButton(_ sender: Any) {
    let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate]
     
    if #available(iOS 11, *) {
               // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
        sessionManager.initiateSession(with: scope, options: .clientOnly)
    } else {
               // Use this on iOS versions < 11 to use SFSafariViewController
        sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
           }
    }
    
    @IBAction func PlayPauseButton(_ sender: Any) {
        //if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
           //     appRemote.playerAPI?.resume(nil)
           // } else {
         //       appRemote.playerAPI?.pause(nil)
          //  }
        }
    
    
    
    // MARK: - SPTSessionManagerDelegate
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        appRemote.connectionParameters.accessToken = session.accessToken
        appRemote.connect()
    }
    
    // MARK: -SPTAppRemoteDelegate
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        //updateViewBasedOnConnected()
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print("Error subscribing to player state:" + error.localizedDescription)
            }
        })
        ///fetchPlayerState()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        //updateViewBasedOnConnected()
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        //updateViewBasedOnConnected()
        lastPlayerState = nil
    }
    
    //MARK: - SPTAppRemotePlayerAPIDelegate
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        //update(playerState: playerState)
    }
    
    //MARK: -Private Helpers
    
    fileprivate func presentAlertController(title: String, message: String, buttonTitle: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        controller.addAction(action)
        present(controller, animated: true)
    }

}
