import AppKit

typealias Any = protocol<>
typealias Int = Int32

@IBObject public class MainWindowController : NSWindowController {

	init() {
		super.init(windowNibName: "MainWindowController");
	}
	
	public var path1: String? {
		get {
			return NSUserDefaults.standardUserDefaults.stringForKey("Path1")
		}
		set {
			NSUserDefaults.standardUserDefaults.setObject(newValue, forKey: "Path1")
			restart1()
		}
	}
	
	public var path2: String? {
		get {
			return NSUserDefaults.standardUserDefaults.stringForKey("Path2")
		}
		set {
			NSUserDefaults.standardUserDefaults.setObject(newValue, forKey: "Path2")
			restart2()
		}
	}
	
	public var path3: String? {
		get {
			return NSUserDefaults.standardUserDefaults.stringForKey("Path3")
		}
		set {
			NSUserDefaults.standardUserDefaults.setObject(newValue, forKey: "Path3")
			restart3()
		}
	}
	
	public var path4: String? {
		get {
			return NSUserDefaults.standardUserDefaults.stringForKey("Path4")
		}
		set {
			NSUserDefaults.standardUserDefaults.setObject(newValue, forKey: "Path4")
			restart4()
		}
	}
	
	public var reviewMode: Boolean {
		get {
			return NSUserDefaults.standardUserDefaults.boolForKey("ReviewMode")
		}
		set {
			NSUserDefaults.standardUserDefaults.setBool(newValue, forKey: "ReviewMode")
			restartAll()
		}
	}

	@IBAction func restart(sender: Any?) {
		restartAll()
	}

	private var docsGenPath:String {
		get {
			return NSBundle.mainBundle.pathForResource("Bin", ofType: "")?.stringByAppendingPathComponent("DocsGen.exe")
		}
	}
	
