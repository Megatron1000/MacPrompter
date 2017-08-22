//
//  EventLoggerProtocol.swift
//  MacPrompter
//
//  Created by Mark Bridges on 22/08/2017.
//  Copyright © 2017 Mark Bridges. All rights reserved.
//

import Foundation

public protocol EventTrackingLogger {
    
    static func logEvent(_ eventName: String)

    static func logEvent(_ eventName: String, parameters: [String : Any])
    
}
