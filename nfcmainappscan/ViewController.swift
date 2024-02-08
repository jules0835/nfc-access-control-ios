
//  ViewController.swift
//  nfcmainappscan
//
//  Created by Jules G on 14/01/2024.
//

import UIKit
import CoreNFC
import Foundation


class ViewController: UIViewController, NFCTagReaderSessionDelegate {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var cardValidLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var profilPicture: UIImageView!
    @IBOutlet weak var scanNbrLabel: UILabel!
    @IBOutlet weak var nfcLabel: UILabel!
    @IBOutlet weak var labelStateMessage: UILabel!
    
    var session: NFCTagReaderSession?
    var countScan = 0

    func updateLabelColorText(labelName: UILabel, bgColor: UIColor, text: String) {
        DispatchQueue.main.async {
            labelName.backgroundColor = bgColor
            labelName.text = text
        }
    }

     @IBAction func nfcScanBtn(_ sender: Any) {
        self.session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        self.session?.alertMessage = "Bring the security card to the top of the phone"
        self.session?.begin()
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var accessList = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let person2 = Person(name: "Mathieu", age: 20, picture: "https://us.123rf.com/450wm/lytasepta/lytasepta2301/lytasepta230100073/196905788-image-de-profil-ronde-d-avatar-masculin-pour-les-r%C3%A9seaux-sociaux-avec-illustration-vectorielle.jpg?ver=6", isValid: true, infos: "Sécurité", endDate: dateFormatter.date(from: "2024-01-14")!, startDate: dateFormatter.date(from: "2021-01-14")!, id: "2", UID: "047f2a72555f80")
        let person3 = Person(name: "Vincent", age: 20, picture: "vincent.jpg", isValid: true, infos: "Etudiant", endDate: dateFormatter.date(from: "2024-01-14")!, startDate: dateFormatter.date(from: "2021-01-14")!, id: "3", UID: "3")
        let person4 = Person(name: "Alexandre", age: 20, picture: "alexandre.jpg", isValid: true, infos: "Etudiant", endDate: dateFormatter.date(from: "2024-01-14")!, startDate: dateFormatter.date(from: "2021-01-14")!, id: "4", UID: "4")
        let person5 = Person(name: "Alexis", age: 20, picture: "alexis.jpg", isValid: true, infos: "Etudiant", endDate: dateFormatter.date(from: "2024-01-14")!, startDate: dateFormatter.date(from: "2021-01-14")!, id: "5", UID: "5")

        self.accessList = [person2, person3, person4, person5]
    }


    class Person {
        var name: String
        var age: Int
        var picture: String
        var isValid: Bool
        var infos: String
        var endDate: Date
        var startDate: Date
        var id: String
        var UID: String


        init(name: String, age: Int, picture: String, isValid: Bool, infos: String, endDate: Date, startDate: Date, id: String, UID: String) {
            self.name = name
            self.age = age
            self.picture = picture
            self.isValid = isValid
            self.infos = infos
            self.endDate = endDate
            self.startDate = startDate
            self.id = id
            self.UID = UID
        }
        
    }
    
    func displayProfilPicture(urlPicture : String){
         if let imageUrl = URL(string: urlPicture) {
             URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                 if let error = error {
                     print("Erreur lors du téléchargement de l'image : \(error.localizedDescription)")
                     return
                 }
                 
                 if let imageData = data {
                 
                     DispatchQueue.main.async {
                     
                         self.profilPicture.image = UIImage(data: imageData)
                     }
                 }
             }.resume()
         }
     }
   

    // start nfc scan
  
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        updateLabelColorText(labelName: labelStateMessage, bgColor: .orange, text: "Scanning card")
        print("session begun")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("\(error)")
        print("session error")
    }
    
    func displayInfoScan(infoPers: Person){
        displayProfilPicture(urlPicture : String(infoPers.picture))
        DispatchQueue.main.async {
            self.idLabel.text = String(infoPers.id)
            self.cardValidLabel.text = String(infoPers.isValid)
            self.lastNameLabel.text = String(infoPers.name)
            self.firstNameLabel.text = String(infoPers.infos)
        }
        
    }
    

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print("connexion to tag")
        if tags.count > 1 {
            session.alertMessage = "too many cards"
            session.invalidate()
        
        }
        
        let tag = tags.first!
        session.connect(to: tag){ [self](error) in
            if nil != error{
                session.invalidate(errorMessage: "connextion Failed")
            }
            
            if case let .miFare(sTag) = tag {
                let UID_SCAN = sTag.identifier.map{ String(format: "%.2hhx", $0)}.joined()
                session.alertMessage = "The card was scanned successfully"
                print("UID: \(UID_SCAN)")

                
                for person in accessList {
                    print("UID pers: \(person.UID)")
                    if person.UID == String(UID_SCAN) {
                        updateLabelColorText(labelName: labelStateMessage, bgColor: .green, text: "Authorized access")
                        displayInfoScan(infoPers : person)
                        self.countScan = self.countScan + 1
                        
                        session.invalidate()
                        DispatchQueue.main.async {
                            self.nfcLabel.text = "\(UID_SCAN)"
                            self.scanNbrLabel.text = String(self.countScan)
                        }
                        return
                    } else {
                        updateLabelColorText(labelName: labelStateMessage, bgColor: .red, text: "UNKNOWN CARD")
                        session.invalidate()
                    }
                }
            }
        }
    }

}

