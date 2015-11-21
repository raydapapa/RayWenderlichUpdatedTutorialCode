//
//  ViewController.swift
//  Bubble Tea Finder
//
//  Created by Pietro Rea on 8/24/14.
//  Copyright (c) 2014 Pietro Rea. All rights reserved.
//

import UIKit
import CoreData

let filterViewControllerSegueIdentifier = "toFilterViewController"
let venueCellIdentifier = "VenueCell"

class ViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var coreDataStack: CoreDataStack!
    var fetchRequest: NSFetchRequest!
    var venues: [Venue]!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let model = coreDataStack.context.persistentStoreCoordinator!.managedObjectModel
    fetchRequest = model.fetchRequestTemplatesByName("FetchRequest")
    fetchAndReload()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == filterViewControllerSegueIdentifier {
    
    }
  }
  
  @IBAction func unwindToVenuListViewController(segue: UIStoryboardSegue) {
    
  }
}

extension ViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
    return 10
  }

  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(venueCellIdentifier)!
    cell.textLabel!.text = "Bubble Tea Venue"
    cell.detailTextLabel!.text = "Price Info"
    
    return cell
  }
    
    func fetchAndReload() {
        do {
            venues =
                try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Venue]
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}