import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/core/enums/viewstate.dart';
import 'package:support_agent/core/models/ticket_settings.dart';
import 'package:support_agent/core/models/tickets.dart';
import 'package:support_agent/core/services/common.dart';
import 'package:support_agent/core/viewmodels/ticket_info_model.dart';
import 'package:support_agent/ui/shared/color.dart';

import 'base_view.dart';

class TicketInfo extends StatelessWidget {
  final Ticket ticket;
  const TicketInfo({Key key, this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<TicketInfoModel>(
        onModelReady: (model) async => await model.initTicketInfo(ticket),
        builder: (context, model, child) => Container(
              child: Scaffold(
                  appBar: AppBar(
                    title: Text("Ticket: ${model.currentTicket.ticketId}"),
                    centerTitle: false,
                  ),
                  body: model.state == ViewState.Busy
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Card(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SectionHeader("Overview"),
                                          if (model.botUserProfile.data
                                                  .profileData !=
                                              null)
                                            InfoData(
                                              "Location",
                                              lableBody:
                                                  "${model.botUserProfile.data.profileData.city ?? "Not Available"} ${model.botUserProfile.data.profileData.region ?? ""} ",
                                            ),
                                          InfoData(
                                            "Bot Status",
                                            lableBody: model.botStatus
                                                ? "Running"
                                                : "Paused",
                                            action: CupertinoSwitch(
                                                value: model.botStatus,
                                                activeColor: AccentBlue,
                                                onChanged: (value) {}),
                                          ),
                                        ]),
                                  )),
                                  Card(
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SectionHeader("Ticket Details"),
                                                InfoData(
                                                  "Ticket No.",
                                                  lableBody: model
                                                      .currentTicket.ticketId,
                                                ),
                                                InfoData(
                                                  "Description",
                                                  lableBody:
                                                      model.currentTicket.issue,
                                                ),
                                                InfoData(
                                                  "Priority",
                                                  lableBody: capitalize(model
                                                          .currentTicket
                                                          .priority ??
                                                      ""),
                                                ),
                                                InfoData(
                                                  "Status",
                                                  lableBody: capitalize(model
                                                      .currentTicket.status),
                                                ),
                                                // tagsInfo(model),
                                                notesInfo(model),
                                              ]))),
                                  model.customFields != null
                                      ? Card(
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    ShowCustomFields(
                                                      model: model,
                                                    )
                                                  ])))
                                      : SizedBox.shrink(),
                                  Card(
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SectionHeader(
                                                    "Contact Details"),
                                                InfoData(
                                                  "Name",
                                                  lableBody: model.currentTicket
                                                      .contact.name,
                                                ),
                                                InfoData(
                                                  "Email",
                                                  lableBody: model.currentTicket
                                                      .contact.email,
                                                ),
                                                InfoData(
                                                  "Phone",
                                                  lableBody: model.currentTicket
                                                      .contact.phone,
                                                ),
                                              ]))),
                                  if (model.botUserProfile.data.profileData !=
                                      null)
                                    Card(
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SectionHeader(
                                                      "Device Details"),
                                                  model
                                                              .botUserProfile
                                                              .data
                                                              .profileData
                                                              .userAgent ==
                                                          null
                                                      ? Container()
                                                      : InfoData("Browser",
                                                          lableBody: model
                                                              .botUserProfile
                                                              .data
                                                              .profileData
                                                              .userAgent
                                                              .browser),
                                                  model
                                                              .botUserProfile
                                                              .data
                                                              .profileData
                                                              .userAgent ==
                                                          null
                                                      ? Container()
                                                      : InfoData("OS",
                                                          lableBody: model
                                                              .botUserProfile
                                                              .data
                                                              .profileData
                                                              .userAgent
                                                              .os),
                                                  model
                                                              .botUserProfile
                                                              .data
                                                              .profileData
                                                              .userAgent ==
                                                          null
                                                      ? Container()
                                                      : InfoData("Platform",
                                                          lableBody: model
                                                              .botUserProfile
                                                              .data
                                                              .profileData
                                                              .userAgent
                                                              .platform),
                                                  model
                                                              .botUserProfile
                                                              .data
                                                              .profileData
                                                              .userAgent ==
                                                          null
                                                      ? Container()
                                                      : InfoData("Device",
                                                          lableBody: model
                                                              .botUserProfile
                                                              .data
                                                              .profileData
                                                              .userAgent
                                                              .device),
                                                ]))),
                                  SizedBox(
                                    height: 40,
                                  )
                                ]),
                          ),
                        )),
            ));
  }

  InfoData tagsInfo(TicketInfoModel model) {
    return InfoData(
      "Tags",
      bodyWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DropdownButtonFormField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              hintText: 'Tags',
              labelText: 'Tags',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            isDense: true,
            items: model.ticketTags
                .map((tag) => DropdownMenuItem(
                    value: tag,
                    child: Text(
                      tag,
                    )))
                .toList(),
            onChanged: (String value) {
              model.addTags(value);
            },
          ),
          Wrap(
            children:
                // TextField(),
                model.currentTicket.tags
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Chip(
                              padding: const EdgeInsets.all(6),
                              backgroundColor: AccentBlue.withOpacity(0.2),
                              onDeleted: () {
                                model.addTags(f);
                              },
                              deleteIconColor: AccentBlue,
                              labelPadding: EdgeInsets.all(1),
                              labelStyle: GoogleFonts.roboto(
                                  fontSize: 12, color: AccentBlue),
                              label: Text(capitalize(f))),
                        ))
                    .toList(),
          ),
        ],
      ),
    );
  }

  NoteData notesInfo(TicketInfoModel model) {
    return NoteData(model: model);
  }
}

