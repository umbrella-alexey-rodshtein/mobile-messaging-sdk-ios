//
// Created by Goran Tomasic on 07/10/2016.
//

import Foundation

class MMVersionManager {
	static let shared = MMVersionManager()
	var remoteApiQueue: MMRemoteAPIQueue
	
	private let kLastCheckDateKey = "MMLibrary-LastCheckDateKey"
	private let lastCheckDate : NSDate?
	
	init?() {
		guard let remoteUrl = MobileMessaging.sharedInstance?.remoteAPIBaseURL,
			  let appCode = MobileMessaging.sharedInstance?.applicationCode else {
				return nil
		}
		
		lastCheckDate = NSUserDefaults.standardUserDefaults().objectForKey(kLastCheckDateKey) as? NSDate
		remoteApiQueue = MMRemoteAPIQueue(baseURL: remoteUrl, applicationCode: appCode)
	}
	
	func validateVersion() {
		MMLogDebug("Checking MobileMessaging library version..")
		
		var shouldCheckVersion = true
		
		if lastCheckDate != nil {
			let advancedDate = lastCheckDate?.dateByAddingTimeInterval(60 /* to minutes */ * 60 /* to hours */ * 24 /* to days */)
			shouldCheckVersion = (advancedDate?.compare(NSDate()) == NSComparisonResult.OrderedAscending)
		}
		
		guard shouldCheckVersion else {
			MMLogDebug("There's no need to check the library version at this time.")
			return
		}
		
		let handlingQueue = OperationQueue.mm_newSerialQueue
		
		handlingQueue.addOperation(LibraryVersionFetchingOperation(remoteAPIQueue: remoteApiQueue) { [unowned self] (result: MMLibraryVersionResult) in
			if result.error == nil {
				if let onlineVersion = result.value?.libraryVersion,
					let updateUrl = result.value?.updateUrl {
					if onlineVersion != libVersion {
						// Make sure that this is displayed in the console (this code can easily execute before the devs set up the logging in the MM_ methods)
						let warningMessage = "\n****\n\tMobileMessaging SDK version \(onlineVersion) is available. You are currently using the \(libVersion) version.\n\tWe recommend using the latest version.\n\tYou can update using 'pod update' or by downloading the latest version at: \(updateUrl)\n****\n"
						if MobileMessaging.logger.logLevel == MMLogLevel.Off {
							NSLog(warningMessage)
						} else {
							MMLogWarn(warningMessage)
						}
					} else {
						MMLogDebug("Your MobileMessaging library is up to date.")
						
						// save the date only if our version is the new one. Otherwise, we warn the dev in the console every time until he/she updates
						NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: self.kLastCheckDateKey)
						NSUserDefaults.standardUserDefaults().synchronize()
					}
				}
			} else {
				if let error = result.error {
					MMLogDebug("An error occurred while trying to validate library version: \(error)")
				}
			}
			})
	}
	
}
