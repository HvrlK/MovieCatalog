//
//  AddMovieTableViewController.swift
//  MovieCatalog
//
//  Created by Vitalii Havryliuk on 4/12/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit
import MobileCoreServices

class AddMovieTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - Properties
    
    var movie: MovieInfo? {
        let title = titleTextField.text ?? ""
        let genre = genreTextField.text ?? ""
        let yearOfProduction = years[yearOfProductionPickerView.selectedRow(inComponent: 0)]
        let description = descriptionTextView.text ?? ""
        let data = UIImageJPEGRepresentation(posterImageView.image!, 1.0)
        
        return MovieInfo(title: title, genre: genre, yearOfProduction: yearOfProduction, description: description, posterData: data!)
    }
    
    var years: [String] {
        var arrayOfYears: [String] = []
        let date = Date()
        let calendar = Calendar.current
        for year in 1980...calendar.component(.year, from: date) {
            arrayOfYears.append("\(year)")
        }
        return arrayOfYears.sorted { $0 > $1}
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var addPosterButton: UIButton!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var yearOfProductionPickerView: UIPickerView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var posterImageViewAspectRatio: NSLayoutConstraint!
    
    //MARK: - Actions
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        performSegue(withIdentifier: "Add Movie", sender: sender)
    }
    
    @IBAction func addPoster() {
        let picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeImage as String]
        picker.delegate = self
        
        let alert = UIAlertController(
            title: "Chose Source",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(
                title: "Camera",
                style: .default,
                handler: { _ in
                    picker.sourceType = .camera
                    self.present(picker, animated: true)
            }
            ))
        }
    
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(
                title: "Photo Library",
                style: .default,
                handler: { _ in
                    picker.sourceType = .photoLibrary
                    self.present(picker, animated: true)
            }
            ))
        }
        
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))
        
        alert.modalPresentationStyle = .popover
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = posterImageView.image == nil ? addPosterButton : posterImageView
            popoverController.sourceRect = posterImageView.image == nil ? addPosterButton.bounds : posterImageView.bounds
        }
        present(alert, animated: true)
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if posterImageView.image != nil {
                return 2
            } else {
                return 1
            }
        case 1: return 2
        case 2: return 1
        case 3: return 1
        default: return 0
        }
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateDoneButton()
    }
    
    //MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateDoneButton()
    }
    
    //MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return years[row]
    }
    
    //MARK: - UIPickerControllerDelgate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = ((info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage) {
            updatePosterImageView(image: image)
            addPosterButton.setTitle("Change Poster", for: .normal)
            updateDoneButton()
            tableView.reloadData()
            picker.presentingViewController?.dismiss(animated: true)
        } else {
            picker.presentingViewController?.dismiss(animated: true)
            let alert = UIAlertController(
                title: "Error",
                message: "Can't choose image",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "Close",
                style: .default
            ))
            present(alert, animated: true)
        }
    }
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        genreTextField.delegate = self
        descriptionTextView.delegate = self
        updateDoneButton()
        let tap = UITapGestureRecognizer(target: self, action: #selector(addPoster))
        tap.numberOfTapsRequired = 1
        posterImageView.addGestureRecognizer(tap)
    }
    
    private func updateDoneButton() {
        if titleTextField.text == "" || genreTextField.text == "" || descriptionTextView.text == "" || posterImageView.image == nil {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
    
    private func updatePosterImageView(image: UIImage) {
        posterImageView.image = image
        if posterImageViewAspectRatio != nil {
            posterImageView.removeConstraint(posterImageViewAspectRatio)
            posterImageViewAspectRatio = NSLayoutConstraint(
                item: posterImageView,
                attribute: .width,
                relatedBy: .equal,
                toItem: posterImageView,
                attribute: .height,
                multiplier: image.size.width / image.size.height,
                constant: 0
            )
            posterImageView.addConstraint(posterImageViewAspectRatio)
        }
    }
    
}














