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

    var appDelegate: AppDelegate!
    var users: [UdacityUser]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        setProperties()
        getUserList()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.hidesBottomBarWhenPushed = true
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.hidesBottomBarWhenPushed = false
    }

    private func setProperties() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    func getUserList() {
        users = appDelegate.users
        tableView.reloadData()
    }

}

extension ListViewViewController: UITableViewDataSource {

    func items() -> [UdacityUser] {
        return users
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items().count
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("User", forIndexPath: indexPath)
        let item = items()[indexPath.row]

        cell.textLabel?.text = "\(item.firstName) \(item.lastName)"
        cell.imageView?.image = UIImage(named: "pin")

        return cell
    }

}

extension ListViewViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = items()[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: item.mediaURL)!)
    }
}
