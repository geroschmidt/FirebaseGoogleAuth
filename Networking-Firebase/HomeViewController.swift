//
//  HomeViewController.swift
//  Networking-Firebase
//
//  Created by Geronimo Schmidt on 06/03/2023.
//

import UIKit
import FirebaseAuth
import Firebase

enum ProviderType: String {
    case basic
    case google
    case facebook
}

class HomeViewController: UIViewController {
    
    //MARK: IBOULETS
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var closeSessionButton: UIButton!
    
    private let email: String
    private let provider: ProviderType
    
    init(email: String, provider: ProviderType){
        self.email = email
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Inicio"
        
        navigationItem.setHidesBackButton(true, animated: false)
        
        emailLabel.text = email
        providerLabel.text = provider.rawValue
        
        // Guardamos datos del usuario
        
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
        defaults.set(provider.rawValue, forKey: "provider")
        defaults.synchronize()
    }
    
    // MARK: - IBACTION
    
    @IBAction func closeSessionAction(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "provider")
        defaults.synchronize()
        
        switch provider {
            
        case .facebook:
            firebaseLogout()
            
        case .basic, .google:
            
            firebaseLogout()
        }
        navigationController?.popViewController(animated: true)
    }
    
    private func firebaseLogout() {
        do{
            try Auth.auth().signOut()
            
            
        } catch {
            //se ha producido un error
        }
    }
    


}
