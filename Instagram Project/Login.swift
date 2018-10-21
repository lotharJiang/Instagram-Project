//
//  Login.swift
//  Instagram Project
//
//  Created by LiuYuHan on 11/10/18.
//  Copyright © 2018 LiuYuHan. All rights reserved.
//


import UIKit



class Login: UIViewController, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITextFieldDelegate {
    
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.placeholder = "Username"
        username.clearButtonMode = .whileEditing
        username.keyboardType = .default
        username.delegate = self
        username.returnKeyType = .next
        username.autocorrectionType = .no
        
        password.placeholder = "Password"
        password.clearButtonMode = .whileEditing
        password.keyboardType = .default
        password.delegate = self
        password.returnKeyType = .done
        password.autocorrectionType = .no
        password.isSecureTextEntry = true
        // Do any additional setup after loading the view.
        
    }

    override func viewDidAppear(_ animated: Bool) {
        //Automatically Login
        let userdefault = UserDefaults.standard
        if (userdefault.string(forKey: "LoginUser") != nil) {
            self.performSegue(withIdentifier: "Login", sender: userdefault.string(forKey: "LoginUser")!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if(password.text == "" && username.text == ""){
            let alert = UIAlertController(title: "Error", message: "userName and passWord can not be empty", preferredStyle: .alert);
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
            });
            alert.addAction(okAction);
            self.present(alert,animated:true,completion:nil)
        }
        
        else if(password.text == ""){
            let alert = UIAlertController(title: "Error", message: "passWord can not be empty", preferredStyle: .alert);
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
            });
            alert.addAction(okAction);
            self.present(alert,animated:true,completion:nil)
        }
        
        else if(username.text == ""){
            let alert = UIAlertController(title: "Error", message: "userName can not be empty", preferredStyle: .alert);
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
            });
            alert.addAction(okAction);
            self.present(alert,animated:true,completion:nil)
        }
        else{
            //HTTP
            let url = NSURL(string:"http://115.146.84.191:3333/api/login")
            let request = NSMutableURLRequest(url:url! as URL);
            request.httpMethod = "POST";
            let postString="\("loginEmail")=\(self.username.text!)&\("loginPassword")=\(self.password.text!)"
            
            request.httpBody = postString.data(using: .utf8);
            
            let task = URLSession.shared.dataTask(with: request as URLRequest){
                data, response, error in
                if let anError = error {
                    DispatchQueue.main.async(execute:{
                    let errorAlert = UIAlertController(title: "Error", message: "error: "+(anError.localizedDescription)+". Please try again", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    errorAlert.addAction(action)
                    self.present(errorAlert,animated: true,completion: nil)
                    })
                }
                if let receiveString = String(data: data!, encoding: String.Encoding.utf8){
                print("Received:"+receiveString)
                if receiveString == "success"{
                    DispatchQueue.main.async(execute:{
                        let userdefault = UserDefaults.standard
                        userdefault.setValue(self.username.text, forKey: "LoginUser")
                        userdefault.synchronize()
                        self.performSegue(withIdentifier: "Login", sender: self.username.text)
                        
                    })
                }
                else{
                    DispatchQueue.main.async(execute:{
                    let errorAlert = UIAlertController(title: "Sorry", message: "error: "+receiveString+". Please try again", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    errorAlert.addAction(action)
                    self.present(errorAlert,animated: true,completion: nil)
                    })
                }
                }
            }
            task.resume()
        }
        //self.performSegue(withIdentifier: "Login", sender: username.text)
    }
    
    @IBAction func signupAction(_ sender: Any) {
        if(password.text == "" && username.text == ""){
            let alert = UIAlertController(title: "Error", message: "userName and passWord can not be empty", preferredStyle: .alert);
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
            });
            alert.addAction(okAction);
            self.present(alert,animated:true,completion:nil)
            
        }else if(username.text == ""){
            let alert = UIAlertController(title: "Error", message: "userName can not be empty", preferredStyle: .alert);
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
            });
            alert.addAction(okAction);
            self.present(alert,animated:true,completion:nil)
            
        }else if(password.text == ""){
            let alert = UIAlertController(title: "Error", message: "passWord can not be empty", preferredStyle: .alert);
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
            });
            alert.addAction(okAction);
            self.present(alert,animated:true,completion:nil)
        }else{
            var receiveString = String()
            let alert = UIAlertController(title: "Please input your password again", message: "If success, the system will automatically login for you.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Sign Up", style: .default, handler: {
                action in
                if let rp = alert.textFields?.first?.text, rp != self.password.text{
                    let alert = UIAlertController(title: "Error", message: "passWord does not match", preferredStyle: .alert);
                    
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                        action in
                    });
                    alert.addAction(okAction);
                    self.present(alert,animated:true,completion:nil)
                }else{
                    //HTTP
                    let url = NSURL(string:"http://115.146.84.191:3333/api/register")
                    let request = NSMutableURLRequest(url:url! as URL);
                    request.httpMethod = "POST";
                    let postString="\("registerEmail")=\(self.username.text!)&\("registerPassword")=\(self.password.text!)"
                    
                    request.httpBody = postString.data(using: .utf8);
                    
                    let task = URLSession.shared.dataTask(with: request as URLRequest){
                        data, response, error in
                        if let anError = error {
                            DispatchQueue.main.async(execute:{
                                let errorAlert = UIAlertController(title: "Error", message: "error: "+(anError.localizedDescription)+". Please try again", preferredStyle: .alert)
                                let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                                errorAlert.addAction(action)
                                self.present(errorAlert,animated: true,completion: nil)
                            //print("error: "+(anError.localizedDescription))
                            })
                            
                        }
                        receiveString = String(data: data!, encoding: String.Encoding.utf8)!
                        print("Received:"+receiveString)
                        if receiveString == "success"{
                            DispatchQueue.main.async(execute:{
                                let userdefault = UserDefaults.standard
                                userdefault.setValue(self.username.text, forKey: "LoginUser")
                                userdefault.synchronize()
                                self.performSegue(withIdentifier: "Login", sender: self.username.text)
                        })
                        }
                        else{
                            DispatchQueue.main.async(execute:{
                            let errorAlert = UIAlertController(title: "Sorry", message: "error: "+receiveString+". Please try again", preferredStyle: .alert)
                            let action = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                            errorAlert.addAction(action)
                            self.present(errorAlert,animated: true,completion: nil)
                            })
                        }
                    }
                    task.resume()
                }
            })
            alert.addAction(action);
            alert.addTextField(configurationHandler: {textfield in
                textfield.placeholder = "Password Again";
                textfield.returnKeyType = .done
                textfield.isSecureTextEntry = true;
                textfield.delegate = self
            })
            self.present(alert,animated:true,completion:nil);
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.username{
            self.password.becomeFirstResponder()
        }
        else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "Login"){
            let tabBarCtrl = segue.destination as! tabBar
            tabBarCtrl.parentVC = self
            tabBarCtrl.loginUser = sender as! String
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}
