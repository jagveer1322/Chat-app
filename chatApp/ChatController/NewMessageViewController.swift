//
//  NewMessageViewController.swift
//  chatApp
//
//  Created by Macbook on 02/09/22.
//

import UIKit

class NewMessageViewController: UITableViewController {
    let cellid  = "cellid"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "USERS"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(tappedCancel))
    }
    
    @objc func tappedCancel(){
        dismiss(animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellid)

        cell.textLabel?.text = "jagveer"

        return cell
    }

}
