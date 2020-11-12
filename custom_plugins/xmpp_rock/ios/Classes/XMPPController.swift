
import Foundation
import XMPPFramework
import RxSwift

enum XMPPControllerError: Error {
    case wrongUserJID
}

class XMPPController: NSObject {
    var xmppStream: XMPPStream = XMPPStream()
    private var xmppAutoPing: XMPPAutoPing!
    var hostName: String = ""
    var hostPort: UInt16 = 5222
    var password: String = ""
    
    override init() {
    }

    func initialize(hostName: String, userJIDString: String, hostPort: UInt16 = 443, password: String) throws {
        guard let userJID = XMPPJID(string: userJIDString) else {
            throw XMPPControllerError.wrongUserJID
        }

        self.hostName = hostName
        self.hostPort = hostPort
        self.password = password

        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppStream.myJID = userJID
        self.xmppStream.keepAliveInterval = 10
        self.xmppStream.enableBackgroundingOnSocket = true
        self.xmppAutoPing = XMPPAutoPing(dispatchQueue: DispatchQueue.main)
        self.xmppAutoPing?.activate(xmppStream)
        self.xmppAutoPing?.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.xmppAutoPing?.pingInterval = 2
        self.xmppAutoPing?.pingTimeout = 2

        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }


    private func goOnline() {
        let presence = XMPPPresence()
        let domain = self.xmppStream.myJID?.domain

        if domain == "xmpp.yellowmssngr.com" {
            let priority = DDXMLElement.element(withName: "priority", stringValue: "1") as! DDXMLElement
            presence.addChild(priority)
        }
        xmppStream.send(presence)
    }

    private func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        xmppStream.send(presence)
    }

    func connect() -> Bool {
        if (!self.xmppStream.isDisconnected) {
            return true
        }
        do {
              try xmppStream.oldSchoolSecureConnect(withTimeout: 2)
           
                                   return true
                               } catch let error {
                               print("Something went wrong! \(error)")
                                   return false
                               }

    }

    func disconnect() {
        goOffline()
        xmppStream.disconnect()
           
    }

}

extension XMPPController: XMPPStreamDelegate {

    func xmppStreamWillConnect(_ sender: XMPPStream) {
        print("will connect")
    }

    func xmppStreamConnectDidTimeout(_ sender: XMPPStream) {
        print("timeout:")
        MyBus.shared.myBus().send(s: "{\"connected\" : false}")
    }

    func xmppStreamDidConnect(_ stream: XMPPStream) {
        print("Stream: Connected")
        
        do {
            try stream.authenticate(withPassword: self.password)
        } catch let error {
            print("Auth Error: \(error)")
            MyBus.shared.myBus().send(s: "{\"authenticated\" : false}")
            MyBus.shared.myBus().send(s: "{\"connected\" : false}")
        }

    }
    
    func xmppStreamDidDisconnect(stream: XMPPStream, withError error: NSError){
        print("disconnected");
        MyBus.shared.myBus().send(s: "{\"connected\" : false}")
        
    }

    func xmppStreamDidNotConnect(_ stream: XMPPStream) {
        print("Stream: Not Connected")
        MyBus.shared.myBus().send(s: "{\"connected\" : false}")
    }

    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        //self.xmppStream.send(XMPPPresence())
        print("Stream: Authenticated")
        MyBus.shared.myBus().send(s: "{\"connected\" : true}")
        MyBus.shared.myBus().send(s: "{\"authenticated\" : true}")
        goOnline()

    }
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
        print("Did receive IQ")
        return false
    }

    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print(message)
        if let msg = message.body {
            print(msg)
            MyBus.shared.myBus().send(s: msg)
        }
    }

    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {
        print("Did send message \(String(describing: message))")
    }


    func xmppRoster(sender: XMPPRoster!, didReceiveRosterItem item: DDXMLElement!) {
        print("Did receive Roster item")
    }
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        print("Stream: Failed to Authenticate")
        MyBus.shared.myBus().send(s: "{\"connected\" : false}")
        MyBus.shared.myBus().send(s: "{\"authenticated\" : false}")
    }

    func xmppStream(_ sender: XMPPStream, didReceiveError error: DDXMLElement) {
           print(error)
       }
  

    func xmppStream(_ sender: XMPPStream, didReceive trust: SecTrust, completionHandler: ((Bool) -> Void)) {
               completionHandler(true)
           }

    func xmppStream(_ sender: XMPPStream, willSecureWithSettings settings: NSMutableDictionary) {
               print("willSecureWithSettings")
               settings.setObject(true, forKey:GCDAsyncSocketManuallyEvaluateTrust as NSCopying)
           }
    
    

}

