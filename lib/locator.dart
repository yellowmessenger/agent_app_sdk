import 'package:get_it/get_it.dart';
import 'package:support_agent/core/models/appstate.dart';
import 'package:support_agent/core/models/config.dart';
import 'package:support_agent/core/services/bot_service.dart';
import 'package:support_agent/core/services/custom_details.dart';
import 'package:support_agent/core/services/ticket_service.dart';
import 'package:support_agent/core/services/xmpp_creds.dart';
import 'package:support_agent/core/services/xmpp_service.dart';
import 'package:support_agent/core/viewmodels/agents_model.dart';
// import 'package:support_agent/core/viewmodels/archives_model.dart';
import 'package:support_agent/core/viewmodels/bot_selection_model.dart';
import 'package:support_agent/core/viewmodels/chat_model.dart';
import 'package:support_agent/core/viewmodels/home_model.dart';
import 'package:support_agent/core/viewmodels/landing_model.dart';
import 'package:support_agent/core/viewmodels/my_tickets_model.dart';
import 'package:support_agent/core/viewmodels/overview_model.dart';
import 'package:support_agent/core/viewmodels/settings_model.dart';
import 'package:support_agent/core/viewmodels/ticket_info_model.dart';
import 'package:support_agent/core/viewmodels/transfer_ticket_model.dart';

import 'core/models/notifications.dart';
import 'core/services/api.dart';
import 'core/services/authentication_service.dart';
import 'core/viewmodels/login_model.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => Api());
  locator.registerLazySingleton(() => BotService());
  locator.registerLazySingleton(() => XmppCredsService());
  locator.registerLazySingleton(() => XmppService());
  locator.registerLazySingleton(() => TicketService());
  locator.registerLazySingleton(() => CustomDataService());
  locator.registerLazySingleton(() => AppState());
  locator.registerLazySingleton(() => Configurations());
  // locator.registerLazySingleton(() => NotificationService());

  locator.registerFactory(() => LoginModel());
  locator.registerFactory(() => HomeModel());
  locator.registerFactory(() => BotSelectionModel());
  locator.registerFactory(() => LandingModel());
  // locator.registerFactory(() => ArchiveModel());
  locator.registerFactory(() => MyTicketsModel());
  locator.registerFactory(() => ChatModel());
  locator.registerFactory(() => TicketInfoModel());
  locator.registerFactory(() => SettingsModel());
  locator.registerFactory(() => OverViewModel());
  locator.registerFactory(() => Notifications());
  locator.registerFactory(() => AgentsModel());
  locator.registerFactory(() => TransferTicketModel());
}
