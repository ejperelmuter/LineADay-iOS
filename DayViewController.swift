//
//  DayViewController.swift
//  LineADay-iPhone
//
//  Created by Ethan Perelmuter on 12/30/18.
//  Copyright © 2018 Peethan. All rights reserved.
//

import UIKit
import CoreData

struct DayInfo {
    var year : String
    var dayText : String
    var dayPhoto : Data?
}

class DayTableViewCell: UITableViewCell {
    @IBOutlet weak var dayText: UILabel!
    @IBOutlet weak var dayYear: UILabel!
    @IBOutlet var dayImage: UIImageView!
    //@IBOutlet weak var dayPicture: UIImageView!
}

class DayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Fields
    var dayCellArray = [DayInfo]()
    var wheelDate : String = ""
    var wheelYear : String = ""
    var currPreview : UIImage? = nil
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayDate: UILabel!
    @IBOutlet weak var entryTextBox: UITextView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet var addImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Styling
        editButton.layer.cornerRadius = 4
        homeButton.layer.cornerRadius = 4
        addImageButton.layer.cornerRadius = 4

        print("view did load!")
        //Prepare the fetch request
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DayEntry")
        request.returnsObjectsAsFaults = false
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL dd"
        if wheelDate == "" {
            wheelDate = dateFormatter.string(from: now)
        }
        request.predicate = NSPredicate(format: "monthDayString == %@", wheelDate)
        
        //TODO: Fetch all entries for today's date (any year)
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //Create a context from this container
            let context = appDelegate.persistentContainer.viewContext
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                //Add the entries to the dayCellArray as DayInfo structs
                let year = (data.value(forKey: "yearString") as! String)
                let entryText = (data.value(forKey: "entryText") as! String)
                let dayPhoto = (data.value(forKey: "entryImage") as! Data?)
                dayCellArray.append(DayInfo(year: year, dayText: entryText, dayPhoto: dayPhoto))
            }
        } catch {
            print("Failed to fetch entries")
        }
        
        //TODO: Sort entries by Year

        //Delegate table
        tableView.delegate = self
        tableView.dataSource = self
        //Delegate textbox
        entryTextBox.delegate = self
        //Delegate ImagePicker
        imagePicker.delegate = self

        
        //Place today's data appropriately
        if wheelDate == "" {
            dayDate.text = dateFormatter.string(from: now)
        } else {
            dayDate.text = wheelDate
        }
        

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("in numberOfRowsInSection")
        return dayCellArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("in cellForRowAt")
        let dayCell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as! DayTableViewCell
        let d = self.dayCellArray[indexPath.row]
        print("d.dayText: " + d.dayText)
        dayCell.dayText.text = d.dayText
        dayCell.dayYear.text = d.year
        //TODO: Put the photo in the cell
        var picAsUI : UIImage? = nil
        dayCell.dayYear.textColor = UIColor.black
        if d.dayPhoto != nil {
            picAsUI = UIImage(data: d.dayPhoto!)
            dayCell.dayYear.textColor = UIColor.white
        }
        dayCell.dayImage.image = picAsUI
        //self.imagePreview.image = picAsUI
        
        //dayCell.dayImage.contentMode = UIViewContentModeScaleAspectFit
        //dayCell.dayPicture?.image = UIImage(named: d.dayPhoto)

        return dayCell
    }
    

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("In textViewDidBeginEditing")
        entryTextBox.text = String()
    }
    
   
    @IBAction func addEntryToday(_ sender: Any) {
        print("Adding entry in addEntryToday")
        //Get what the user typed
        let entryText : String = entryTextBox.text
        print("User typed: " + entryText)
        
        //Get today's date
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL dd"
        //let monthDay : String = dateFormatter.string(from: now)
        let monthDay = wheelDate //NEW
        dateFormatter.dateFormat = "yyyy"
        var year : String = dateFormatter.string(from: now)
        if wheelYear != "" {
            year = wheelYear
        }
        
        //Get the image if the user uploaded one
        var picSelected : Data? = nil
        ///Convert to NSData
        if imagePreview.image != nil {
            print("User uploaded an image")
            //picSelected = imagePreview.image!.pngData()! as Data?
            picSelected = imagePreview.image!.jpegData(compressionQuality: 0.8)! as Data?
        }
        
        //Add to dayCellArray
        dayCellArray.append(DayInfo(year: year, dayText: entryText, dayPhoto: picSelected))
        //Update the table immediately
        self.tableView.reloadData()
        
        //Store the entry as a new DayEntry in Core Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //Create a context from this container
        let context = appDelegate.persistentContainer.viewContext
        //Create the DayEntry entity
        let dayEntyEntity = NSEntityDescription.entity(forEntityName: "DayEntry", in: context)
        let dayEntryObject = NSManagedObject(entity: dayEntyEntity!, insertInto: context)
        dayEntryObject.setValue(monthDay, forKey: "monthDayString")
        dayEntryObject.setValue(entryText, forKey: "entryText")
        dayEntryObject.setValue(year, forKey: "yearString")
        //Save the photo if the user chose one
        dayEntryObject.setValue(picSelected, forKey: "entryImage")
        //print("Saving entity with monthDay: " + monthDay + "  entryText: " + entryText + "  yearString: " + year)
        //Save the entity
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        //Empty the text box
        entryTextBox.text = String()
        //Delete the pic
        imagePreview.image = nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            //Remove it from CoreData
            let cell : DayInfo = dayCellArray[indexPath.row]
            let cellDay = NSPredicate(format: "yearString = %@", cell.year)
            let cellText = NSPredicate(format: "entryText = %@", cell.dayText)
            let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [cellDay, cellText])
            //Form the request
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DayEntry")
            request.returnsObjectsAsFaults = false
            request.predicate = andPredicate
            do {
                let result = try context.fetch(request)
                for managedObject in result as! [NSManagedObject]{
                    let s = "Entry text to delete" + (managedObject.value(forKey: "entryText") as! String)
                    print(s)
                    context.delete(managedObject)
                }
            } catch let error as NSError {
                print("Delete all data in 'entryText' error : \(error) \(error.userInfo)")
            }
            self.dayCellArray.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    func deleteAllData(_ entity: String){
        dayCellArray = [DayInfo]()
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
    
    var i = 0
    @IBAction func editModeToggle(_ sender: Any) {
        print("Toggling editting")
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing {
            editButton.setTitle("Done", for: .normal)
        } else {
            editButton.setTitle("Edit", for: .normal)
        }
    }

    /*
     * IMAGE ADDING
     */
    
    @IBOutlet var imagePreview: UIImageView!
    let imagePicker = UIImagePickerController()
    @IBAction func addPicturePressed(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.imagePreview.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        currPreview = self.imagePreview.image
        imagePicker.dismiss(animated:true,completion:nil)
    }
}
