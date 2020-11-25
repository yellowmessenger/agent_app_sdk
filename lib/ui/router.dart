import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:support_agent/core/models/chat_args.dart';
import 'package:support_agent/ui/shared/color.dart';
import 'package:support_agent/ui/views/agents_view.dart';
import 'package:support_agent/ui/views/botselection.dart';
import 'package:support_agent/ui/views/chatpage.dart';
import 'package:support_agent/ui/views/home.dart';
import 'package:support_agent/ui/views/landing.dart';
import 'package:support_agent/ui/views/login.dart';
import 'package:support_agent/ui/views/redirect.dart';
import 'package:support_agent/ui/views/ticket_info.dart';
import 'package:support_agent/ui/views/transfer_ticket.dart';

const String initialRoute = "login";

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LandingPage());
      case 'home':
        return MaterialPageRoute(builder: (_) => HomePage());
      case 'login':
        return MaterialPageRoute(builder: (_) => LoginView());
      case 'bot_selection':
        return MaterialPageRoute(builder: (_) => BotSelectionPage());
      case 'agents':
        return MaterialPageRoute(builder: (_) => AgentsView());
      case 'transfer':
        return MaterialPageRoute(
            builder: (_) => TransferTicket(
                  ticket: settings.arguments,
                ));
      case 'chat_page':
        final ChatScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            builder: (_) => ChatPage(
                  ticket: args.ticket,
                  isArchive: args.isArchive,
                ));
      case 'ticket_info':
        return MaterialPageRoute(
            builder: (_) => TicketInfo(ticket: settings.arguments));
      case 'ticket/':
        return MaterialPageRoute(builder: (_) => Redirect());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset("images/error-404.png"),
                      Text(
                        'It seems you are lost.',
                        style: TextStyle(fontSize: 36),
                      ),
                      Text(
                        'Let\'s take you back.',
                        style: TextStyle(fontSize: 22),
                      ),
                      FlatButton.icon(
                        color: AccentBlue,
                        textColor: Colors.white,
                        onPressed: () => Navigator.canPop(_)
                            ? Navigator.pop(_)
                            : Navigator.pushReplacementNamed(_, '/'),
                        label: Text(
                          "Home",
                          style: TextStyle(fontSize: 18),
                        ),
                        icon: Icon(Icons.arrow_back),
                      )
                    ],
                  ),
                ));
    }
  }
}
