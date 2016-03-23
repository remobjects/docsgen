import AppKit
import ApplicationServices.HIServices

@IBObject @NSApplicationMain class AppDelegate : INSApplicationDelegate {

	var mainWindowController: MainWindowController?

	public func applicationDidFinishLaunching(notification: NSNotification!) {

		NSAppleEventManager.sharedAppleEventManager.setEventHandler(self, andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)), forEventClass: kInternetEventClass, andEventID: kAEGetURL)

		mainWindowController = MainWindowController();
		mainWindowController?.showWindow(nil);
	}
	
	public func applicationWillTerminate(_ aNotification: NSNotification!) {
		mainWindowController?.close()
	}
	
	public func handleGetURLEvent(_ event: NSAppleEventDescriptor!, withReplyEvent replyEvent: NSAppleEventDescriptor!) {
		NSLog("handleGetURLEvent:withReplyEvent:")
		if let urlString = event.paramDescriptorForKeyword(keyDirectObject)?.stringValue {
			let url = NSURL.URLWithString(urlString);
			NSLog("%@", url);
		}
	}
	
	@IBAction func restart(sender: Any?) {
		mainWindowController?.restart1()
		mainWindowController?.restart2()
		mainWindowController?.restart3()
		mainWindowController?.restart4()
	}
	
}
