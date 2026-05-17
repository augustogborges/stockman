import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    required property int buttonIndex

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
                anchors.centerIn: parent
                width: childrenRect.width
                spacing: 4

                Text {
                    id: buttonIcon
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.buttonSymbols[root.buttonIndex]
                    font.family: Parameters.iconFontBold
                    font.pixelSize: 22
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 10
                    color: "#ffffff"
                }

                Text {
                    id: buttonText
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.buttonNames[root.buttonIndex]
                    font.family: Parameters.defaultFont
                    font.styleName: "Medium"
                    //style: containerRect.viewIndex == root.buttonIndex ? Text.Outline : Text.Normal
                    //styleColor: '#404040'
                    font.pixelSize: 24
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 10
                    color: "#ffffff"
                }
            }
        }
    }
}
