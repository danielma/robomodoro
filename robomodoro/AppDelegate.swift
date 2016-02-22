//
//  AppDelegate.swift
//  musicBar
//
//  Created by Daniel Ma on 2/20/16.
//  Copyright © 2016 Daniel Ma. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var popupLabel: NSTextFieldCell!

  enum PomodoroMode: String {
    case Work = "👔"
    case Break = "☕"
    case Disabled = "🍅"
  }

  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
  let menu = NSMenu()
  let workTime = 25 * 60.0
  let breakTime = 5 * 60.0
  var startedSectionAt = 0
  var countdownUntil = NSDate()
  var currentMode = PomodoroMode.Disabled
  var currentTimer = NSTimer()

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    updateMenuText()
    menu.addItem(NSMenuItem(title: "👔 Work", action: Selector("startWorkMode:"), keyEquivalent: "s"))
    menu.addItem(NSMenuItem(title: "☕ Break", action: Selector("startBreakMode:"), keyEquivalent: "b"))
    menu.addItem(NSMenuItem(title: "🔌 Disable", action: Selector("startDisabledMode:"), keyEquivalent: "d"))
    menu.addItem(NSMenuItem.separatorItem())
    menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
    
    statusItem.menu = menu
  }
  
  func applicationWillTerminate(aNotification: NSNotification) {
  }

  func ensureTimer() {
    if (!currentTimer.valid) {
      currentTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateMenuTextFromTimer:"), userInfo: nil, repeats: true)
      currentTimer.tolerance = 0.5
    }
  }

  func startWorkMode(sender: AnyObject) {
    ensureTimer()
    currentMode = .Work
    countdownUntil = NSDate(timeIntervalSinceNow: workTime)
    showNotification("Work time!")
    updateMenuText()
  }

  func startBreakMode(sender: AnyObject) {
    ensureTimer()
    currentMode = .Break
    countdownUntil = NSDate(timeIntervalSinceNow: breakTime)
    showNotification("Break time!")
    updateMenuText()
  }

  func startDisabledMode(sender: AnyObject) {
    currentTimer.invalidate()
    currentMode = .Disabled
    countdownUntil = NSDate()
    updateMenuText()
  }

  func updateMenuTextFromTimer(sender: AnyObject) {
    let timeLeftInMode = countdownUntil.timeIntervalSinceNow

    if (timeLeftInMode <= 0) {
      if (currentMode == .Break) {
        startWorkMode("")
      } else {
        startBreakMode("")
      }
    } else {
      updateMenuText()
    }
  }
  
  func updateMenuText() {
    if let button = statusItem.button {
      let timeLeftInMode = stringFromTimeInterval(countdownUntil.timeIntervalSinceNow)
      button.title = "\(currentMode.rawValue) \(timeLeftInMode)"
    }
  }

  func showNotification(text: String) {
    //let myPopup: NSAlert = NSAlert()
    //myPopup.messageText = text
    //myPopup.informativeText = "With love, PiCO Modoro"
    //myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
    //myPopup.addButtonWithTitle("OK")
    //myPopup.runModal()

    // NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    popupLabel.title = text
    window.orderFrontRegardless()

    let delta: Int64 = 3 * Int64(NSEC_PER_SEC)
    let time = dispatch_time(DISPATCH_TIME_NOW, delta)

    dispatch_after(time, dispatch_get_main_queue(), {
      self.window.orderOut("")
    })
  }

  // thanks http://stackoverflow.com/a/28872601/4499924
  func stringFromTimeInterval(interval: NSTimeInterval) -> NSString {
    if (interval < 1.0) { return "" }

    let intervalAsInteger = Int(interval)
    let seconds = intervalAsInteger % 60
    let minutes = (intervalAsInteger / 60) % 60

    return NSString(format: "%0.2d:%0.2d", minutes, seconds)
  }
}
