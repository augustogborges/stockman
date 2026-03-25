import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    required property int buttonIndex

    property list<string> buttonNames: ["Dashboard", "Inventário", "Financeiro", "Usuários"];
    property list<string> buttonSymbols: ["", "", "", ""];

    property color backColor: "#0f1869";
    property color foreColor: "#ff7e00"

    Layout.fillHeight: true
    Layout.fillWidth: true
    hoverEnabled: true;
    acceptedButtons: Qt.LeftButton;
    onClicked: {
        switch(buttonIndex) {
            case 0:
                container.viewIndex = 0;
                usersButton.scale = 0.9;
                financeButton.scale = 0.9;
                itensButton.scale = 0.9;
                dashButton.scale = 1;
                usersButton.opacity = 0.95;
                financeButton.opacity = 0.95;
                itensButton.opacity = 0.95;
                dashButton.opacity = 1;
                break;
            case 1:
                container.viewIndex = 1;
                usersButton.scale = 0.9;
                financeButton.scale = 0.9;
                itensButton.scale = 1;
                dashButton.scale = 0.9;
                usersButton.opacity = 0.95;
                financeButton.opacity = 0.95;
                itensButton.opacity = 1;
                dashButton.opacity = 0.95;
                break;
            case 2:
                container.viewIndex = 2;
                usersButton.scale = 0.9;
                financeButton.scale = 1;
                itensButton.scale = 0.9;
                dashButton.scale = 0.9;
                usersButton.opacity = 0.9;
                financeButton.opacity = 1;
                itensButton.opacity = 0.95;
                dashButton.opacity = 0.95;
                break;
            case 3:
                container.viewIndex = 3;
                usersButton.scale = 1;
                financeButton.scale = 0.9;
                itensButton.scale = 0.9;
                dashButton.scale = 0.9;
                usersButton.opacity = 1;
                financeButton.opacity = 0.95;
                itensButton.opacity = 0.95;
                dashButton.opacity = 0.95;
                break;
        }
    }
    cursorShape: Qt.PointingHandCursor;

    Rectangle {
        anchors.fill: parent
        Layout.fillHeight: true
        Layout.fillWidth: true
        color: "transparent"
        
        Rectangle {
            id: bgButton
            anchors.centerIn: parent;
            width: sidebarRect.width * 4.5 / 5
            height: 50
            radius: 30
            scale: 1 //0.9
            opacity:1 //0.95
            color: container.viewIndex == root.buttonIndex ? root.foreColor : "transparent"

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutCubic
                }
            }

            RowLayout {
                anchors.centerIn: parent;
                width: childrenRect.width
                spacing: 4;

                Text {
                    id: buttonIcon
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.buttonSymbols[root.buttonIndex]
                    font.family: "Phosphor-Bold"
                    style: container.viewIndex == root.buttonIndex ? Text.Outline : Text.Normal
                    styleColor: '#6c272727'
                    font.pointSize: 15
                    color: "#ffffff"
                }

                Text {
                    id:buttonText
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.buttonNames[root.buttonIndex]
                    font.family: "Roboto Condensed Medium"
                    style: container.viewIndex == root.buttonIndex ? Text.Outline : Text.Normal
                    styleColor: '#6c272727'
                    font.pointSize: 15
                    color: "#ffffff"
                }
            }
        }
    }
}