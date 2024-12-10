//
//  MasterViewController.swift
//  AcornsMobilePlayerApp
//
//  Created by Dan Harvey on 7/23/15.
//  Copyright (c) 2015 Dan Harvey. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var tableViewController: UITableViewController? = nil
    var lessonNames = NSMutableArray() // Was [AnyObject]()
    var lessonObject: AcornsLessons?
    var lessonString: String!
    
    // Master view navigation bar buttons?
    var navTrashButton: UIBarButtonItem?
    var navRefreshButton: UIBarButtonItem?
    var navOrganizeButton: UIBarButtonItem?
    var displayButton: UIBarButtonItem?

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
        self.title = "Lessons"
    }
    
    /* Insert new lesson from email, web, or cloud */
    func insertNewObject(sender: AnyObject, webAddress address:NSString) {
        lessonNames.insert(address, at: 0)
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [(indexPath as IndexPath)], with: .automatic)
    }
    
    func selectRow(_ row: Int) {
        NSLog("row = %d", row)
        if row < 0 || row >= lessonNames.count { return }
        let rowToSelect:IndexPath = IndexPath(row: row, section: 0);
        tableView.selectRow(at: rowToSelect, animated: true, scrollPosition: UITableView.ScrollPosition.none)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var row = 0
        if lessonString == nil  {
            if  lessonNames.count == 0 {
                return
            }
        }
        else {
            NSLog("master to appear %@", lessonString!)
            row = lessonNames.index(of: lessonString!)
        }
        updateNavigationBars()
        selectRow(row)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NSLog("Master will disappear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateNavigationBars()
        NSLog("Master did appear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateNavigationBars()
        NSLog("Master did disappear")
    }
    
    /** Reload the table view after receiving a launch with URL */
    func reloadView()  {
        if lessonObject == nil { lessonObject = AcornsLessons()  }
        
        lessonNames = lessonObject!.findLessons()
        tableView.reloadData()
        if lessonNames.count >  0
        {
            displayLesson(0)
        }
        if detailViewController?.viewIfLoaded?.window != nil
        {
            detailViewController?.loadView()
        }
        else {
            self.performSegue(withIdentifier: "showDetail", sender: self)
        }
        updateNavigationBars()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
       if let split = splitViewController {
        
            let controllers = split.viewControllers
            detailViewController =
                (controllers[controllers.count-1] as! UINavigationController).topViewController
                as? DetailViewController
            
            tableViewController =
                (controllers[controllers.count-1] as! UINavigationController).topViewController
                as? UITableViewController
            
            // Instantiate master navigation bar buttons
            self.navTrashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(MasterViewController.removeObject(_:)))
            self.navOrganizeButton = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(MasterViewController.organizeObject(_:)))
            self.navRefreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(MasterViewController.refreshObject(_:)))

            self.displayButton = splitViewController!.displayModeButtonItem
 
             
            if lessonObject == nil
            {
                lessonObject = AcornsLessons()
                self.lessonNames = lessonObject!.findLessons()
            }
            
            displayLesson(0)
            updateNavigationBars()
         }
    }

    func backButtonClicked()
    {
        // changed from collapsed to expanded or vice versa
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSLog("Low Resources")
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue,
        sender: Any?)
        {
            NSLog("seque to %@", segue.identifier!)
            if segue.identifier == "showDetail"
            {
                detailViewController = (segue.destination
                    as! UINavigationController).topViewController
                    as? DetailViewController
                
                
                detailViewController!.detailItem = nil;
                
                if let indexPath = self.tableView.indexPathForSelectedRow {
                lessonString = lessonNames.object(at: indexPath.row) as? String
                                   
                detailViewController!.detailItem = lessonString as AnyObject
            }

            else
            {
              NSLog("not showDetail %@", segue.identifier!)
            }
                
            updateNavigationBars()
        }
    }
    
    func updateNavigationBars() {
        NSLog("Number of lessons = %d", lessonNames.count)
        var buttons = [self.displayButton!]
        if (lessonNames.count == 0)
        {
            if self.viewIfLoaded?.window == nil {
                buttons.append(self.navOrganizeButton!)
            }
        }
        if detailViewController != nil
        {
            detailViewController!.navigationItem.setRightBarButtonItems(buttons, animated: false)
        }

        if lessonNames.count > 0
        {
            
            navigationItem.setRightBarButtonItems([self.navOrganizeButton!, self.navTrashButton!, self.navRefreshButton!], animated: true)
        }
        else
        {
            navigationItem.setRightBarButtonItems([self.navOrganizeButton!], animated: false)
        }
        NSLog("Updated navigation buttons")
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessonNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = (lessonNames.object(at: indexPath.row) as! String)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true // Return false for not editable
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
   /** Remove lesson by swiping and clicking the detail button */
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        NSLog("editing style %d", editingStyle.rawValue)
 
        if editingStyle == .delete {
            let row = deleteLesson(indexPath)
            
        displayLesson(row)
    
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("You selected cell number: \(indexPath.row)!");
    }
    /** Load sample lessons when the organizer button is touched */
    @objc func organizeObject(_ sender: AnyObject) {
        NSLog("Organizer")

        if lessonObject == nil { lessonObject = AcornsLessons()  }
        
        lessonObject!.findTestLessons()
        selectRow(0)
        reloadView()
        updateNavigationBars()
    }
    
    func deleteLesson(_ indexPath: IndexPath?) -> Int
    {
        if indexPath == nil { return  -1}
        
        if detailViewController != nil
        {
            detailViewController!.stopLoad()
        }
        
        var row = indexPath!.row
        let lessonName = lessonNames.object(at: row) as! String
        NSLog("delete %d %@", row, lessonName)
        
        lessonNames.removeObject(at: row)
        tableView.deleteRows(at: [indexPath!], with: .fade)
        lessonObject!.deleteLessonFromGallery(lessonName)
        
        if row >= lessonNames.count { row -= 1 }
        if row >= 0 {
            selectRow(row)
        }

        NSLog("Selecting row %d", row)
        updateNavigationBars()
        return row
    }
    
    func displayLesson(_ row: Int) {
        var rowToSelect = row
        if lessonNames.count > 0 {
            if row >= lessonNames.count { rowToSelect = lessonNames.count - 1 }
            if row < 0 { rowToSelect = 0 }
        
            let data = lessonNames.object(at: rowToSelect)
       
            if detailViewController != nil
            {
                detailViewController!.detailItem = data as AnyObject
            }
            selectRow(rowToSelect)
        }
        else {
            if detailViewController != nil
            {
                self.detailViewController!.detailItem = nil
            }
            NSLog("no items")
        }
        NSLog("")
    }
    
    
    
    /** Respond to refresh button to refresh view to restore the sorted order */
    @objc func refreshObject(_ sender: AnyObject) {
        NSLog("Refresh")
        if let indexPath = self.tableView.indexPathForSelectedRow
        {
            let row = indexPath.row
            selectRow(row)
            if lessonNames.count >  0 { displayLesson(row) }
            self.performSegue(withIdentifier: "showDetail", sender: self)
        }
    }
    
    /** Respond to trash button to remove lesson by clicking trash icon */
    @objc func removeObject(_ sender: AnyObject)
    {
        let indexPath = self.tableView.indexPathForSelectedRow
        if indexPath == nil { return }
        
        //tableView.beginUpdates()
        let row = deleteLesson(indexPath)
        tableView.reloadData()
        //tableView.endUpdates()
        displayLesson(row)
        if detailViewController?.viewIfLoaded?.window != nil || lessonNames.count == 0
        {
            self.performSegue(withIdentifier: "showDetail", sender: self)
        }
        else {
            selectRow(row)
        }
    }
}

