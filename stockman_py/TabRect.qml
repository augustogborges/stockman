import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    required property int buttonIndex
    property real targetWidth

    property list<string> buttonNames: ["Dashboard", "Inventário", "Usuários"]
    property list<string> buttonSymbols: ["", "", ""]

    property color backColor: "#0f1869"
    property color foreColor: "#ff7e00"

    Layout.preferredHeight: 24
    Layout.fillWidth: true
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    enabled: root.visible
    onClicked: {
        switch (buttonIndex) {
        case 0:
            containerRect.viewIndex = 0;
            usersButton.scale = 0.9;
            itensButton.scale = 0.9;
            dashButton.scale = 1;
            usersButton.opacity = 0.95;
            itensButton.opacity = 0.95;
            dashButton.opacity = 1;
            break;
        case 1:
            containerRect.viewIndex = 1;
            usersButton.scale = 0.9;
            itensButton.scale = 1;
            dashButton.scale = 0.9;
            usersButton.opacity = 0.95;
            itensButton.opacity = 1;
            dashButton.opacity = 0.95;
            break;
        case 2:
            containerRect.viewIndex = 2;
            usersButton.scale = 1.0;
            itensButton.scale = 0.9;
            dashButton.scale = 0.9;
            usersButton.opacity = 1.0;
            itensButton.opacity = 0.95;
            dashButton.opacity = 0.95;
            break;
        }
    }
    cursorShape: Qt.PointingHandCursor

    Rectangle {
        anchors.fill: parent
        Layout.fillHeight: true
        Layout.fillWidth: true
        color: "transparent"

        Rectangle {
            id: bgButton
            anchors.centerIn: parent
            width: sidebarRect.width * 4.5 / 5
            height: 50
            radius: 30
            scale: 0.9
            opacity: 0.95
            color: containerRect.viewIndex == root.buttonIndex ? root.foreColor : "transparent"

            Behavior on opacity {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.InOutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutCubic
                }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 4

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    id: buttonIcon
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    text: root.buttonSymbols[root.buttonIndex]
                    font.family: Parameters.iconFontBold
                    font.pixelSize: containerRect.globalScaleWidth / 41
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 14
                    color: "#ffffff"
                }

                Text {
                    id: buttonText
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    text: root.buttonNames[root.buttonIndex]
                    font.family: Parameters.defaultFont
                    font.styleName: "Medium"
                    //style: containerRect.viewIndex == root.buttonIndex ? Text.Outline : Text.Normal
                    //styleColor: '#404040'
                    font.pixelSize: containerRect.globalScaleWidth / 43
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 12
                    color: "#ffffff"
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