class ShowCustomFields extends StatelessWidget {
  final TicketInfoModel model;
  ShowCustomFields({this.model});

  @override
  Widget build(BuildContext context) {
    List<Widget> customFields = List<Widget>();
    model.customFields.fields.forEach((key, value) {
      customFields.add(
        InfoData(capitalize(value.name),
            bodyWidget: Column(
              children: <Widget>[
                value.type != "checkboxes"
                    ? TextFieldWidget(value, model, key)
                    : CheckBoxWidget(value, model, key),
              ],
            )),
      );
    });
    customFields.add(
      Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Divider(),
            Container(
              width: double.infinity,
              height: 60,
              child: FlatButton(
                  color: AccentBlue,
                  onPressed: () async {
                    var updateResponse = await model.sendCustomData();
                    if (updateResponse['success'] != true) {
                      print(updateResponse['message']);
                      final snackBar = SnackBar(
                          elevation: 4.0,
                          backgroundColor: Colors.white,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                color: Danger,
                                height: 2,
                              ),
                              ListTile(
                                  leading: Icon(
                                    Icons.info_outline,
                                    color: Danger,
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                        "Failed to update Custom Fields",
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20,
                                            color: TextColorDark)),
                                  ),
                                  subtitle: Text(updateResponse['message'],
                                      style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: TextColorDark))),
                            ],
                          ));
                      Scaffold.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: Text("Save Ticket Details",
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          fontSize: 20.0,
                          color: Colors.white))),
            )
          ]),
    );
    return ExpansionTile(
        title: SectionHeader("Ticket Extra Details"), children: customFields);
  }
}

class TextFieldWidget extends StatelessWidget {
  final Field value;
  final TicketInfoModel model;
  final String fieldKey;
  const TextFieldWidget(this.value, this.model, this.fieldKey);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: model.customFieldsValues != null
          ? model.customFieldsValues[fieldKey]
          : "",
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        hintText: value.description,
        labelText: value.description,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        hintStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.w400, fontSize: 16.0, color: TextColorLight),
      ),
      onFieldSubmitted: (text) => model.updateCustomFields(fieldKey, text),
    );
  }
}

class CheckBoxWidget extends StatefulWidget {
  final Field value;
  final TicketInfoModel model;
  final String fieldKey;
  const CheckBoxWidget(this.value, this.model, this.fieldKey);

  @override
  _CheckBoxWidgetState createState() => _CheckBoxWidgetState();
}

class _CheckBoxWidgetState extends State<CheckBoxWidget> {
  Map<String, bool> checkedValues = {};

