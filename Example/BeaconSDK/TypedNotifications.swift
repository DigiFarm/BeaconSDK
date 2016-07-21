import Foundation

class Box<T> {
    
    let unbox: T
    
    init(_ value: T) {
        self.unbox = value
    }
}

struct Notification<A> {
    let name: String
}

func postNotification<A>(note: Notification<A>, value: A) {
    let userInfo = ["value": Box(value)]
    NSNotificationCenter.defaultCenter().postNotificationName(note.name, object: nil, userInfo: userInfo)
}

class NotificationObserver {
    let observer: NSObjectProtocol
    
    init<A>(notification: Notification<A>, queue: NSOperationQueue?, block aBlock: A -> ()) {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(notification.name, object: nil, queue: queue) { note in
            if let value = (note.userInfo?["value"] as? Box<A>)?.unbox {
                aBlock(value)
            } else {
                assert(false, "Couldn't understand user info")
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
    
}