	@IBAction func browseURL(url: String) {
		if reviewMode { 
			url += "__status.html"
		}
		NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString(url))
	}

	@IBAction func browse1(sender: Any?) {
		browseURL("http://localhost:4001/")
	}
	
	@IBAction func browse2(sender: Any?) {
		browseURL("http://localhost:4002/")
	}

	@IBAction func browse3(sender: Any?) {
		browseURL("http://localhost:4003/")
	}

	@IBAction func browse4(sender: Any?) {
		browseURL("http://localhost:4004/")
	}

   /* @IBAction func pullDA(sender: Any?) {
		enableGitButtons(false)
		/*runTask("/usr/bin/git", folder: path1, arguments: ["fetch"], callback: { (success: Bool) in 
			self.enableGitButtons(true) 
			if success {
				self.runTask("/usr/bin/git", folder: self.path1, arguments: ["pull"], callback: { (success2: Bool) in
					self.enableGitButtons(true)
					if !success2 {
						self.showError("Pull Failed.")
					}
				})
			} else {
				self.showError("Fetch Failed.")
			}
		})*/
	}

	@IBAction func pushDA(sender: Any?) {
		enableGitButtons(false)
		/*runTask("/usr/bin/git", folder: path1, arguments: ["commit","-m", "LatestReviews"], callback: { (success: Bool) in
			if success {
				self.runTask("/usr/bin/git", folder: self.path1, arguments: ["push"], callback: { (success2: Bool) in
					self.enableGitButtons(true)
					if !success2 {
						self.showError("Push Failed.")
					}
				})
			} else {
				self.enableGitButtons(true)
				self.showError("Commit Failed.")
			}
		})*/
	}

	@IBAction func pullElements(sender: Any?) {
		enableGitButtons(false)
		/*runTask("/usr/bin/git", folder: path2, arguments: ["fetch"], callback: { (success: Bool) in 
			self.enableGitButtons(true)
			if success {
				self.runTask("/usr/bin/git", folder: self.path2, arguments: ["pull", "-v"], callback: { (success2: Bool) in
					self.enableGitButtons(true)
					if !success2 {
						self.showError("Pull Failed.")
					}
				})
			} else {
				self.showError("Fetch Failed.")
			}
		})*/
	}

	@IBAction func pushElements(sender: Any?) {
		enableGitButtons(false)
		/*runTask("/usr/bin/git", folder: path2, arguments: ["commit","-m", "LatestReviews"], callback: { (success: Bool) in
			if success {
				self.runTask("/usr/bin/git", folder: self.path2, arguments: ["push"], callback: { (success2: Bool) in
					self.enableGitButtons(true)
					if !success2 {
						self.showError("Push Failed.")
					}
				})
			} else {
				self.enableGitButtons(true)
				self.showError("Commit Failed.")
			}
		})*/
	}*/
	
	private func enableGitButtons(enabled: Bool) {
		/*pullElementsButton.enabled = enabled
		pushElementsButton.enabled = enabled
		pullDAButton.enabled = enabled
		pushDAButton.enabled = enabled*/
	}
	
	private func logLine(line: String) {
		NSLog("%@", line)
		log.textStorage!.beginEditing()
		log.textStorage!.mutableString.appendString(line)
		log.textStorage!.mutableString.appendString("\n")
		log.textStorage!.endEditing()
		log.scrollRangeToVisible(NSMakeRange(log.textStorage!.mutableString.length-1, 0))
	}

	private func showError(message: String) {
		NSLog("%@", message)
		logLine(message.uppercaseString)
		let alert = NSAlert()
		alert.messageText = message
		alert.informativeText = message
		alert.alertStyle = .NSCriticalAlertStyle // should be .CriticalAlertStyle
		alert.beginSheetModalForWindow(window!, completionHandler: {})
	}
	
	@IBOutlet var browseDAButton: NSButton!
	@IBOutlet var pullDAButton: NSButton!
	@IBOutlet var pushDAButton: NSButton!
	@IBOutlet var browseElementsButton: NSButton!
	@IBOutlet var pullElementsButton: NSButton!
	@IBOutlet var pushElementsButton: NSButton!
	@IBOutlet var browseTrainButton: NSButton!
	@IBOutlet var browseCIButton: NSButton!
	@IBOutlet var log: NSTextView!
	
	var task1: NSTask?
	func restart1() {
		task1 = restartOldTask(task1, port: 4001, folder: path2)
	}

	var task2: NSTask?
	func restart2() {
		task2 = restartOldTask(task2, port: 4002, folder: path1)
	}
	
	var task3: NSTask?
	func restart3() {
		task3 = restartOldTask(task3, port: 4003, folder: path3)
	}
	
	var task4: NSTask?
	func restart4() {
		task4 = restartOldTask(task4, port: 4004, folder: path4)
	}

	func restartAll() {
		restart1()
		restart2()
		restart3()
		restart4()
	}

	func processTaskOutputFromStdOut(stdOut: NSFileHandle, name: String, lastIncompleteLogLine: String?) {
		let d = stdOut.availableData;
		if (d != nil && d.length > 0) {
			var rawString = NSString(data: d, encoding: .NSUTF8StringEncoding)
			if let last = lastIncompleteLogLine {
				rawString = last.stringByAppendingString(rawString);
				lastIncompleteLogLine = nil;
			}
			let lines = rawString.componentsSeparatedByString("\n");
			for var i: Int = 0; i < lines.count; i++ {
				let s: String = lines[i]!;
				if i == lines.count-1 && !s.hasSuffix("\n") {
					if s.length > 0 {
						lastIncompleteLogLine = s;
					}
					break;
				}
				dispatch_async(dispatch_get_main_queue()) {
					self.logLine("["+name+"] "+s!);
				}
			}
		}
	}
	
	func processTaskOutput(task: NSTask, name: String) {
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			let stdOut = task.standardOutput!.fileHandleForReading
			var lastIncompleteLogLine: String?
			
			while task.isRunning { 
				autoreleasepool {
					self.processTaskOutputFromStdOut(stdOut, name: name, lastIncompleteLogLine: lastIncompleteLogLine)
					NSRunLoop.currentRunLoop().runUntilDate(NSDate.date)
				}
			}
		}
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			let stdOut = task.standardError!.fileHandleForReading
			var lastIncompleteLogLine: String?
			
			while task.isRunning { 
				autoreleasepool {
					self.processTaskOutputFromStdOut(stdOut, name: name+" (stderr)", lastIncompleteLogLine: lastIncompleteLogLine)
					NSRunLoop.currentRunLoop().runUntilDate(NSDate.date)
				}
			}
		}
	}
	
	
	func runTask(exe: String, folder: String, arguments: Object[], callback: (Bool)->() ) {
		let task = NSTask()
		task.arguments = NSArray.arrayWithObjects((&arguments[0]) as! UnsafePointer<id>, count: length(arguments)) // workaround
		NSLog("%@", task.arguments)
		task.launchPath = exe
		task.currentDirectoryPath = folder

		task.setStandardOutput(NSPipe.pipe)

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			task.launch()

			let stdOut = task.standardOutput!.fileHandleForReading
			var lastIncompleteLogLine: String?
			
			while task.isRunning { 
				autoreleasepool {
					self.processTaskOutputFromStdOut(stdOut, name: exe.lastPathComponent+" "+arguments[0], lastIncompleteLogLine: lastIncompleteLogLine)
					NSRunLoop.currentRunLoop().runUntilDate(NSDate.date)
				}
			}
			dispatch_async(dispatch_get_main_queue()) {
				self.logLine(NSString.stringWithFormat("Exit code %d", task.terminationStatus))
				callback(task.terminationStatus == 0)
			}
		}
	}
	
	func restartOldTask(oldTask:NSTask?, port:Int, folder: String?) -> NSTask? {
		if let task = oldTask {
			task.terminate();
		}
		if length(folder) > 0 {
			let result = NSTask()
			//let args: [String] = [String](arrayLiteral: [docsGenPath, "serve", folder!, "--port", port.stringValue, "--loop"])
			let args: NSMutableArray! = [docsGenPath, "serve", folder!, "--port", port.stringValue, "--loop"]
			if reviewMode {
				args.addObject("--edit")
			}
			result.arguments = args
			
			let env = ["MONO_MANAGED_WATCHER" : "false"]
			result.environment = env
			
			result.launchPath = "/usr/local/bin/mono"
			if !NSFileManager.defaultManager.fileExistsAtPath(result.launchPath!) {
				result.launchPath = "/Library/Frameworks/Mono.framework/Versions/Current/bin/mono"
			}
			result.setStandardInput(NSPipe.pipe)
			result.setStandardOutput(NSPipe.pipe)
			result.setStandardError(NSPipe.pipe)
			result.launch()
			processTaskOutput(result, name: folder!.lastPathComponent)
			
			NSLog("Starting %@ %@", result.launchPath, result.arguments)
			return result
		} else {
			return nil
		}
	}
	
	public override func close() {
		restartOldTask(task1, port: 4001, folder: nil)
		restartOldTask(task2, port: 4002, folder: nil)
		restartOldTask(task3, port: 4003, folder: nil)
		restartOldTask(task4, port: 4004, folder: nil)
	}

	public override func windowDidLoad() {

		super.windowDidLoad()
		restart(nil)
	}

}
