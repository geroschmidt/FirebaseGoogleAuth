//
//  AuthViewController.swift
//  Networking-Firebase
//
//  Created by Geronimo Schmidt on 06/03/2023.
//

import UIKit
import Firebase
import FirebaseAnalytics
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class AuthViewController: UIViewController {
    
    //MARK: IBOULETS
    
    
    @IBOutlet weak var authStackView: UIStackView!
    
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var registrarButton: UIButton!
    @IBOutlet weak var accederButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        title = "Autentication"
        
        // Analytics event
        
        Analytics.logEvent("InitScreen", parameters: ["message":"Integracion de firebase completa"])
        
        // Comprobar autenticacion
        
        let defaults = UserDefaults.standard
        if let email = defaults.value(forKey: "email") as? String,
            let provider = defaults.value(forKey: "provider") as? String {
            
            authStackView.isHidden = true
            
            self.navigationController?.pushViewController(HomeViewController(email: email, provider: ProviderType.init(rawValue: provider)!), animated: false)
        }
        
        
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authStackView.isHidden = false
    }
    
    //MARK: IBACTIONS

    @IBAction func registrarButtonAction(_ sender: Any) {
        
       if let email = emailTextfield.text, let password = passwordTextfield.text {
            
            Auth.auth().createUser(withEmail: email, password: password) {
                (result, error) in
                
                self.showHome(result: result, error: error, provider: .basic)
            }
        }
    }
    
    @IBAction func accederButtonAction(_ sender: Any) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text {
             
             Auth.auth().signIn(withEmail: email, password: password) {
                 (result, error) in
                 
                 self.showHome(result: result, error: error, provider: .basic)
             }
         }
    }
    
    @IBAction func googleButtonAction(_ sender: Any) {
        Task { @MainActor in
            await signInWithGoogle()
        }
        
        self.navigationController?.pushViewController(HomeViewController(email: "geroschmidt4@gmail.com", provider: .google), animated: true)
    }
    
    @IBAction func facebookButtonAction(_ sender: Any) {
        
        let loginManager = LoginManager()
        loginManager.logOut()
         
        
    }
    
    
    //MARK: Functions
    
    private func showHome(result: AuthDataResult?, error: Error?, provider: ProviderType){
        
        if let result = result, error == nil {
            
            self.navigationController?.pushViewController(HomeViewController(email: result.user.email!, provider: .basic), animated: true)
            
        } else {
            
            let alertController = UIAlertController(title: "Error", message: "Se ha producido un error de autenticacion mediante \(provider.rawValue).", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            
            self.present(alertController,animated: true,completion: nil)
        }
    }
    
    
}



extension AuthViewController {
    
    func signInWithGoogle() async -> Bool {
        // Google Auth
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller")
            return false
        }
        
        do{
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                print("ID Token missing")
                return false
            }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print("User\(firebaseUser.uid), signed in with email \(firebaseUser.email ?? "Unknow")")
            return true
        }
        catch {
            print(error.localizedDescription)
            return false
        }
    }
    
}
