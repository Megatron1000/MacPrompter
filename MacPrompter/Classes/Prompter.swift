//
//  MacPrompter
//
//  Created by Mark Bridges on 05/05/2017.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
//  and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions 
//  of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
//  TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import AppKit
import Foundation

public class Prompter {
    
    public struct PromptResult {
        
        public enum PromptType {
            case rate
            case viewOtherApp(otherApp: OtherAppPromptInfo)
        }
        
        public let promptType: PromptType
        public let wasSelected: Bool
        public let isPromptsToBeSuppressedInFuture: Bool
    }
    
    // MARK: Enum
    
    enum PrompterError: Error {
        case unableToParsePlist
    }
    
    // MARK: Keys
    
    private let ConfigFileName: String = "PrompterConfig"
    private let RunCountKey: String = "runCount"
    private let StopRateKey: String = "stopRate"
    private let RateAppIntervalKey: String = "rateAppPromptInterval"
    private let AppURLKey: String = "appURL"
    private let OtherAppsKey: String = "otherApps"
    
    // MARK: Logging Classes
    
    let eventLogger: EventTrackingLogger.Type?
    let debugLogger: DebugLogger.Type?
    
    // MARK: Private Properties

    private let persistantData = UserDefaults.standard
    private let appName: String = NSRunningApplication.current().localizedName ?? ""
    private let otherAppPromptInfos: [OtherAppPromptInfo]
    private let appURL: URL
    private let rateAppPromptInterval: Int
    private let delay: TimeInterval = 1
    
    private var runCount: Int {
        get {
            return persistantData.integer(forKey: RunCountKey)
        } set {
            persistantData.set(newValue, forKey: RunCountKey)
        }
    }

    // MARK: Initialiser
    
   public init(eventLogger: EventTrackingLogger.Type? = nil, debugLogger: DebugLogger.Type? = nil) throws {
        
        guard
            let url: URL = Bundle.main.url(forResource: self.ConfigFileName, withExtension: "plist"),
            let config = NSDictionary(contentsOf: url) as? [String : Any],
            let otherAppDictionaries = config[OtherAppsKey] as? [[String : Any]],
            let rateAppPromptInterval = config[RateAppIntervalKey] as? Int,
            let appURLString = config[AppURLKey] as? String,
            let appURL = URL(string: appURLString) else {
                throw PrompterError.unableToParsePlist
        }
        
        self.otherAppPromptInfos = try otherAppDictionaries.map{ try OtherAppPromptInfo(dictionary: $0) }
        self.appURL = appURL
        self.rateAppPromptInterval = rateAppPromptInterval
        self.eventLogger = eventLogger
        self.debugLogger = debugLogger
    }
    
    // MARK: Functions

    public func runWithCompletion(completion: ((PromptResult) -> Void)? = nil) {
        
        runCount = runCount + 1
        
        debugLogger?.log("Prompter has been run \(runCount) times")
        
        if !persistantData.bool(forKey: StopRateKey) && ((runCount % rateAppPromptInterval) == 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay,
                                          execute: { [weak self] in
                                            self?.showRateAppPromptWithCompletion(completion: completion)
            })
        }
        else {
            let shuffledOtherAppPromptInfos = otherAppPromptInfos.shuffled()
            for otherAppPromptInfo in shuffledOtherAppPromptInfos {
                
                if otherAppPromptInfo.promptInterval > 0 {
                    if !persistantData.bool(forKey: otherAppPromptInfo.stopKey) && ((runCount % otherAppPromptInfo.promptInterval) == 0) {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay,
                                                      execute: { [weak self] in
                                                        self?.showOtherAppPrompt(for: otherAppPromptInfo, withCompletion: completion)
                        })
                        break
                    }
                }
            }
        }
    }
    
    private func showRateAppPromptWithCompletion(completion: ((PromptResult) -> Void)?) {
        let alert = NSAlert()
        alert.messageText = appName
        alert.informativeText = String(format: "prompter.rateAppAlert.title".localized, appName)
        alert.showsSuppressionButton = true
        alert.suppressionButton?.title = "prompter.alert.dontAskAgain".localized
        alert.addButton(withTitle: "prompter.alert.rateNow".localized)
        alert.addButton(withTitle: "prompter.alert.noThanks".localized)
        alert.window.level = Int(CGWindowLevelForKey(CGWindowLevelKey.popUpMenuWindow))
        
        let result: Int = alert.runModal()
        
        let alertWasSuppressed = alert.suppressionButton?.state == NSOnState

        if alertWasSuppressed {
            persistantData.set(true, forKey: StopRateKey)
            debugLogger?.log("Suppressed")
            eventLogger?.logEvent("rate_app_suppressed")
        }
        
        switch result {
        case NSAlertFirstButtonReturn:
            debugLogger?.log("Will Rate")
            NSWorkspace.shared().open(appURL)
            persistantData.set(true, forKey: StopRateKey)
            eventLogger?.logEvent("rate_app_selected")
            completion?(PromptResult(promptType: .rate, wasSelected: true, isPromptsToBeSuppressedInFuture: alertWasSuppressed))
            
        default:
            eventLogger?.logEvent("rate_app_dismissed")
            completion?(PromptResult(promptType: .rate, wasSelected: false, isPromptsToBeSuppressedInFuture: alertWasSuppressed))
            
        }
        
    }
    
    private func showOtherAppPrompt(for otherAppPromptInfo: OtherAppPromptInfo, withCompletion completion: ((PromptResult) -> Void)? ) {
        
        let alert = NSAlert()
        alert.messageText = otherAppPromptInfo.name
        alert.informativeText = String(format: "prompter.viewOtherAppsAlert.title".localized, appName, otherAppPromptInfo.name)
        alert.showsSuppressionButton = true
        alert.suppressionButton?.title = "prompter.alert.dontAskAgain".localized
        alert.addButton(withTitle: "prompter.alert.viewInStore".localized)
        alert.addButton(withTitle: "prompter.alert.noThanks".localized)
        alert.icon = otherAppPromptInfo.image
        alert.window.level = Int(CGWindowLevelForKey(CGWindowLevelKey.popUpMenuWindow))
        
        let result: Int = alert.runModal()
        
        let alertWasSuppressed = alert.suppressionButton?.state == NSOnState
        
        if alertWasSuppressed {
            persistantData.set(true, forKey: otherAppPromptInfo.stopKey)
            debugLogger?.log("Suppressed")
            eventLogger?.logEvent("view_other_app_suppressed", parameters: ["app_name" : otherAppPromptInfo.name])
        }

        switch result {
        case NSAlertFirstButtonReturn:
            debugLogger?.log("Will Rate")
            NSWorkspace.shared().open(otherAppPromptInfo.url)
            persistantData.set(true, forKey: otherAppPromptInfo.stopKey)
            eventLogger?.logEvent("view_other_app_selected", parameters: ["app_name" : otherAppPromptInfo.name])
            completion?(PromptResult(promptType: .viewOtherApp(otherApp: otherAppPromptInfo),
                                     wasSelected: true,
                                     isPromptsToBeSuppressedInFuture: alertWasSuppressed))
            
        default:
            eventLogger?.logEvent("view_other_app_dismissed", parameters: ["app_name" : otherAppPromptInfo.name])
            completion?(PromptResult(promptType: .viewOtherApp(otherApp: otherAppPromptInfo),
                                     wasSelected: false,
                                     isPromptsToBeSuppressedInFuture: alertWasSuppressed))
            
        }
    }
}
