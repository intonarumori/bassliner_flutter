import 'package:bassliner/browser/browser_viewmodels.dart';
import 'package:bassliner/browser/device_pattern_browser.dart';
import 'package:bassliner/browser/mobile_file_browser.dart';
import 'package:bassliner/views/bordered_button.dart';
import 'package:bassliner/views/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrowserRoute extends CupertinoPageRoute {
  BrowserRoute({
    required Function() onToggleTheme,
    required BrowseScreenViewModel viewModel,
  }) : super(
          fullscreenDialog: true,
          builder: (BuildContext context) => Scaffold(
            resizeToAvoidBottomInset: false,
            body: BrowserScreen(
              onToggleTheme: onToggleTheme,
              viewModel: viewModel,
            ),
          ),
        );
}

// MARK: -

enum BrowserScreenTab { device, mobile }

class BrowserScreen extends StatefulWidget {
  final BrowseScreenViewModel viewModel;
  final Function() onToggleTheme;

  const BrowserScreen({super.key, required this.onToggleTheme, required this.viewModel});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  BrowserScreenTab _tab = BrowserScreenTab.device;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() async {
    if (widget.viewModel.mobileBrowsingEnabled) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final value = prefs.getInt('browser_selected_tab') ?? 0;
      switch (value) {
        case 0:
          _selectTab(BrowserScreenTab.device);
          break;
        default:
          _selectTab(BrowserScreenTab.mobile);
          break;
      }
    }
  }

  void _selectTab(BrowserScreenTab tab) async {
    _tab = tab;
    setState(() {});

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('browser_selected_tab', _tab == BrowserScreenTab.device ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 30;
    final theme = Theme.of(context).basslinerTheme;

    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // TOP
          SizedBox(
            height: headerHeight,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    widget.viewModel.title ?? '',
                    style: TextStyle(color: theme.whiteKeyColor),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    BorderedButton(
                      text: 'Cancel',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          // Container(height: 1, color: theme.disabledWhiteKeyColor),
          // const SizedBox(height: 10),

          // CONTENT
          Expanded(
            child: Builder(builder: (context) {
              switch (_tab) {
                case BrowserScreenTab.mobile:
                  return MobileFileBrowser(viewModel: widget.viewModel);
                default:
                  return DevicePatternBrowser(
                    viewModel: widget.viewModel,
                    onSelect: (group, pattern) {
                      widget.viewModel.selectPattern(group, pattern);
                      Navigator.of(context).pop();
                    },
                  );
              }
            }),
          ),

          const SizedBox(height: 10),

          if (widget.viewModel.mobileBrowsingEnabled) ...[
            // TABBAR
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: ToggleButton(
                      text: 'TD-3',
                      icon: 'assets/TD3Icon.svg',
                      selected: _tab == BrowserScreenTab.device,
                      onToggle: (_) => _selectTab(BrowserScreenTab.device),
                      theme: ToggleButtonTheme(
                        backgroundColor: Colors.transparent,
                        textColor: theme.disabledWhiteKeyColor,
                        selectedBackgroundColor: theme.disabledBlackKeyColor,
                        selectedTextColor: theme.whiteKeyColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ToggleButton(
                      text: 'Mobile',
                      icon: 'assets/iPhoneIcon.svg',
                      selected: _tab == BrowserScreenTab.mobile,
                      onToggle: (_) => _selectTab(BrowserScreenTab.mobile),
                      theme: ToggleButtonTheme(
                        backgroundColor: Colors.transparent,
                        textColor: theme.whiteKeyColor,
                        selectedBackgroundColor: theme.disabledBlackKeyColor,
                        selectedTextColor: theme.whiteKeyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
