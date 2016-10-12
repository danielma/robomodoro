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

  let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
  let menu = NSMenu()
  let workTime = 25 * 60.0
  let breakTime = 5 * 60.0
  let longBreakTime = 15 * 60.0
  let longBreakInterval = 4
  let showSeconds = false
  let completedCountMenuItem = NSMenuItem(title: "Completed: 0", action: nil, keyEquivalent: "")
  var completedPomodoros = 0
  var startedSectionAt = 0
  var countdownUntil = Date()
  var currentMode = PomodoroMode.Disabled
  var currentTimer = Timer()
  var userNotifications = NSUserNotificationCenter.default
  var notificationCenter = NotificationCenter.default

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    updateMenuText()
    menu.addItem(NSMenuItem(title: "👔 Work", action: #selector(startWorkMode), keyEquivalent: "s"))
    menu.addItem(NSMenuItem(title: "☕ Break", action: #selector(startBreakMode), keyEquivalent: "b"))
    menu.addItem(NSMenuItem(title: "🔌 Disable", action: #selector(startDisabledMode), keyEquivalent: "d"))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(self.completedCountMenuItem)
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "About robomodoro", action: #selector(showAboutWindow), keyEquivalent: ""))
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(terminate), keyEquivalent: "q"))
    
    statusItem.menu = menu
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
  }

  func ensureTimer() {
    if (!currentTimer.isValid) {
      currentTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateMenuTextFromTimer), userInfo: nil, repeats: true)
      currentTimer.tolerance = 0.5
    }
  }

  func showAboutWindow(_ sender: AnyObject) {
    NSApplication.shared().orderFrontStandardAboutPanel("")
  }

  func terminate(_ sender: AnyObject) {
    NSApplication.shared().terminate(self)
  }

  func startWorkMode(_ sender: AnyObject) {
    ensureTimer()
    currentMode = .Work
    countdownUntil = Date(timeIntervalSinceNow: workTime)
    showNotification("Work time!")
    updateMenuText()
  }

  func startBreakMode(_ sender: AnyObject) {
    ensureTimer()
    currentMode = .Break
    countdownUntil = Date(timeIntervalSinceNow: breakTime)
    showNotification("Break time!")
    updateMenuText()
  }

  func startLongBreakMode(_ sender: AnyObject) {
    ensureTimer()
    currentMode = .LongBreak
    countdownUntil = Date(timeIntervalSinceNow: longBreakTime)
    showNotification("Long break time!")
    updateMenuText()
  }

  func startDisabledMode(_ sender: AnyObject) {
    currentTimer.invalidate()
    currentMode = .Disabled
    countdownUntil = Date()
    updateMenuText()
  }

  func updateMenuTextFromTimer(_ sender: AnyObject) {
    let timeLeftInMode = countdownUntil.timeIntervalSinceNow

    if (timeLeftInMode <= 0) {
      if (currentMode == .Break || currentMode == .LongBreak) {
        startWorkMode("" as AnyObject)
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
      startLongBreakMode("" as AnyObject)
    } else {
      startBreakMode("" as AnyObject)
    }
  }
  
  func updateMenuText() {
    if let button = statusItem.button {
      let timeLeftInMode = stringFromTimeInterval(countdownUntil.timeIntervalSinceNow)
      button.title = "\(currentMode.rawValue) \(timeLeftInMode)"
    }
  }

  func showNotification(_ text: String) {
    let notification:NSUserNotification = NSUserNotification()
    notification.identifier = "com.danielma.robomodoro-notification"
    notification.title = "Robomodoro"
    notification.subtitle = "\(currentMode.rawValue) \(text)"
    notification.soundName = NSUserNotificationDefaultSoundName

    userNotifications.scheduleNotification(notification)
  }

  // thanks http://stackoverflow.com/a/28872601/4499924
  func stringFromTimeInterval(_ interval: TimeInterval) -> NSString {
    if (interval < 1.0) { return "" }

    let intervalAsInteger = Int(interval)
    let seconds = intervalAsInteger % 60
    let minutes = Int(showSeconds ?
      (intervalAsInteger / 60) % 60 :
      Int(round(interval / 60.0)) % 60)

    if (showSeconds) {
      return NSString(format: "%0.2d:%0.2d", minutes, seconds)
    } else {
      return NSString(format: "%0.1d", minutes)
    }
  }

  func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
    return true
  }
}
