//
//  AppDelegate.swift
//  musicBar
//
//  Created by Daniel Ma on 2/20/16.
//  Copyright © 2016 Daniel Ma. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var popupLabel: NSTextFieldCell!

  enum PomodoroMode: String {
    case Work = "👔"
    case Break = "☕"
    case LongBreak = "😴"
    case Disabled = "🍅"
  }

  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
  let menu = NSMenu()
  let workTime = 25 * 60.0
  let breakTime = 5 * 60.0
  let longBreakTime = 15 * 60.0
  let longBreakInterval = 4
  let showSeconds = false
  let completedCountMenuItem = NSMenuItem(title: "Completed: 0", action: nil, keyEquivalent: "")
  var completedPomodoros = 0
  var startedSectionAt = 0
  var countdownUntil = NSDate()
  var currentMode = PomodoroMode.Disabled
  var currentTimer = NSTimer()
  var userNotifications = NSUserNotificationCenter.defaultUserNotificationCenter()
  var notificationCenter = NSNotificationCenter.defaultCenter()

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    updateMenuText()
    menu.addItem(NSMenuItem(title: "👔 Work", action: Selector("startWorkMode:"), keyEquivalent: "s"))
    menu.addItem(NSMenuItem(title: "☕ Break", action: Selector("startBreakMode:"), keyEquivalent: "b"))
    menu.addItem(NSMenuItem(title: "🔌 Disable", action: Selector("startDisabledMode:"), keyEquivalent: "d"))
    menu.addItem(NSMenuItem.separatorItem())
    menu.addItem(self.completedCountMenuItem)
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

  func startLongBreakMode(sender: AnyObject) {
    ensureTimer()
    currentMode = .LongBreak
    countdownUntil = NSDate(timeIntervalSinceNow: longBreakTime)
    showNotification("Long break time!")
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
      if (currentMode == .Break || currentMode == .LongBreak) {
        startWorkMode("")
      } else {
        completedPomodoro()
      }
    } else {
      updateMenuText()
    }
  }

  func completedPomodoro() {
    completedPomodoros = completedPomodoros + 1
    completedCountMenuItem.title = "Completed: \(completedPomodoros)"

    if (completedPomodoros % longBreakInterval == 0) {
      startLongBreakMode("")
    } else {
      startBreakMode("")
    }
  }
  
  func updateMenuText() {
    if let button = statusItem.button {
      let timeLeftInMode = stringFromTimeInterval(countdownUntil.timeIntervalSinceNow)
      button.title = "\(currentMode.rawValue) \(timeLeftInMode)"
    }
  }

  func showNotification(text: String) {
    let notification:NSUserNotification = NSUserNotification()
    notification.title = "Robomodoro"
    notification.subtitle = "\(currentMode.rawValue) \(text)"
    notification.soundName = NSUserNotificationDefaultSoundName

    userNotifications.scheduleNotification(notification)
  }

  // thanks http://stackoverflow.com/a/28872601/4499924
  func stringFromTimeInterval(interval: NSTimeInterval) -> NSString {
    if (interval < 1.0) { return "" }

    let intervalAsInteger = Int(interval)
    let seconds = intervalAsInteger % 60
    let minutes = Int(showSeconds ? (intervalAsInteger / 60) % 60 : round(interval / 60.0) % 60)

    if (showSeconds) {
      return NSString(format: "%0.2d:%0.2d", minutes, seconds)
    } else {
      return NSString(format: "%0.1d", minutes)
    }
  }

  func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
    return true
  }
}
