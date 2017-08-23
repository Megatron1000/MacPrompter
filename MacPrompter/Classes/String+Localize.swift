//
//  String+Localize.swift
//  MacPrompter
//
//  Created by Mark Bridges on 22/08/2017.
//  Copyright © 2017 Mark Bridges. All rights reserved.
//

import Foundation

extension String {
    
    var localized: String {
        
        let frameworkBundle = Bundle(for: Prompter.self)
        
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("MacPrompter.bundle")
        
        let resourceBundle = Bundle(url: bundleURL!)!
        
        return NSLocalizedString(self, tableName: nil, bundle: resourceBundle, value: "", comment: "")
    }
}
