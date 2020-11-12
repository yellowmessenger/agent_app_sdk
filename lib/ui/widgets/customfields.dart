import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/core/models/ticket_settings.dart';
import 'package:support_agent/core/services/common.dart';
import 'package:support_agent/core/viewmodels/chat_model.dart';
import 'package:support_agent/ui/shared/color.dart';

class CustomTags {
  String name;
  bool selected;

  CustomTags(this.name, this.selected);

  @override
  String toString() {
    return '{ ${this.name}, ${this.selected} }';
  }
}

class TagsCustomFieldWidget extends StatefulWidget {
  final Field value;
  final ChatModel model;
  final String fieldKey;

  const TagsCustomFieldWidget(this.value, this.model, this.fieldKey);

  @override
  _TagsCustomFieldWidgetState createState() => _TagsCustomFieldWidgetState();
}

class _TagsCustomFieldWidgetState extends State<TagsCustomFieldWidget> {
  bool showSuggestion = false;
  List<CustomTags> selectedTags = List<CustomTags>();
  List<dynamic> userSelectedTags = List<dynamic>();

  @override
  void initState() {
    super.initState();
    if (widget.model.currentTicket.customFieldsValues.fields[widget.fieldKey] !=
        null)
      userSelectedTags =
          widget.model.currentTicket.customFieldsValues.fields[widget.fieldKey];
    for (var item in widget.value.tags) {
      if (userSelectedTags != null)
        selectedTags.add(CustomTags(item, userSelectedTags.contains(item)));
      else
        selectedTags.add(CustomTags(item, false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(color: Colors.grey)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Wrap(
                  children: selectedTags
                      .map((f) => Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: f.selected
                              ? Chip(
                                  padding: const EdgeInsets.all(6),
                                  backgroundColor: AccentBlue.withOpacity(0.2),
                                  onDeleted: () {
                                    // widget.model.addTags(f.name);
                                    setState(() {
                                      selectedTags.forEach((element) {
                                        if (element.name == f.name) {
                                          element.selected = !element.selected;
                                          userSelectedTags.remove(element.name);
                                        }
                                        widget.model.updateCustomFields(
                                            widget.fieldKey, userSelectedTags);
                                        // : element.selected = false;
                                      });
                                    });
                                  },
                                  deleteIconColor: AccentBlue,
                                  labelPadding: EdgeInsets.all(1),
                                  labelStyle: GoogleFonts.roboto(
                                      fontSize: 12, color: AccentBlue),
                                  label: Text(capitalize(f.name)))
                              : SizedBox.shrink()))
                      .toList(),
                ),
              ),
              IconButton(
                icon: Icon(
                    showSuggestion
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    size: 30,
                    color: Colors.black.withOpacity(0.4)),
                onPressed: () {
                  setState(() {
                    showSuggestion = !showSuggestion;
                  });
                  // model.setEditingNotes(true);
                },
              )
            ],
          ),
        ),
        if (showSuggestion)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: selectedTags
                  .map((f) => !f.selected
                      ? Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTags.forEach((element) {
                                    if (element.name == f.name) {
                                      element.selected = !element.selected;
                                      userSelectedTags.add(element.name);
                                    }
                                    // : element.selected = false;
                                  });

                                  widget.model.updateCustomFields(
                                      widget.fieldKey, userSelectedTags);
                                });

                                // model.setEditingNotes(true);
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                height: 16,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        capitalize(f.name),
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              color: Colors.grey,
                            )
                          ],
                        )
                      : SizedBox.shrink())
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class DateCustomFieldWidget extends StatefulWidget {
  final Field value;
  final ChatModel model;
  final String fieldKey;
  DateCustomFieldWidget(this.value, this.model, this.fieldKey);

  @override
  _DateCustomFieldWidgetState createState() => _DateCustomFieldWidgetState();
}

class _DateCustomFieldWidgetState extends State<DateCustomFieldWidget> {
  DateTime selectedDate = DateTime.now();
  var myFormat = DateFormat('d-MM-yyyy');

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
    // widget.model
    //     .updateCustomFields(widget.fieldKey, widget.textEditingController.text);
  }

  @override
  void initState() {
    super.initState();
    selectedDate = widget.model.currentTicket.customFieldsValues != null &&
            widget.model.currentTicket.customFieldsValues
                    .fields[widget.fieldKey] !=
                null
        ? DateTime.parse(widget
            .model.currentTicket.customFieldsValues.fields[widget.fieldKey])
        : DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: BasicDateField((value) {
              if (value != null)
                widget.model.updateCustomFields(widget.fieldKey, value);
            }, selectedDate),
          ),
        ],
      ),
    );
  }
}

class BasicDateField extends StatelessWidget {
  final format = DateFormat("dd-MM-yyyy");
  final Function callBack;
  final DateTime currentDate;

  BasicDateField(this.callBack, this.currentDate);
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      DateTimeField(
        initialValue: currentDate.toLocal(),
        format: format,
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
        },
        onChanged: (value) => callBack(value?.toUtc()?.toIso8601String()),
      ),
    ]);
  }
}

class CheckBoxCustomWidget extends StatefulWidget {
  final Field value;
  final ChatModel model;
  final String fieldKey;
  const CheckBoxCustomWidget(this.value, this.model, this.fieldKey);

  @override
  _CheckBoxCustomWidgetState createState() => _CheckBoxCustomWidgetState();
}

class _CheckBoxCustomWidgetState extends State<CheckBoxCustomWidget> {
  Map<String, bool> checkedValues = {};

  @override
  void initState() {
    super.initState();

    widget.value.checkboxes.forEach((e) {
      setState(() {
        checkedValues[e] = false;
      });
      if (widget
              .model.currentTicket.customFieldsValues.fields[widget.fieldKey] !=
          null)
        for (var item in widget
            .model.currentTicket.customFieldsValues.fields[widget.fieldKey]) {
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
                    widget.fieldKey,
                    getAllChecked(),
                  );
                },
                controlAffinity:
                    ListTileControlAffinity.leading, //  <-- leading Checkbox
              ))
          .toList(),
    );
  }
}
