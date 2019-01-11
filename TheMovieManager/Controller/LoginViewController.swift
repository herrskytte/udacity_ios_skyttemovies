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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = "ghostgob"
        passwordTextField.text = "aphiw3au"
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        TMDBClient.getRequestToken(completion: requestTokenHandler(success:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        TMDBClient.getRequestToken { (success, error) in
            if(success){
                UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options: [:], completionHandler: nil)
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
        if(success){
            self.performSegue(withIdentifier: "completeLogin", sender: nil)
        }
    }
}
