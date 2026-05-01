pragma Singleton

import QtQuick

QtObject {
    readonly property color mainBgColor: "#fafafa" //"#121212"
    readonly property color shadeBgColor: Qt.tint(mainBgColor, Qt.lighter(Qt.rgba(mainHighlightBg.r, mainHighlightBg.g, mainHighlightBg.b, 0.05), 3.2)) //'#eaeff3' //"#202020"
    readonly property color dimmedBgColor: "#c0c0c0"
    readonly property color lightBorder: '#6e6e6e'
    readonly property color mainHighlightBg: "#0f1869" //"#dc2332"
    readonly property color shadeHighlightBg: Qt.darker(mainHighlightBg, 1.21)
    readonly property color stdButtonBg: Qt.darker(mainHighlightBg, 1.15)
    readonly property color pressedButtonBg: Qt.darker(mainHighlightBg, 1.7)
    readonly property color hoveredButtonBg: Qt.lighter(mainHighlightBg, 1.3)
    readonly property color highlightFg: "#f37906" //"#eeeeee"
    readonly property color shadeHighlightFg: '#bd4b00'
    readonly property color dimmedHighlightBg: '#454d5e'
    readonly property color cashGreen: '#009e2a'
    readonly property color cashCyan: '#38a36a'
    readonly property color lowCashRed: '#be3e3e'
    readonly property color lowCashPink: '#c23e6c'
    readonly property int defaultRadius: 15
    readonly property string defaultFont: "Roboto Condensed Medium"
    readonly property string thinFont: "Roboto Condensed"
    readonly property string wideFont: "Roboto Regular"
    readonly property string altFont: "Iosevka Nerd Font"
    readonly property string iconFont: "Phosphor"
    readonly property string iconFontBold: "Phosphor-Bold"
    readonly property string iconFontFilled: "Phosphor-Fill"

    readonly property var whiteButtonGradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { color: "#dddddd"; position: 0.0}
        GradientStop { color: "#e5e5e5"; position: 0.45}
    }

    readonly property var whiteBgGradient: Gradient {
        GradientStop {color: "#efefef"; position: 0.0}
        GradientStop {color: "#f0f0f0"; position: 0.5}
        GradientStop {color: mainBgColor; position: 0.65}
    }

    readonly property var subTableGradient: Gradient {
        GradientStop {color: "#f2f2f2"; position: 0.0}
        GradientStop {color: "#fcfcfc"; position: 0.5}
        GradientStop {color: "#fefefe"; position: 0.65}
    }

    readonly property var subItemGradient: Gradient {
        GradientStop {color: "#f2f2f2"; position: 0.0}
        GradientStop {color: "#fefefe"; position: 0.4}
    }
}