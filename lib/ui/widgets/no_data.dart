import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/ui/shared/color.dart';

class NoData extends StatelessWidget {
  const NoData({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    
                    children: <Widget>[
                      Image.asset("images/no-results.png"),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No results found',
                          style: GoogleFonts.roboto(
                          fontSize: 28, color: TextColorDark),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:20.0),
                        child: Text(
                          'Seems like the page you are looking for does not have any data at the moment. Try some other time.',
                          style: GoogleFonts.roboto(
                          fontSize: 14, color: TextColorLight),
                        ),
                      ),
                      // FlatButton.icon(
                      //   color: AccentBlue,
                      //   textColor: Colors.white,
                      //   onPressed: () => Navigator.canPop(_) ? Navigator.pop(_) : Navigator.pushReplacementNamed(_, '/'),
                      //   label: Text(
                      //     "Home",
                      //     style: TextStyle(fontSize: 18),
                      //   ),
                      //   icon: Icon(Icons.arrow_back),
                      // )
                    ],
                  );
  }
}