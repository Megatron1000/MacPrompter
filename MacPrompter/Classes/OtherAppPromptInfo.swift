//
//  OtherAppPromptInfo.swift
//  MacPrompter
//
//  Created by Mark Bridges on 22/08/2017.
//  Copyright © 2017 Mark Bridges. All rights reserved.
//

import AppKit

public struct OtherAppPromptInfo {
    
    private let OtherAppNameKey: String = "otherAppName"
    private let OtherAppURLKey: String = "otherAppURL"
    private let OtherAppImageKey: String = "otherAppImage"
    private let OtherAppPromptIntervalKey: String = "otherAppPromptInterval"
    private let StopViewOtherKey: String = "stopViewOther"
    
    let name: String
    let url: URL
    let image: NSImage
    let promptInterval: Int
    let stopKey: String
    
    init(dictionary: [String : Any]) throws {
        
        guard
            let name = dictionary[OtherAppNameKey] as? String,
            let urlString = dictionary[OtherAppURLKey] as? String,
            let url = URL(string: urlString),
            let imageName = dictionary[OtherAppImageKey] as? String,
            let image = NSImage(named: imageName),
            let promptInterval = dictionary[OtherAppPromptIntervalKey] as? Int else {
                throw Prompter.PrompterError.unableToParsePlist
        }
        
        self.name = name
        self.url = url
        self.image = image
        self.promptInterval = promptInterval
        self.stopKey = "\(StopViewOtherKey)-\(name)"
        
    }
    
}
