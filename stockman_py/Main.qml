pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Window
import Qt.labs.qmlmodels

import Stocker

Window {
    id: root
    visible: true;
    visibility: Window.Maximized
    title: qsTr("Stock-Man");
    property int productAmount
    //color: "#e9e9e9";
    property color bgColor: "#0f1869"
    property color logoContainColor: Qt.darker(bgColor, 1.21)

    Item {
        id: container
        anchors.fill: parent;
        property real standardRadius: 30;
        property int viewIndex: 0;

        Rectangle {
            id: containerRect;
            anchors.fill: parent;
            color: "#e9e9e9"

            GridLayout {
                anchors.fill: parent;
                columns: 2;
                rows: 1;

                Rectangle {
                    id: sidebarRect
                    /*anchors {
                        left: parent.left;
                        top: parent.top;
                        bottom: parent.bottom;
                    }*/
                    Layout.fillHeight: true;
                    Layout.fillWidth: false;
                    width: 180;
                    topLeftRadius: 0;
                    bottomLeftRadius: 0;
                    topRightRadius: 3;
                    bottomRightRadius: 3;
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop {position: 0.0; color: root.bgColor}
                        GradientStop {position: 0.45; color: Qt.lighter(root.bgColor, 1.1)}
                        GradientStop {position: 0.5; color: Qt.lighter(root.bgColor, 1.2)}
                        GradientStop {position: 0.66; color: Qt.lighter(root.bgColor, 1.6)}
                        GradientStop {position: 0.75; color: Qt.lighter(root.bgColor, 1.3)}
                        GradientStop {position: 1.0; color: Qt.lighter(root.bgColor, 1.1)}
                    }

                    ColumnLayout {
                        id: sideTabs
                        anchors {
                            top: parent.top
                            right: parent.right
                            left: parent.left
                            bottom: parent.bottom
                            bottomMargin: root.height - 315
                        }
                        
                        Item {
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: logoContainer.height
                            Layout.fillWidth: true
                            Layout.margins: 8

                            Rectangle {
                                anchors.centerIn: parent
                                id:logoContainer
                                height: 100
                                width: parent.width
                                radius: 30
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 1.0; color: '#ec943c' }
                                    GradientStop { position: 0.8; color: '#cc7c22' }
                                    GradientStop { position: 0.0; color: '#2f29de' }
                                }
                            }

                            Rectangle {
                                id: logoRect
                                anchors.centerIn: logoContainer
                                width: logoContainer.width - 8
                                height: logoContainer.height - 8
                                radius: logoContainer.radius
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop {position: 0.0; color: root.logoContainColor}
                                    GradientStop {position: 0.45; color: Qt.lighter(root.logoContainColor, 1.22)}
                                    GradientStop {position: 0.5; color: Qt.lighter(root.logoContainColor, 1.31)}
                                    GradientStop {position: 0.66; color: Qt.lighter(root.logoContainColor, 1.4)}
                                    GradientStop {position: 0.75; color: Qt.lighter(root.logoContainColor, 1.29)}
                                    GradientStop {position: 1.0; color: Qt.lighter(root.logoContainColor, 1.15)}
                                }

                                RowLayout { 
                                    anchors.centerIn: parent
                                    spacing: 8;

                                    Text {
                                        id: logoIcon
                                        text: ""
                                        font.family: "Roboto Mono Nerd Font"
                                        font.pointSize: 22
                                        color: '#b3c3ff'
                                    }

                                    Text {
                                        id: logoText
                                        text: "Stockman"
                                        font.family: "Roboto Condensed Medium"
                                        font.underline: true
                                        font.pointSize: 18
                                        color: '#b5d1ff'
                                    }
                                }
                            }
                        }

                        TabRect {
                            id: dashButton
                            buttonIndex: 0
                            Component.onCompleted: {
                                container.viewIndex = 0;
                                usersButton.scale = 0.9;
                                financeButton.scale = 0.9;
                                itensButton.scale = 0.9;
                                dashButton.scale = 1;
                                usersButton.opacity = 0.95;
                                financeButton.opacity = 0.95;
                                itensButton.opacity = 0.95;
                                dashButton.opacity = 1;
                            }
                        }

                        TabRect {
                            id: itensButton
                            buttonIndex: 1
                        }

                        TabRect {
                            id: financeButton
                            buttonIndex: 2
                        }

                        TabRect {
                            id: usersButton
                            buttonIndex: 3
                        }
                    }
                }

                Rectangle {
                    id: mainRect
                    anchors {
                        right: parent.right;
                        top: parent.top;
                        bottom: parent.bottom;
                        left: sidebarRect.right;
                    }
                    Layout.fillHeight: true;
                    Layout.fillWidth: false
                    color: "transparent";

                    StackLayout {
                        id: switchableTabs
                        anchors.fill: parent
                        currentIndex: container.viewIndex

                        Rectangle {
                            anchors.fill: parent
                            color: containerRect.color
                        }

                        Rectangle {
                            id: secondTab
                            anchors.fill: parent
                            color: containerRect.color

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.topMargin: 40
                                anchors.bottomMargin: 25
                                spacing: 32

                                 RowLayout {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    height: 45

                                    Rectangle {
                                        id: searchContainer
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        color: "#d9d9d9"
                                        radius: 30
                                        border.width: 1
                                        border.color: '#b7484242'
                                        height: 45
                                        width: 520

                                            TextField {
                                                anchors.fill: parent
                                                anchors.leftMargin: 8
                                                anchors.rightMargin: 8
                                                anchors.topMargin: 2
                                                anchors.bottomMargin: 2
                                                background: Rectangle {
                                                    color: "transparent"
                                                    width: searchContainer.width
                                                    height: searchContainer.height
                                                    radius: searchContainer.radius
                                                    opacity: 0
                                                }
                                                placeholderText: "🔍"
                                                font.pointSize: 16
                                                color: "#202020"
                                                /*validator: {
                                                    RegularExpressionValidator {
                                                        regularExpression: /[0-9A-Z!?]+/
                                                    }
                                                }*/
                                                selectByMouse: true
                                                mouseSelectionMode: TextInput.SelectWords
                                            }
                                    }

                                    Button {
                                        id: searchSubmit
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "Pesquisar"
                                        implicitWidth: 84
                                        implicitHeight: 38

                                        contentItem: Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            font.pointSize: 12
                                            text: searchSubmit.text
                                            color: searchSubmit.down ? '#b7b7b7' : "f1f1f1"
                                        }
                                        
                                        background: Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            implicitWidth: 84
                                            implicitHeight: 38
                                            radius: searchContainer.radius
                                            color: searchSubmit.down ? '#091054' : searchSubmit.hovered ? "#ad5401" : "#f37906"
                                            border.width: 2
                                            border.color: "#101a72"
                                            
                                        }
                                        HoverHandler {
                                            enabled: parent.visible
                                            cursorShape: Qt.PointingHandCursor
                                        }

                                        
                                    }
                                }

                                Rectangle {
                                    id: tableBox
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    width: 720
                                    radius: 15
                                    border.width: 1
                                    border.color: '#f37906'
                                    color: "#e0e0e0"
                                    Layout.leftMargin: 60
                                    Layout.rightMargin: 60

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 0

                                        Rectangle {
                                            id: initCContainer
                                            Layout.fillWidth: true
                                            Layout.margins: 0
                                            height: 40
                                            color: "transparent"

                                            RowLayout {
                                                id: initColumn
                                                anchors.fill: parent
                                                Layout.leftMargin: 0
                                                Layout.rightMargin: 0
                                                spacing: 0
                                                uniformCellSizes: false
                                                implicitHeight: childrenRect.height

                                                Rectangle {
                                                    Layout.horizontalStretchFactor: 3
                                                    Layout.fillWidth: true
                                                    Layout.preferredWidth: 1
                                                    Layout.preferredHeight: 40
                                                    color: "#101a72"
                                                    border.width: 1
                                                    border.color: '#f37906'
                                                    topLeftRadius: tableBox.radius

                                                    Text {
                                                        anchors.centerIn: parent
                                                        color: "#f1f1f1"
                                                        font.family: "Roboto"
                                                        font.pointSize: 13
                                                        text: "Nome do Produto"
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.horizontalStretchFactor: 1
                                                    Layout.preferredWidth: 1
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 40
                                                    color: "#101a72"
                                                    border.width: 1
                                                    border.color: '#f37906'

                                                    Text {
                                                        anchors.centerIn: parent
                                                        color: "#f1f1f1"
                                                        font.family: "Roboto"
                                                        font.pointSize: 13
                                                        text: "Quantidade"
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.horizontalStretchFactor: 2
                                                    Layout.preferredWidth: 1
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 40
                                                    color: "#101a72"
                                                    border.width: 1
                                                    border.color: '#f37906'

                                                    Text {
                                                        anchors.centerIn: parent
                                                        color: "#f1f1f1"
                                                        font.family: "Roboto"
                                                        font.pointSize: 13
                                                        text: "Valor (Custo)"
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.horizontalStretchFactor: 2
                                                    Layout.preferredWidth: 1
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 40
                                                    color: "#101a72"
                                                    border.width: 1
                                                    border.color: '#f37906'

                                                    Text {
                                                        anchors.centerIn: parent
                                                        color: "#f1f1f1"
                                                        font.family: "Roboto"
                                                        font.pointSize: 13
                                                        text: "Valor (Venda)"
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.horizontalStretchFactor: 2
                                                    Layout.preferredWidth: 1
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 40
                                                    color: "#101a72"
                                                    border.width: 1
                                                    border.color: '#f37906'
                                                    topRightRadius: tableBox.radius

                                                    Text {
                                                        anchors.centerIn: parent
                                                        color: "#f1f1f1"
                                                        font.family: "Roboto"
                                                        font.pointSize: 13
                                                        text: "Valor (Lucro)"
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            anchors.top: initCContainer.bottom
                                            anchors.topMargin: -6
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            color: "transparent"
                                            Layout.margins: 0

                                            ListView {
                                                id: listView
                                                anchors.fill: parent
                                                orientation: ListView.Vertical

                                                StockModel {
                                                    id: stock_model
                                                }

                                                delegate: ProductLister {
                                                    id: delegate
                                                    sModel: stock_model
                                                }

                                                model: stock_model

                                                ScrollBar.vertical: ScrollBar { }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: containerRect.color
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: containerRect.color
                        }
                    }
                }
            }
        }
    }
}
