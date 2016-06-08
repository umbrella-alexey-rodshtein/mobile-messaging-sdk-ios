//
//  MMAPIKeysAndValues.swift
//  MobileMessaging
//
//  Created by okoroleva on 08.03.16.
//

import Foundation

struct MMAPIKeys {
	//MARK: API availability
	static let kFetchAPIEnabled = true
	static let kSeenAPIEnabled = true
	
    //MARK: registration
    static let kPlatformType = "platformType"
    static let kRegistrationId = "registrationId"
    static let kInternalRegistrationId = "deviceApplicationInstanceId"
    
    //MARK: delivery
    static let kMessageIDs = "messageIDs"
	
    //MARK: serviceErrors
    static let kRequestError = "requestError"
    static let kServiceException = "serviceException"
    static let kErrorText = "text"
    
    //MARK: APNs
    static let kPayloads = "payloads"
    static let kAps = "aps"
    static let kAlert = "alert"
    static let kTitle = "title"
    static let kBody = "body"
    static let kBadge = "badge"
    static let kSound = "sound"
    static let kData = "data"
	
	//MARK: email
	static let kEmail = "email"
	
	//MARK: msisdn
	static let kMSISDN = "msisdn"
    
    //MARK: seenMessages
    static let kSeenMessages = "messages"
    static let kSeenTimestamp = "seenDate"
    
    //MARK: Common fields
    static let kMessageId = "messageId"
}

struct MMAPIValues {
	static let kProdBaseURLString = "https://oneapi.infobip.com"	
	static let kPlatformType = "APNS"
}

public struct MMEventNotifications {
	/**
	The notification `kRegistrationUpdated` will be posted after the registration is updated on backend server.
	The notification's `userInfo` will contain a server's Internal Id string for the registered user paired with `kRegistrationUserInfoKey` key
	*/
	public static let kRegistrationUpdated = "com.mobile-messaging.notification.reg-updated"
	public static let kRegistrationUserInfoKey = "com.mobile-messaging.notification.registration-key"
	
	/**
	The notification `kDeviceTokenReceived` will be posted after the APNs device token is received.
	The notification's `userInfo` will contain a new hex-encoded device token string paired with `kDeviceTokenKey` key
	*/
	public static let kDeviceTokenReceived = "com.mobile-messaging.notification.device-token-received"
	public static let kDeviceTokenKey = "com.mobile-messaging.notification.device-token-key"
	
	/**
	The notification `kDeliveryReportSent` will be posted after the MobileMesaging library has succesfully sent message delivery report.
	The notification's `userInfo` will contain an array of message ID strings paired with `kMessageIDsUserInfoKey` key
	*/
	public static let kDeliveryReportSent = "com.mobile-messaging.notification.dlr-sent"
	public static let kMessageIDsUserInfoKey = "com.mobile-messaging.notification.dlr-key"
	
	/**
	The notification `kAPIError` will be posted after receiving any error from server.
	The notification's `userInfo` will contain a corresponding `NSError` object paired with `kAPIErrorUserInfoKey` key
	*/
	public static let kAPIError = "com.mobile-messaging.notification.api-error"
	public static let kAPIErrorUserInfoKey = "com.mobile-messaging.notification.api-error-key"
	
	/**
	The notification `kMessageReceived` will be posted after receiving any message, either from APNs or the server.
	The notification's `userInfo` will contain a remote notification `userInfo` dictionary paired with `kMessageUserInfoKey` key
	The value for key `kMessageIsPushKey` contains a flag which indicate whether the message is pushed by APNs or pulled from the server
	*/
	public static let kMessageReceived = "com.mobile-messaging.notification.message-received"
	public static let kMessageUserInfoKey = "com.mobile-messaging.notification.message-key"
	public static let kMessageIsPushKey = "com.mobile-messaging.notification.message-is-push-key"
}