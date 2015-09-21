import AppKit
import ApplicationServices.HIServices

@IBObject @NSApplicationMain class AppDelegate : INSApplicationDelegate {

	var mainWindowController: MainWindowController?

	public func applicationDidFinishLaunching(notification: NSNotification!) {

		NSAppleEventManager.sharedAppleEventManager.setEventHandler(self, andSelector: "handleGetURLEvent:withReplyEvent:", forEventClass: kInternetEventClass, andEventID: kAEGetURL)

		mainWindowController = MainWindowController();
		mainWindowController?.showWindow(nil);
	}
	
	public func applicationWillTerminate(_ aNotification: NSNotification!) {
		mainWindowController?.close()
	}
	
	public func handleGetURLEvent(_ event: NSAppleEventDescriptor!, withReplyEvent replyEvent: NSAppleEventDescriptor!) {
		NSLog("handleGetURLEvent:withReplyEvent:")
		let url = NSURL.URLWithString(event.paramDescriptorForKeyword(keyDirectObject)?.stringValue);
		NSLog("%@", url);
	}
	
	@IBAction func restart(sender: Any?) {
		mainWindowController?.restartElements()
		mainWindowController?.restartDataAbstract()
	}
	
}
