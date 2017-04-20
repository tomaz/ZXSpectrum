//
//  SettingsComputerTableViewController.swift
//  ZX Spectrum
//
//  Created by Tomaz Kragelj on 20.04.17.
//  Copyright © 2017 Gentle Bytes. All rights reserved.
//

import UIKit

class SettingsComputerViewController: UITableViewController {
	
	var selected: Machine? {
		guard let indexPath = tableView.indexPathForSelectedRow else {
			return nil
		}
		return machines[indexPath.row]
	}
	
	fileprivate lazy var machines = Machine.allMachines().map { $0 as! Machine }

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return machines.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let machine = machines[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "MachineCell", for: indexPath) as! SettingsComputerTableViewCell
		cell.configure(object: machine)
		return cell
	}
}
