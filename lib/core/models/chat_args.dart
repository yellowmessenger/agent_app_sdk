import 'package:support_agent/core/models/tickets.dart';

class ChatScreenArguments{
  final Ticket ticket;
  final bool isArchive;

  ChatScreenArguments(this.ticket, this.isArchive);
}