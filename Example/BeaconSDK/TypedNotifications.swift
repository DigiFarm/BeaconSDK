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

func postNotification<A>(_ note: Notification<A>, value: A) {
    let userInfo = ["value": Box(value)]
    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: note.name), object: nil, userInfo: userInfo)
}

class NotificationObserver {
    let observer: NSObjectProtocol
    
    init<A>(notification: Notification<A>, queue: OperationQueue?, block aBlock: @escaping (A) -> ()) {
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: notification.name), object: nil, queue: queue) { note in
            if let value = ((note as NSNotification).userInfo?["value"] as? Box<A>)?.unbox {
                aBlock(value)
            } else {
                assert(false, "Couldn't understand user info")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
    
}
