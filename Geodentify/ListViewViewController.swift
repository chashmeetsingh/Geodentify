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

    var users: [UdacityUser]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setProperties()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hidesBottomBarWhenPushed = true
        getUserList()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        hidesBottomBarWhenPushed = false
    }

    private func setProperties() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    func getUserList() {
        users = SaveStudent.sharedInstance().getStudentData()
        tableView.reloadData()
    }

}

extension ListViewViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("User", forIndexPath: indexPath)
        let user = users[indexPath.row]

        cell.textLabel?.text = "\(user.firstName) \(user.lastName)"
        cell.imageView?.image = UIImage(named: "pin")

        return cell
    }

}

extension ListViewViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: user.mediaURL)!)
    }
}
