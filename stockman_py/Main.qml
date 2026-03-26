pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Window
import Qt.labs.qmlmodels

Window {
    id: root
    visible: true;
    visibility: Window.Maximized
    title: qsTr("Stock-Man");
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

                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: "#d5d5d5"
                                    radius: 30
                                    border.width: 1
                                    border.color: '#b7484242'
                                    height: 65
                                    width: 700
                                }

                                Rectangle {
                                    id: tableBox
                                    //anchors.horizontalCenter: parent.horizontalCenter
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 15
                                    border.width: 1.2
                                    border.color: '#b7484242'
                                    color: "#e0e0e0"
                                    Layout.leftMargin: 60
                                    Layout.rightMargin: 60

                                    /*TableView {
                                        anchors.fill: parent
                                        keyNavigationEnabled: false
                                        property real totalHorizontal: parent.width
                                        property var columnWidths: [totalHorizontal * 0.6, totalHorizontal * 0.1, totalHorizontal * 0.1, totalHorizontal * 0.1, totalHorizontal * 0.1]
                                        columnWidthProvider: function (column) { return columnWidths[column] }

                                        columnSpacing: 1
                                        rowSpacing: 1
                                        clip: true

                                        model: TableModel {
                                            TableModelColumn { display: "Nome do Produto" }
                                            TableModelColumn { display: "Quantidade" }
                                            TableModelColumn { display: "Preço de Custo" }
                                            TableModelColumn { display: "Preço de Venda" }
                                            TableModelColumn { display: "Lucro" }

                                            rows: [
                                               {
                                                    "Nome do Produto": "cat",
                                                    "Quantidade": "10",
                                                    "Preço de Custo": "2",
                                                    "Preço de Venda": "2",
                                                    "Lucro": "2"
                                               }
                                           ]
                                        }
                                        delegate: Rectangle {
                                            implicitHeight: 50
                                            border.width: 1

                                            Text {
                                                text: display
                                                color: "#000000"
                                                anchors.centerIn: parent
                                            }
                                        }

                                    }*/

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 0

                                        RowLayout {
                                            id: firstColumns
                                            anchors.top: parent.top
                                            anchors.topMargin: 1
                                            Layout.leftMargin: 1
                                            Layout.rightMargin: 1
                                            property var columnNames: [productObject.name, productObject.quantity, productObject.buyPrice, productObject.sellPrice, productObject.profit]
                                            spacing: 0
                                            uniformCellSizes: false

                                            Repeater {
                                                id: firstRowRepeat
                                                model: 5

                                                delegate: Rectangle {
                                                    required property int index
                                                    Layout.horizontalStretchFactor: index == 0 ? 6 : 1
                                                    Layout.preferredWidth: index == 0 ? undefined : childrenRect.width + 30
                                                    topLeftRadius: index == 0 ? 15 : 0
                                                    topRightRadius:  index == 4 ? 15 : 0
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 40
                                                    color: "#e0e0e0"
                                                    border.width: 1
                                                    border.color: '#b7484242'

                                                    Text {
                                                        anchors.centerIn: parent
                                                        color: "#000000"
                                                        font.family: "Roboto"
                                                        font.pointSize: 13
                                                        text: firstColumns.columnNames[parent.index]
                                                    }
                                                }
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
