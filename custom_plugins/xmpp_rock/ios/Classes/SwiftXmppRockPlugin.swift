import Flutter
import UIKit
import XMPPFramework

public class SwiftXmppRockPlugin: NSObject, FlutterPlugin {
    let xmppController: XMPPController
    
    public override init() {
        xmppController = XMPPController()
    }
    
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannelName = "com.yellowmessenger.xmpp/methods"
    let eventChannelName = "com.yellowmessenger.xmpp/stream"
    
    let channel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: registrar.messenger())
       let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: registrar.messenger())
          eventChannel.setStreamHandler(EventStreamHandler())
       let instance = SwiftXmppRockPlugin()
       registrar.addMethodCallDelegate(instance, channel: channel)
    
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
      switch call.method {
      case "initializeXMPP":
           
         
               guard let args = call.arguments else {
                 return
               }
               if let myArgs = args as? [String: Any],
                  let xmppJid = myArgs["fullJid"] as? String, let xmppPassword = myArgs["password"] as? String, let port = myArgs["port"] as? Int
                   {
                    let jid:XMPPJID = XMPPJID(string: xmppJid)!
                    try! self.xmppController.initialize(hostName: jid.domain,
                                                        userJIDString: (jid.user ?? "") + "@xmpp.yellowmssngr.com",
                                                        hostPort: UInt16(port), password: xmppPassword
                )

                  if (!xmppController.xmppStream.isConnected) {
                  let connectionStatus = xmppController.connect()
                    result(connectionStatus)
          }
          else{
            self.xmppController.disconnect()
            let connectionStatus = xmppController.connect()
            result(connectionStatus)
          }
                   
               } else {
                 result("iOS could not extract flutter arguments in method: (initializeXMPP)")
               }
                
          
          break
      case "closeConnection":
              self.xmppController.disconnect()
              break

      default:
          result("No Method Configured.")
        
      }
    }
}
class EventStreamHandler: NSObject, FlutterStreamHandler {
    override init() {
        
    }
    
    private var _eventSink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventSink = events
        events("Stream Connected")
        if(!MyBus.shared.myBus().hasObservers()){
        MyBus.shared.myBus().toObservable()
            .subscribe(onNext : {
                events($0)
            })}
                    
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil
        return nil
    }
   
}
