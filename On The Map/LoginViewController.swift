//
//  LoginViewController.swift
//  On The Map
//
//  Created by Maarut Chandegra on 22/04/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController
{

    private let signUpLinkString = NSURL(string: "https://www.udacity.com/account/auth#!/signup")!
    @IBOutlet weak var noAccountLabel: UILabel!
    @IBOutlet weak var usernameEntry: UITextField!
    @IBOutlet weak var passwordEntry: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let noAccountText = NSMutableAttributedString(string: "Don't have an account? ")
        noAccountText.appendAttributedString(NSAttributedString(string: "Sign up!", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]))
        noAccountLabel.attributedText = noAccountText
        [usernameEntry, passwordEntry].forEach {
            $0.layer.borderColor = UIColor.whiteColor().CGColor
            $0.layer.borderWidth = 1.0
        }
        loginButton.setTitleColor(UIColor.lightTextColor(), forState: .Disabled)
        addGradientToView()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        usernameEntry.text = nil
        passwordEntry.text = nil
        loginButton.enabled = false
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        resignFirstResponderForTextFields()
    }
    
    @IBAction func labelTapped(sender: UITapGestureRecognizer)
    {
        if resignFirstResponderForTextFields() { return }
        if !noAccountLabel.pointInside(sender.locationInView(noAccountLabel), withEvent: nil) { return }
        let rangeOfLink = (noAccountLabel.text! as NSString).rangeOfString("Sign up!")
        if sender.didTapAttributedTextInLabel(noAccountLabel, inRange: rangeOfLink) {
            UIApplication.sharedApplication().openURL(signUpLinkString)
        }
    }
    
    @IBAction func loginTapped(sender: AnyObject)
    {
        let currentLoginText = loginButton.currentTitle
        loginButton.enabled = false
        loginButton.setTitle("", forState: .Normal)
        activityIndicator.startAnimating()
        UdacityClient.sharedInstance().login(usernameEntry.text!, password: passwordEntry.text!) { (didSucceed, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if didSucceed {
                    self.performSegueWithIdentifier("loggedInSegue", sender: self)
                }
                else {
                    let alertController: UIAlertController
                    if error?.code == UdacityClient.ResponseKeys.ForbiddenResponseErrorCode {
                        if let parsedResult = error!.userInfo[UdacityClient.ResponseKeys.ForbiddenResponseKey] as? [String: AnyObject],
                            let errorMsg = parsedResult[UdacityClient.ResponseKeys.ErrorKey] as? String {
                            alertController = UIAlertController(title: "Login Error", message: errorMsg, preferredStyle: .Alert)
                        }
                        else {
                            alertController = UIAlertController(title: "Login Error", message: "Invalid credentials submitted. Please check the details entered and try again.", preferredStyle: .Alert)
                        }
                    }
                    else {
                        alertController = UIAlertController(title: "Login Error", message: "Login failed to complete. Please try again.", preferredStyle: .Alert)
                    }
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default , handler: { _ in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                self.loginButton.enabled = true
                self.activityIndicator.stopAnimating()
                self.loginButton.setTitle(currentLoginText, forState: .Normal)
            }
        }
    }
    
    @IBAction func desp(sender: AnyObject)
    {
        performSegueWithIdentifier("loggedInSegue", sender: self)
    }
    
    private func resignFirstResponderForTextFields() -> Bool
    {
        for textField in [usernameEntry, passwordEntry] {
            if textField.isFirstResponder() {
                textField.resignFirstResponder()
                return true
            }
        }
        return false
    }
    
    private func addGradientToView()
    {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [view.backgroundColor!.CGColor, UIColor(red: 1.0, green: 200.0/255.0, blue: 0.0, alpha: 1).CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
    }

}

extension LoginViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        switch textField {
        case usernameEntry:
            passwordEntry.becomeFirstResponder()
            break
        case passwordEntry:
            passwordEntry.resignFirstResponder()
            if loginButton.enabled {
                loginTapped(self)
            }
            break
        default:
            break
        }
        return true;
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool
    {
        let enableLoginButton: Bool
        switch textField {
        case usernameEntry:
            enableLoginButton = (passwordEntry.text?.isEmpty ?? false)
            break
        case passwordEntry:
            enableLoginButton = (usernameEntry.text?.isEmpty ?? false)
            break
        default:
            enableLoginButton = false
            break
        }
        loginButton.enabled = enableLoginButton
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let enableLoginButton: Bool
        switch textField {
        case usernameEntry:
            enableLoginButton = !newString.isEmpty && !(passwordEntry.text?.isEmpty ?? true)
            break
        case passwordEntry:
            enableLoginButton = !newString.isEmpty && !(usernameEntry.text?.isEmpty ?? true)
            break
        default:
            enableLoginButton = false
            break
        }
        loginButton.enabled = enableLoginButton
        return true
    }
}

// UILabel doesn't have builtin functionality to send the user to Safari when tapping a link.
// The code below was found at
// http://samwize.com/2016/03/04/how-to-create-multiple-tappable-links-in-a-uilabel/
// The basic concept of the code is to use TextKit to determine whether a tap occured over
// underlined text. A NSTextStorage object is created and "overlaid" over the label text.
// The location of the tap is then translated to a point over the NSTextStorage object.
// We can then determine if a character that we're interested in has been tapped.
private extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = locationInView(label)
        let textBoundingBox = layoutManager.usedRectForTextContainer(textContainer)
        let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                         locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndexForPoint(locationOfTouchInTextContainer, inTextContainer: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