  @override
  void initState() {
    super.initState();

    widget.value.checkboxes.forEach((e) {
      setState(() {
        checkedValues[e] = false;
      });
      if (widget.model.customFieldsValues[widget.fieldKey] != null)
        for (var item in widget.model.customFieldsValues[widget.fieldKey]) {
          checkedValues[item] = true;
        }
    });
  }

  List getAllChecked() {
    List toSend = [];
    checkedValues.forEach((key, value) {
      if (value) toSend.add(key);
    });
    return toSend;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.value.checkboxes
          .map((e) => CheckboxListTile(
                title: Text(e),
                value: checkedValues[e],
                onChanged: (newValue) {
                  setState(() {
                    checkedValues[e] = newValue;
                  });
                  widget.model.updateCustomFields(
                      widget.fieldKey, getAllChecked(),
                      checkbox: true);
                },
                controlAffinity:
                    ListTileControlAffinity.leading, //  <-- leading Checkbox
              ))
          .toList(),
    );
  }
}

class NoteData extends StatefulWidget {
  final TicketInfoModel model;
  const NoteData({this.model});
  @override
  _NoteDataState createState() => _NoteDataState(model: model);
}

class _NoteDataState extends State<NoteData> {
  final TicketInfoModel model;

  _NoteDataState({this.model});
  TextEditingController notesController = TextEditingController();
  TextEditingController notesController_closed = TextEditingController();
  @override
  void initState() {
    super.initState();
    notesController_closed.text = model.currentTicket.note;
  }

  @override
  Widget build(BuildContext context) {
    return InfoData(
      "Note",
      bodyWidget: !model.editingNotes
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 229, 143, 0.5),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextFormField(
                    controller: notesController_closed,
                    readOnly: true,
                    maxLines: 5,
                    minLines: 1,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      hintText: notesController_closed.text,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      filled: false,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      hintStyle: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          fontSize: 18.0,
                          color: TextColorLight),
                    ),
                  )),
                  IconButton(
                    icon: Icon(Icons.edit,
                        size: 18, color: Colors.black.withOpacity(0.4)),
                    onPressed: () {
                      model.setEditingNotes(true);
                    },
                  )
                ],
              ),
            )
          : Column(
              children: <Widget>[
                TextFormField(
                  controller: notesController,
                  maxLines: 5,
                  minLines: 2,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    hintText: model.currentTicket.note,
                    labelText: 'Add a note',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide:
                          BorderSide(color: Color.fromRGBO(255, 229, 143, 1)),
                    ),
                    filled: true,
                    fillColor: Color.fromRGBO(255, 229, 143, 0.5),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    hintStyle: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                        fontSize: 18.0,
                        color: TextColorLight),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    OutlineButton(
                        onPressed: () {
                          model.setEditingNotes(false);
                        },
                        borderSide: BorderSide(color: TextColorMedium),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: TextColorMedium),
                        )),
                    SizedBox(
                      width: 6,
                    ),
                    FlatButton(
                        onPressed: () {
                          print(notesController.text);
                          setState(() {
                            notesController_closed.text = notesController.text;
                          });

                          model.setEditingNotes(false);
                          model.updateNotes(notesController.text);
                        },
                        color: AccentBlue,
                        child: Text(
                          "Add",
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              fontSize: 14.0,
                              color: Colors.white),
                        )),
                  ],
                ),
              ],
            ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String s;

  const SectionHeader(this.s, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(s,
          style: GoogleFonts.roboto(fontSize: 20, color: TextColorMedium)),
    );
  }
}

class InfoData extends StatelessWidget {
  final String lableText, lableBody;
  final Widget action, bodyWidget;
  const InfoData(this.lableText,
      {this.lableBody, this.bodyWidget, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            padding: const EdgeInsets.only(right: 5),
            child: Text("$lableText: ",
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    color: TextColorMedium,
                    fontSize: 16)),
          ),
          if (bodyWidget != null)
            Container(
                width: MediaQuery.of(context).size.width * 0.55,
                child: bodyWidget),
          if (lableBody != null)
            Text("$lableBody ",
                style:
                    GoogleFonts.roboto(fontSize: 16, color: TextColorMedium)),
          Spacer(),
          Container(padding: EdgeInsets.only(left: 10), child: action)
        ],
      ),
    );
  }
}
