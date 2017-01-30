//
//  Session.swift
//  OpenTokBeacon
//
//  Created by javierfuchs on 1/30/17.
//  Copyright © 2017 OpenTok. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 [{
	"id": 1,
	"api_key": "45621172",
	"session_id": "2_MX40NTYyMTE3Mn5-MTQ4NTc3OTU3NDYxMH5DL0sraVd0alpEaDQ4NVRDS2hkYk40bmt-fg",
	"token_id": "T1==cGFydG5lcl9pZD00NTYyMTE3MiZzaWc9OTZmOWMxOTg4ZTJlMTYxZTM2OWY0MGVkMWMyZTk4MzkxZmU5MjRhNDpzZXNzaW9uX2lkPTJfTVg0ME5UWXlNVEUzTW41LU1UUTROVGMzT1RVM05EWXhNSDVETDBzcmFWZDBhbHBFYURRNE5WUkRTMmhrWWs0MGJtdC1mZyZjcmVhdGVfdGltZT0xNDg1Nzc5NjQzJm5vbmNlPTAuNTQxNzI2OTc4MzczMzYzMSZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNDg1ODAxMTc0JmNvbm5lY3Rpb25fZGF0YT0lN0IlMjJyb2xlJTIyJTNBJTIyY2xpZW50JTIyJTJDJTIycGxhdGZvcm0lMjIlM0ElMjJpb3MlMjIlN0Q=",
	"beacon_id": "3",
	"created_at": "2017-01-30T12:37:59.448Z",
	"updated_at": "2017-01-30T12:37:59.448Z",
	"url": "http://192.168.250.185:3000/sessions/1.json"
 }]*/

class Session : Mappable {
    var id: Int?
    var api_key: String?
    var session_id: String?
    var token_id: String?
    var beacon_id: String?
    var created_at: Date?
    var updated_at: Date?
    var url: String?
    
    required public init?(map: Map) {
        
    }
    
    public init?(name: String, urlAsset: AVURLAsset) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        api_key <- map["api_key"]
        session_id <- map["session_id"]
        token_id <- map["token_id"]
        beacon_id <- map["beacon_id"]
        created_at <- (map["created_at"], DateTransform())
        updated_at <- (map["updated_at"], DateTransform())
        url <- map["url"]
    }
}

