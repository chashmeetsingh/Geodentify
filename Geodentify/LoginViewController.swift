//
//  LoginViewController.swift
//  Geodentify
//
//  Created by Y50-70 on 13/09/16.
//  Copyright © 2016 Chashmeet Singh. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: Properties

    var appDelegate: AppDelegate!
    var keyboardOnScreen = false

    // Contains user email
    @IBOutlet weak var userEmailTextField: UITextField!

    // Contains user password
    @IBOutlet weak var userPasswordTextField: UITextField!

    // Udacity Logo
    @IBOutlet weak var udacityLogo: UIImageView!

    // Login Button
    @IBOutlet weak var loginButton: UIButton!

    // Error label
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(keyboardWillHide))
        subscribeToNotification(UIKeyboardDidShowNotification, selector: #selector(keyboardDidShow))
        subscribeToNotification(UIKeyboardDidHideNotification, selector: #selector(keyboardDidHide))
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }

    @IBAction func loginUserClicked(sender: AnyObject) {

        userDidTapView(self)

        if userEmailTextField.text!.isEmpty || userPasswordTextField.text!.isEmpty {
            errorLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            tryLoginUser()
        }

    }

    private func tryLoginUser() {
        activityIndicator.startAnimating()
        let username = userEmailTextField.text!
        let password = userPasswordTextField.text!
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"

        UdacityClient.sharedInstance().authenticateWithViewController(jsonBody, hostViewController: self, completionHandlerForAuth: { (success, errorString) in
            performUIUpdatesOnMain({
                if success {
                    self.completeLogin()
                } else {
                    let alert = UIAlertController(title: "Error logging in", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
                self.activityIndicator.stopAnimating()
                self.setUIEnabled(true)
            })
        })
    }

    private func completeLogin() {
        performUIUpdatesOnMain {
            self.errorLabel.text = ""
            self.userEmailTextField.text = ""
            self.userPasswordTextField.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UserTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }

}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: Show/Hide Keyboard

    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            udacityLogo.hidden = true
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            udacityLogo.hidden = false
        }
    }

    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }

    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }

    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }

    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(userEmailTextField)
        resignIfFirstResponder(userPasswordTextField)
    }
}

// MARK: - LoginViewController (Notifications)

extension LoginViewController {

    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }

    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - LoginViewController (Configure UI)

extension LoginViewController {

    private func setUIEnabled(enabled: Bool) {
        userEmailTextField.enabled = enabled
        userPasswordTextField.enabled = enabled
        loginButton.enabled = enabled
        errorLabel.text = ""
        errorLabel.enabled = enabled

        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }

    private func displayError(errorString: String?) {
        if let errorString = errorString {
            errorLabel.text = errorString
        }
    }
}
