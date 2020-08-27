// import 'dart:async';

// import 'package:xmpp_rock/xmpp_rock.dart';



// class ChatProvider {

//   StreamSubscription<String> _chatStreamSubscription;
//   StreamController<String> _chatStatusController;

//   StreamSubscription<String> get subscription => _chatStreamSubscription;
//   StreamController<String> get chatStatusController => _chatStatusController;

//   ChatProvider(){
//     _chatStatusController = StreamController<String>();
    
//     _invokeNetworkStatusListen();
//   }

//   void _invokeNetworkStatusListen() async{


//     _chatStatusController.sink.add( await Connectivity().checkConnectivity());

//     _chatStreamSubscription = XmppRock.xmppStream.listen(_updateUI);

//   }

//   void disposeStreams(){

//     _subscription.cancel();
//     _chatStatusController.close();

//   }

// }