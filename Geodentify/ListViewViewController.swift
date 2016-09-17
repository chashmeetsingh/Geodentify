//
//  ListViewViewController.swift
//  Geodentify
//
//  Created by Y50-70 on 16/09/16.
//  Copyright © 2016 Chashmeet Singh. All rights reserved.
//

import UIKit

class ListViewViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setProperties()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hidesBottomBarWhenPushed = true
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        hidesBottomBarWhenPushed = false
    }

    private func setProperties() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    @IBAction func signout(sender: AnyObject) {
        UdacityClient.sharedInstance().logOutUser(self, completionHandlerForUserSignOut: { (success, error) in
            performUIUpdatesOnMain({
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                } else {
                    let alert = UIAlertController(title: "Parse Network Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            })
        })
    }
}

extension ListViewViewController: UITableViewDataSource {
    
    func users() -> [UdacityUser] {
        return SaveStudent.sharedInstance().getStudentData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users().count
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("User", forIndexPath: indexPath)
        let user = users()[indexPath.row]

        cell.textLabel?.text = "\(user.firstName) \(user.lastName)"
        cell.imageView?.image = UIImage(named: "pin")

        return cell
    }

}

extension ListViewViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = users()[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: user.mediaURL)!)
    }
}
