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
        
        let bundle = Bundle(for: Prompter.self)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
