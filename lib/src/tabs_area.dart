import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tabbed_view/src/flow_layout.dart';
import 'package:tabbed_view/src/internal/tabbed_view_provider.dart';
import 'package:tabbed_view/src/tab_button.dart';
import 'package:tabbed_view/src/tab_button_widget.dart';
import 'package:tabbed_view/src/tab_data.dart';
import 'package:tabbed_view/src/tab_status.dart';
import 'package:tabbed_view/src/tab_widget.dart';
import 'package:tabbed_view/src/tabbed_view_controller.dart';
import 'package:tabbed_view/src/tabbed_view_menu_item.dart';
import 'package:tabbed_view/src/tabs_area_layout.dart';
import 'package:tabbed_view/src/theme/tabbed_view_theme_data.dart';
import 'package:tabbed_view/src/theme/tabs_area_theme_data.dart';
import 'package:tabbed_view/src/theme/theme_widget.dart';

/// Widget for the tabs and buttons.
class TabsArea extends StatefulWidget {
  const TabsArea({required this.provider});

  final TabbedViewProvider provider;

  @override
  State<StatefulWidget> createState() => _TabsAreaState();
}

/// The [TabsArea] state.
class _TabsAreaState extends State<TabsArea> {
  int? _highlightedIndex;

  final HiddenTabs hiddenTabs = HiddenTabs();

  @override
  Widget build(BuildContext context) {
    TabbedViewController controller = widget.provider.controller;
    TabbedViewThemeData theme = TabbedViewTheme.of(context);
    TabsAreaThemeData tabsAreaTheme = theme.tabsArea;
    List<Widget> children = [];
    for (int index = 0; index < controller.tabs.length; index++) {
      TabStatus status = _getStatusFor(index);
      children.add(TabWidget(
          index: index,
          status: status,
          provider: widget.provider,
          updateHighlightedIndex: _updateHighlightedIndex));
    }
    Widget tabsAreaLayout = TabsAreaLayout(
        children: children,
        buttonsAreaBuilder: _buttonsAreaBuilder,
        theme: theme,
        hiddenTabs: hiddenTabs,
        selectedTabIndex: controller.selectedIndex);
    tabsAreaLayout = ClipRect(child: tabsAreaLayout);

    Decoration? decoration;
    if (tabsAreaTheme.color != null || tabsAreaTheme.border != null) {
      decoration = BoxDecoration(
          color: tabsAreaTheme.color, border: tabsAreaTheme.border);
    }
    return Container(child: tabsAreaLayout, decoration: decoration);
  }

  /// Area for buttons like the hidden tabs menu button.
  ///
  /// Even if there are no visible buttons, an empty container must be created.
  Widget _buttonsAreaBuilder(BuildContext context) {
    TabbedViewThemeData theme = TabbedViewTheme.of(context);
    TabsAreaThemeData tabsAreaTheme = theme.tabsArea;
    Widget buttonsArea;

    List<TabButton> buttons = [];
    if (widget.provider.tabsAreaButtonsBuilder != null) {
      buttons = widget.provider.tabsAreaButtonsBuilder!(
          context, widget.provider.controller.tabs.length);
    }

    if (hiddenTabs.hasHiddenTabs) {
      TabButton hiddenTabsMenuButton = TabButton(
          icon: tabsAreaTheme.menuIcon, menuBuilder: _hiddenTabsMenuBuilder);
      buttons.insert(0, hiddenTabsMenuButton);
    }

    if (buttons.isNotEmpty) {
      List<Widget> children = [];
      for (int i = 0; i < buttons.length; i++) {
        EdgeInsets? padding;
        if (i > 0 && tabsAreaTheme.buttonsGap > 0) {
          padding = EdgeInsets.only(left: tabsAreaTheme.buttonsGap);
        }
        TabButton tabButton = buttons[i];
        children.add(Container(
            child: TabButtonWidget(
                provider: widget.provider,
                button: tabButton,
                enabled: true,
                normalColor: tabsAreaTheme.normalButtonColor,
                hoverColor: tabsAreaTheme.hoverButtonColor,
                disabledColor: tabsAreaTheme.disabledButtonColor,
                normalBackground: tabsAreaTheme.normalButtonBackground,
                hoverBackground: tabsAreaTheme.hoverButtonBackground,
                disabledBackground: tabsAreaTheme.disabledButtonBackground,
                iconSize: tabButton.iconSize != null
                    ? tabButton.iconSize!
                    : tabsAreaTheme.buttonIconSize,
                themePadding: tabsAreaTheme.buttonPadding),
            padding: padding));
      }

      buttonsArea = FlowLayout(children: children, firstChildFlex: false);

      EdgeInsetsGeometry? margin;
      if (tabsAreaTheme.buttonsOffset > 0) {
        margin = EdgeInsets.only(left: tabsAreaTheme.buttonsOffset);
      }
      if (tabsAreaTheme.buttonsAreaDecoration != null ||
          tabsAreaTheme.buttonsAreaPadding != null ||
          margin != null) {
        buttonsArea = Container(
            child: buttonsArea,
            decoration: tabsAreaTheme.buttonsAreaDecoration,
            padding: tabsAreaTheme.buttonsAreaPadding,
            margin: margin);
      }
    } else {
      buttonsArea = SizedBox(width: 0);
    }
    return buttonsArea;
  }

  /// Builder for hidden tabs menu.
  List<TabbedViewMenuItem> _hiddenTabsMenuBuilder(BuildContext context) {
    List<TabbedViewMenuItem> list = [];
    hiddenTabs.indexes.sort();
    for (int index in hiddenTabs.indexes) {
      TabData tab = widget.provider.controller.tabs[index];
      list.add(TabbedViewMenuItem(
          text: tab.text,
          onSelection: () => widget.provider.controller.selectedIndex = index));
    }
    return list;
  }

  /// Gets the status of the tab for a given index.
  TabStatus _getStatusFor(int tabIndex) {
    TabbedViewController controller = widget.provider.controller;
    if (controller.tabs.isEmpty || tabIndex >= controller.tabs.length) {
      throw Exception('Invalid tab index: $tabIndex');
    }

    if (controller.selectedIndex != null &&
        controller.selectedIndex == tabIndex) {
      return TabStatus.selected;
    } else if (_highlightedIndex != null && _highlightedIndex == tabIndex) {
      return TabStatus.highlighted;
    }
    return TabStatus.normal;
  }

  void _updateHighlightedIndex(int? tabIndex) {
    if (_highlightedIndex != tabIndex) {
      setState(() {
        _highlightedIndex = tabIndex;
      });
    }
  }
}
