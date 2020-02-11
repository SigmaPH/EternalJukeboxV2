//
//  ViewController.swift
//  SpotifyWebAPI
//
//  Created by  on 2/11/20.
//  Copyright © 2020 SpotifyWebAPI. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation

class ViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    //based off of app delegage defualt once logged in
    var auth = SPTAuth.defaultInstance()
    var session : SPTSession!
    var player : SPTAudioStreamingController?
    var loginURL : URL?
    
    //Button Outlet for login
    @IBOutlet weak var LogButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAfterFistLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
    }
    func setup () {
        let redirectURL = "SpotifyWebAPI://SpotifyAuthentication"    //URL for redirect from SPT DEV DASHBOARD
        let clientID = "8866119a188a432eae96083ed34c857b"            //This is also the SPT DEV DASHBOARD
        auth?.redirectURL = URL(string: redirectURL)
        auth?.clientID = "8866119a188a432eae96083ed34c857b"
        auth?.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginURL = auth?.spotifyAppAuthenticationURL()
    }
    func initalizePlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player?.start(withClientId: auth?.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    @objc func updateAfterFistLogin() {
        let userDefaults  = UserDefaults.standard
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let FirstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = FirstTimeSession
            initalizePlayer(authSession: session)
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("Logged in! TEST")
    }
    
    

    //login button Tapped Action
    @IBAction func LoginTapped(_ sender: Any) {
        if UIApplication.shared.openURL(loginURL!){
            if (auth?.canHandle(auth!.redirectURL))! {
                //to do - build in error handling
            }
        }
    }
    
}

