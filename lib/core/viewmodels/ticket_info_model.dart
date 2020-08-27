import 'dart:convert';

import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/bot_user_profile.dart';
import 'package:support_agent/core/models/ticket_settings.dart';
import 'package:support_agent/core/models/tickets.dart';
import 'package:support_agent/core/services/api.dart';
import 'package:support_agent/core/services/authentication_service.dart';
import 'package:support_agent/core/services/bot_service.dart';
import 'package:support_agent/core/services/custom_details.dart';
import '../../locator.dart';
import 'base_model.dart';

class TicketInfoModel extends BaseModel {
  Api _api = locator<Api>();

  AuthenticationService _authService =
      locator<AuthenticationService>(); //For Auth Key
  BotService _botService = locator<BotService>(); // For current Bot
  CustomDataService _customDataService =
      locator<CustomDataService>(); // For CustomData
  Ticket _ticket;
  Ticket get currentTicket => _ticket;
  bool _botStatus = false;
  bool get botStatus => _botStatus;
  BotUser _botUser;
  BotUser get botUserProfile => _botUser;
  List<String> _ticketTags;
  List<String> get ticketTags => _ticketTags;
  bool _editingNotes = false;
  bool get editingNotes => _editingNotes;
  CustomFields customFields;
  Map<String, dynamic> customFieldValues = Map<String, dynamic>();

  get customFieldsValues => customFieldValues;

  Future initTicketInfo(Ticket ticket) async {
    _ticket = ticket;
    setState(ViewState.Busy);
    String authKey = _authService.currentUserData.accessToken;
    String botId = _botService.defaultBot.userName;
    String uid = ticket.uid;
    String source = ticket.source;

    var botStatusResponse = await _api.getBotStatus(authKey, botId, uid);
    _botStatus = botStatusResponse.data.paused != null
        ? botStatusResponse.data.paused ? false : true
        : true;
    var botUserProfile =
        await _api.getTicketUserProfile(authKey, botId, uid, source);
    if (botUserProfile != null) _botUser = botUserProfile;

    var allTags = await _api.getTags(authKey, botId);
    if (allTags != null) _ticketTags = allTags;
    getSettings();
    await _customDataService.getCustomData();

    setState(ViewState.Idle);
    return true;
  }

  addTags(String val) {
    // print(val);
  }
  removeTags(String val) {
    // print(val);
  }

  changeBotStatus() {}

  setEditingNotes(bool editing) {
    setState(ViewState.Busy);
    _editingNotes = editing;
    setState(ViewState.Idle);
  }

  getSettings() async {
    var settings = await _api.getSettings(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName);
    setState(ViewState.Busy);
    //getting custom fields names
    customFields = settings.data.settings.customFields;
    // if custom fields are present
    if (customFields != null) {
      // checking for locally stored values
      if (_customDataService.customData != null &&
          _customDataService.customData
              .containsKey(_botService.defaultBot.userName) &&
          _customDataService.customData[_botService.defaultBot.userName]
              .containsKey(_ticket.ticketId)) {
        customFieldValues = _customDataService
            .customData[_botService.defaultBot.userName][_ticket.ticketId];
      }
      // Setting values form current ticket details
      else if (currentTicket.customFieldsValues != null) {
        customFields.fields.forEach((key, value) {
          customFieldValues[key] = currentTicket.customFieldsValues.fields[key];
        });
      }
    }
    setState(ViewState.Idle);
  }

  updateNotes(String note) async {
    var update = await _api.updateTicketNote(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName,
        currentTicket.ticketId,
        note);
  }

  updateCustomFields(String fieldKey, dynamic fieldValue,
      {bool checkbox}) async {
    setState(ViewState.Busy);
    customFieldValues[fieldKey] = fieldValue;
    _customDataService.setDefault({
      _botService.defaultBot.userName: {
        currentTicket.ticketId: customFieldValues
      }
    });
    setState(ViewState.Idle);
  }

  sendCustomData() async {
    var update = await _api.updateCustomFields(
        _authService.currentUserData.accessToken,
        _botService.defaultBot.userName,
        currentTicket.ticketId,
        customFieldValues
          ..removeWhere(
              (dynamic key, dynamic value) => key == null || value == null));
    return update;
  }
}
