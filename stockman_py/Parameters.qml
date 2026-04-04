pragma Singleton

import QtQuick

QtObject {
    readonly property color mainBgColor: "#eeeeee" //"#121212"
    readonly property color shadeBgColor: Qt.tint(mainBgColor, Qt.lighter(Qt.rgba(mainHighlightBg.r, mainHighlightBg.g, mainHighlightBg.b, 0.05), 3.2)) //'#eaeff3' //"#202020"
    readonly property color mainHighlightBg: "#0f1869" //"#dc2332"
    readonly property color shadeHightlightBg: Qt.darker(mainHighlightBg, 1.21)
    readonly property color stdButtonBg: Qt.darker(mainHighlightBg, 1.15)
    readonly property color pressedButtonBg: Qt.darker(mainHighlightBg, 1.7)
    readonly property color hoveredButtonBg: Qt.lighter(mainHighlightBg, 1.3)
    readonly property color highlightFg: "#f37906" //"#eeeeee"
    readonly property int defaultRadius: 15
    readonly property string defaultFont: "Roboto Condensed Medium"
    readonly property string thinFont: "Roboto Condensed"
    readonly property string wideFont: "Roboto Regular"
    readonly property string altFont: "Iosevka Nerd Font"
    readonly property string iconFont: "Phosphor"
    readonly property string iconFontBold: "Phosphor-Bold"
}