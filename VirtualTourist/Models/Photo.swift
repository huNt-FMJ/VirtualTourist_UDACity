//
//  Photo.swift
//  VirtualTourist
//
//  Created by M on 03/02/16.
//
//

import Foundation
import CoreData
import UIKit
protocol PhotoImageLoadedDelegate {
    func imageLoaded()
}

class Photo : NSManagedObject {
    @NSManaged var imageURL : String!
    @NSManaged var imageID  : String!
    @NSManaged var pin      : Pin?
    
    var delegate            : PhotoImageLoadedDelegate?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(withPin pin : Pin, imageURL : String, andContext context : NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.pin = pin
        self.imageURL = imageURL
    }
    
    var photoImage : UIImage? {
        get {
            return FlickrAPI.Caches.imageCache.imageWithIdentifier(imageID)
        }

        set {
            if newValue != nil {
                FlickrAPI.Caches.imageCache.storeImage(newValue, withIdentifier: imageID!)
                print("[Photo photoImage]: image loaded")
                delegate?.imageLoaded()
            }
        }
    }
    
    func startLoadingPhotoURL() {
        print("[Photo startLoadingPhotoURL]: loading url: \(imageURL)")
        if photoImage != nil {
            print("[Photo]: image \(imageID) already available, skipping download")
            delegate?.imageLoaded()
            return
        }
        let potentiallyDownloadedData : NSData? = NSData(contentsOfURL: NSURL(string: imageURL)!)
        if let downloadedData = potentiallyDownloadedData {
            dispatch_async(dispatch_get_main_queue()) {
                let imageFromData = UIImage(data: downloadedData)
                self.photoImage = imageFromData
            }
        }
    }
}