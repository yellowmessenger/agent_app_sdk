import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/core/models/all_bots.dart';
import 'package:support_agent/core/services/common.dart';
import 'package:support_agent/ui/shared/color.dart';

class CreateBotTile extends StatelessWidget {
  final BotMappings bot;
  final String botType;
  const CreateBotTile({Key key, this.bot, this.botType}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    
  if (bot.botIcon != null && bot.botIcon != '') {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(bot.botIcon),
      ),
      title: Text(bot.botName,
          style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: TextColorMedium)),
      subtitle: Text(bot.botDesc,
          style: GoogleFonts.roboto(fontSize: 12, color: TextColorLight)),
      trailing: Text(botType ?? "", style: GoogleFonts.roboto(fontSize: 12, color: TextColorLight)),
    );
  } else {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade900,
        child: Text(getInitials(bot.botName ?? "")),
      ),
      title: Text(bot.botName,
          style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: TextColorMedium)),
      subtitle: Text(bot.botDesc,
          style: GoogleFonts.roboto(fontSize: 12, color: TextColorLight)),
      trailing: Text(botType ?? "", style: GoogleFonts.roboto(fontSize: 12, color: TextColorLight)),
    );
  }
  }
}

