//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = "ghostgob"
        passwordTextField.text = "aphiw3au"
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        setLoggingIn(true)
        TMDBClient.getRequestToken(completion: requestTokenHandler(success:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        setLoggingIn(true)
        TMDBClient.getRequestToken { (success, error) in
            if(success){
                UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
    }
    
    func requestTokenHandler(success: Bool, error: Error?){
        print("requesttoken \(success)")
        if(success){
            TMDBClient.login(un: self.emailTextField.text ?? "", pw: self.passwordTextField.text ?? "", completion: self.loginHandler(success:error:))
        }
    }
    
    func loginHandler(success: Bool, error: Error?){
        print("login \(success)")
        if(success){
            TMDBClient.getSessionId(completion: getSessionHandler(success:error:))
        }
    }
    
    func getSessionHandler(success: Bool, error: Error?){
        print("session \(success)")
        setLoggingIn(false)
        if(success){
            self.performSegue(withIdentifier: "completeLogin", sender: nil)
        }
    }
    
    func setLoggingIn(_ yes: Bool){
        if yes{
             activityIndicator.startAnimating()
        }
        else{
            activityIndicator.stopAnimating()
        }
       
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
