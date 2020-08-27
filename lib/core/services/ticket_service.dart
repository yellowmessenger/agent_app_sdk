import 'package:support_agent/core/models/tickets.dart';

class TicketService {
  String _currentTicketId;
  List<Ticket> _tickets = List<Ticket>();
  List<Ticket> get tickets => _tickets;
  String get currentTicketId => _currentTicketId;



  setCurrentTicketId(String ticketId) {
    if (ticketId == "") {
      _currentTicketId = null;
    } else {
      _currentTicketId = ticketId;
    }
  }

  setTickets(List<Ticket> tickets) {
    _tickets = tickets;
  }

  Ticket searchById(String ticketId){
    if(_tickets == null) return null;
    for (var item in _tickets) {
      if(item.ticketId == ticketId){
        return item;
      }
    }
  }
}
