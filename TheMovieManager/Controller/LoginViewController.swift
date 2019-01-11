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
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        TMDBClient.getRequestToken(completion: requestTokenHandler(success:error:))
        //performSegue(withIdentifier: "completeLogin", sender: nil)
    }
    
    @IBAction func loginViaWebsiteTapped() {
        TMDBClient.getRequestToken { (success, error) in
            if(success){
                
            }
        }
    }
    
    func requestTokenHandler(success: Bool, error: Error?){
        print("requesttoken \(success)")
        print(error ?? "no Error")
        print(TMDBClient.Auth.requestToken)
        if(success){
            DispatchQueue.main.async {
                TMDBClient.login(un: self.emailTextField.text ?? "", pw: self.passwordTextField.text ?? "", completion: self.loginHandler(success:error:))
            }
        }
    }
    
    func loginHandler(success: Bool, error: Error?){
        print("login \(success)")
        print(error ?? "no Error")
        print(TMDBClient.Auth.requestToken)
        if(success){
            TMDBClient.getSessionId(completion: getSessionHandler(success:error:))
        }
    }
    
    func getSessionHandler(success: Bool, error: Error?){
        print("session \(success)")
        print(error ?? "no Error")
        print(TMDBClient.Auth.sessionId)
        if(success){
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
            }
            
        }
    }
}
