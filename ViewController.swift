//
//  ViewController.swift
//  LineADay-iPhone
//
//  Created by Ethan Perelmuter on 12/29/18.
//  Copyright © 2018 Peethan. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController {
    
    //Labels
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var dateSpinner: UIDatePicker!
    @IBOutlet weak var viewADayButton: UIButton!
    //Miscellaneous Fields
    //var dateString : String?
    var wheelDate : String = ""
    var wheelYear : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Styling
        todayButton.layer.cornerRadius = 4
        viewADayButton.layer.cornerRadius = 4
        
        
        //Place today's data appropriately
        let now = Date()
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "eeee, LLLL dd, yyyy"
        let dateString = "Today: " + dateFormatter.string(from: now)
        todayButton.setTitle(dateString, for: .normal)
        //self.deleteAllData("DayEntry")
    }
    
    func deleteAllData(_ entity: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject]{
                let s = "Entry text to delete" + (managedObject.value(forKey: "entryText") as! String)
                print(s)
                context.delete(managedObject)
            }
        } catch let error as NSError {
            print("Delete all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //TODO: Get the date as [Month Day] from the dateSpinner
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL dd"
        wheelDate = formatter.string(from: dateSpinner.date)
        formatter.dateFormat = "yyyy"
        wheelYear = formatter.string(from: dateSpinner.date)
        print("Date on wheel to send: " + wheelDate)
        print("Year: " + wheelYear)
        if let dvc = segue.destination as? DayViewController {
            dvc.wheelDate = self.wheelDate
            dvc.wheelYear = self.wheelYear
        }
    }


}

