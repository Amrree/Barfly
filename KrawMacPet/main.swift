import Cocoa

print("Starting Mac Pet application...")

let app = NSApplication.shared
let delegate = SimpleMacPet()
app.delegate = delegate

print("App delegate set, starting run loop...")
app.run()
