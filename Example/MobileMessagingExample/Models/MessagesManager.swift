//
//  MessagesManager.swift
//  MobileMessagingExample
//
//  Created by Andrey K. on 20/05/16.
//

import UIKit
import MobileMessaging

let kMessageSeenAttribute = "seen"
let kMessageDeliveryReportSentAttribute = "deliveryReportSent"
let kMessagesKey = "kMessagesKey"

class Message : NSObject, NSCoding {
	var text: String
	var messageId: String
	dynamic var deliveryReportSent: Bool = false
	dynamic var seen : Bool = false
	
	required init(text: String, messageId: String){
		self.text = text
		self.messageId = messageId
		super.init()
	}
	
	//MARK: NSCoding
	required init(coder aDecoder: NSCoder) {
		text = aDecoder.decodeObject(forKey: "text") as! String
		messageId = aDecoder.decodeObject(forKey: "messageId") as! String
		deliveryReportSent = aDecoder.decodeBool(forKey: kMessageDeliveryReportSentAttribute)
		seen = aDecoder.decodeBool(forKey: kMessageSeenAttribute)
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(text, forKey: "text")
		aCoder.encode(messageId, forKey: "messageId")
		aCoder.encode(deliveryReportSent, forKey: kMessageDeliveryReportSentAttribute)
		aCoder.encode(seen, forKey: kMessageSeenAttribute)
	}
	
	//MARK: Util
	class func prepare(_ rawMessage: [String : Any]) -> Message? {
		guard let text = rawMessage.mm_apsAlertBody
			, let messageId = rawMessage.mm_messageId
			else {
			return nil
		}
		return Message(text: text, messageId: messageId)
	}
}

final class MessagesManager: NSObject, UITableViewDataSource {
	static let sharedInstance = MessagesManager()
	var newMessageBlock: ((Message) -> Void)?
	var messages = [Message]()

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override init() {
		super.init()
		unarchiveMessages()
		startObservingNotifications()
	}
	
	func cleanMessages() {
		synced(self) {
			self.messages.removeAll()
			UserDefaults.standard.removeObject(forKey: kMessagesKey)
		}
	}
	
	//MARK: Private
	fileprivate func displayMessageAlert(_ messageUserInfo: [AnyHashable: Any]) {
		if UIApplication.shared.applicationState == .active {
			MMPush.handlePush(userInfo: messageUserInfo)
		}
	}
	
	fileprivate func synced(_ lock: AnyObject, closure: (Void) -> Void) {
		objc_sync_enter(lock)
		closure()
		objc_sync_exit(lock)
	}
	
	fileprivate func startObservingNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(MessagesManager.appWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(MessagesManager.handleNewMessageReceivedNotification(_:)), name: NSNotification.Name(rawValue: MMNotificationMessageReceived), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(MessagesManager.handleDeliveryReportSentNotification(_:)), name: NSNotification.Name(rawValue: MMNotificationDeliveryReportSent), object: nil)
	}
	
	fileprivate func archiveMessages() {
		synced(self) {
			let data: Data = NSKeyedArchiver.archivedData(withRootObject: self.messages)
			UserDefaults.standard.set(data, forKey: kMessagesKey)
		}
	}
	
	fileprivate func unarchiveMessages() {
		synced(self) {
			if let messagesData = UserDefaults.standard.object(forKey: kMessagesKey) as? Data,
				let messages = NSKeyedUnarchiver.unarchiveObject(with: messagesData) as? [Message] {
				self.messages.append(contentsOf: messages)
			}
		}
	}
	
	//MARK: Handle notifications
	func appWillTerminate() {
		archiveMessages()
	}
	
	func handleNewMessageReceivedNotification(_ notification: Notification) {
		guard let userInfo = notification.userInfo,
			let messageUserInfo = userInfo[MMNotificationKeyMessagePayload] as? [String : Any],
			let message = Message.prepare(messageUserInfo) else {
				return
		}
		
		synced(self) {
			self.messages.insert(message, at: 0)
		}
		
		newMessageBlock?(message)
		displayMessageAlert(messageUserInfo)
	}
	
	func handleDeliveryReportSentNotification(_ notification: Notification) {
		guard let userInfo = notification.userInfo,
			let messageUserInfo = userInfo[MMNotificationKeyDLRMessageIDs] as? [String] else {
				return
		}
		
		for message in messages {
			if messageUserInfo.contains(message.messageId) {
				message.deliveryReportSent = true
			}
		}
	}

	//MARK: UITableViewDataSource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: kMessageCellId, for: indexPath) as? MessageCell {
			cell.message = messages[indexPath.row]
			return cell
		}
		fatalError()
	}
}
