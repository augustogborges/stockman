pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window

Window {
    id: root
    visible: true
    visibility: Window.Maximized
    title: qsTr("Stockman")
    color: Parameters.mainBgColor

    Connections {
        target: loginLoader.item

        function onUserLogin() {
            mainLoader.active = true;
            mainLoader.item.loggedUser = arguments;
        }
    }

    Connections {
        target: mainLoader

        function onLoaded() {
            if (mainLoader.status === Loader.Ready) {
                loginLoader.active = false;
                Qt.callLater(() => {
                    mainLoader.visible = true;
                });
            }
        }
    }

    Item {
        id: container
        anchors.fill: parent
        property real standardRadius: 30
        property int viewIndex: 0

        Component {
            id: loginComponent

            Login {
                id: loginContainer
            }
        }

        Component {
            id: mainComponent

            MainPage {
                id: mainContainer
            }
        }

        Loader {
            id: loginLoader
            anchors.fill: parent
            active: true
            sourceComponent: loginComponent
            focus: true
            z: 1
        }

        Loader {
            id: mainLoader
            anchors.fill: parent
            active: false
            sourceComponent: mainComponent
            focus: true
            visible: false
        }
    }
}
