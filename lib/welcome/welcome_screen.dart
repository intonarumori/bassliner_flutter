import 'package:bassliner/data/pattern_editor.dart';
import 'package:bassliner/views/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WelcomeScreen extends StatefulWidget {
  final Function() onToggleTheme;

  const WelcomeScreen({super.key, required this.onToggleTheme});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _detailsVisible = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<PatternEditor>(
      builder: (context, patternEditor, child) => StreamBuilder(
          stream: patternEditor.devices.stream,
          builder: (context, snapshot) {
            final devices = snapshot.data ?? [];
            return Container(
              color: Theme.of(context).basslinerTheme.backgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: TextButton(
                        onPressed: widget.onToggleTheme,
                        onLongPress: () => patternEditor.forceConnetion(),
                        child: SvgPicture.asset(
                          'assets/BasslineLogoOutline.svg',
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).basslinerTheme.whiteKeyColor, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _detailsVisible = !_detailsVisible;
                      }),
                      child: Text('Connect TD-3 to get started.',
                          style: TextStyle(color: Theme.of(context).basslinerTheme.whiteKeyColor)),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: _detailsVisible
                          ? Container(
                              width: 250,
                              padding: const EdgeInsets.fromLTRB(10, 15, 10, 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).basslinerTheme.disabledWhiteKeyColor,
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                      devices.isEmpty
                                          ? 'No device is connected.'
                                          : 'Connected devices',
                                      style: TextStyle(
                                          color: Theme.of(context).basslinerTheme.whiteKeyColor)),
                                  if (devices.isNotEmpty) ...[
                                    const SizedBox(height: 5),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) =>
                                          _ListItem(text: devices[index].name),
                                      separatorBuilder: (context, index) => Container(
                                        height: 1,
                                        color:
                                            Theme.of(context).basslinerTheme.disabledBlackKeyColor,
                                      ),
                                      itemCount: devices.length,
                                    ),
                                  ],
                                  TextButton(
                                    onPressed: () => setState(() {
                                      launchUrlString(
                                        'https://drummachinefunk.com/files/Bassliner_User_Manual.pdf',
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }),
                                    child: Text(
                                      'Open the manual for instructions.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context).basslinerTheme.selectionColor),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(height: 0),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 15,
                      child: SvgPicture.asset(
                        'assets/DmfLogo.svg',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).basslinerTheme.whiteKeyColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String text;
  const _ListItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Center(
          child:
              Text(text, style: TextStyle(color: Theme.of(context).basslinerTheme.whiteKeyColor))),
    );
  }
}
