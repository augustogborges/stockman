pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Window
import QtQml

import Stocker

Window {
    id: root
    visible: true;
    visibility: Window.Maximized
    title: qsTr("Stockman");
    color: Parameters.mainBgColor
    property string search: ""
    property int productAmount
    property var sModel: stock_model

    Connections {
        target: root
        function onSearchChanged() {
            listView.model = stock_model.getEffectiveCount(root.search)
        }
    }

    Connections {
        target: newItemDialog
        function onNewAdded() {
            stock_model.reloadDB()
            listView.model = stock_model.getEffectiveCount(root.search)
        }
    }
    
    Connections {
        target: rmItemDialog
        function onItemRemoved() {
            root.sModel = ""
            stock_model.reloadDB()
            listView.model = stock_model.getEffectiveCount(root.search)
            root.sModel = stock_model
        }
    }
    
    Connections {
        target: editItemDialog
        function onCompletedEdit() {
            root.sModel = ""
            stock_model.reloadDB()
            listView.model = stock_model.getEffectiveCount(root.search)
            root.sModel = stock_model
        }
    }

    StockModel {
        id: stock_model
    }

    Item {
        id: container
        anchors.fill: parent;
        property real standardRadius: 30;
        property int viewIndex: 0;

        Rectangle {
            id: loginContainer
            anchors.fill: parent
            visible: true
            z: 1
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop {position: 0.0; color: Parameters.mainHighlightBg}
                GradientStop {position: 0.35; color: Qt.lighter(Parameters.mainHighlightBg, 1.2)}
                GradientStop {position: 0.4; color: Qt.lighter(Parameters.mainHighlightBg, 1.25)}
                GradientStop {position: 0.66; color: Qt.lighter(Parameters.mainHighlightBg, 1.15)}
                GradientStop {position: 0.75; color: Qt.lighter(Parameters.mainHighlightBg, 1.2)}
                GradientStop {position: 1.0; color: Qt.lighter(Parameters.mainHighlightBg, 1)}
            }

            ColumnLayout {
                anchors.fill: parent
 
                Rectangle {
                    id: logoLoginContainer
                    Layout.alignment: Qt.AlignHCenter
                    height: 96
                    width: 160
                    radius: 32
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Qt.lighter(Parameters.mainHighlightBg, 1.66) }
                        GradientStop { position: 0.6; color: Qt.darker(Parameters.highlightFg, 1.2) }
                        GradientStop { position: 1.0; color: Qt.lighter(Parameters.highlightFg, 1.3) }
                    }
                }

                Rectangle {
                    id: logologinRect
                    anchors.centerIn: logoLoginContainer
                    width: logoLoginContainer.width - 8
                    height: logoLoginContainer.height - 8
                    radius: logoLoginContainer.radius
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {position: 0.0; color: Parameters.shadeHightlightBg}
                        GradientStop {position: 0.45; color: Qt.lighter(Parameters.shadeHightlightBg, 1.22)}
                        GradientStop {position: 0.5; color: Qt.lighter(Parameters.shadeHightlightBg, 1.31)}
                        GradientStop {position: 0.66; color: Qt.lighter(Parameters.shadeHightlightBg, 1.4)}
                        GradientStop {position: 0.75; color: Qt.lighter(Parameters.shadeHightlightBg, 1.29)}
                        GradientStop {position: 1.0; color: Qt.lighter(Parameters.shadeHightlightBg, 1.15)}
                    }

                    RowLayout { 
                        anchors.centerIn: parent
                        spacing: 4;

                        Text {
                            id: logoLoginIcon
                            Layout.alignment: Qt.AlignVCenter
                            text: ""
                            font.family: Parameters.iconFontBold
                            font.pointSize: 22
                            color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                        }

                        Text {
                            id: logoLoginText
                            Layout.alignment: Qt.AlignVCenter
                            text: "Stockman"
                            font.family: Parameters.defaultFont
                            font.underline: false
                            font.pointSize: 18
                            color: Qt.lighter(Parameters.mainHighlightBg, 4.2)
                        }
                    }
                }

                Rectangle {
                }
            }
            
        }

        Rectangle {
            id: containerRect;
            anchors.fill: parent;
            color: Parameters.mainBgColor

            GridLayout {
                anchors.fill: parent;
                columns: 2;
                rows: 1;

                Rectangle {
                    id: sidebarRect
                    Layout.fillHeight: true;
                    Layout.fillWidth: false;
                    width: 180;
                    topLeftRadius: 0;
                    bottomLeftRadius: 0;
                    topRightRadius: 3;
                    bottomRightRadius: 3;
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop {position: 0.0; color: Parameters.mainHighlightBg}
                        GradientStop {position: 0.45; color: Qt.lighter(Parameters.mainHighlightBg, 1.1)}
                        GradientStop {position: 0.5; color: Qt.lighter(Parameters.mainHighlightBg, 1.2)}
                        GradientStop {position: 0.66; color: Qt.lighter(Parameters.mainHighlightBg, 1.6)}
                        GradientStop {position: 0.75; color: Qt.lighter(Parameters.mainHighlightBg, 1.3)}
                        GradientStop {position: 1.0; color: Qt.lighter(Parameters.mainHighlightBg, 1.1)}
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
                            Layout.alignment: Qt.AlignHCenter
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
                                    GradientStop { position: 0.0; color: Qt.lighter(Parameters.mainHighlightBg, 1.66) }
                                    GradientStop { position: 0.6; color: Qt.darker(Parameters.highlightFg, 1.2) }
                                    GradientStop { position: 1.0; color: Qt.lighter(Parameters.highlightFg, 1.3) }
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
                                    GradientStop {position: 0.0; color: Parameters.shadeHightlightBg}
                                    GradientStop {position: 0.45; color: Qt.lighter(Parameters.shadeHightlightBg, 1.22)}
                                    GradientStop {position: 0.5; color: Qt.lighter(Parameters.shadeHightlightBg, 1.31)}
                                    GradientStop {position: 0.66; color: Qt.lighter(Parameters.shadeHightlightBg, 1.4)}
                                    GradientStop {position: 0.75; color: Qt.lighter(Parameters.shadeHightlightBg, 1.29)}
                                    GradientStop {position: 1.0; color: Qt.lighter(Parameters.shadeHightlightBg, 1.15)}
                                }

                                RowLayout { 
                                    anchors.centerIn: parent
                                    spacing: 4;

                                    /*Text {
                                        id: logoIcon
                                        text: ""
                                        font.family: "Roboto Mono Nerd Font"
                                        font.pointSize: 22
                                        color: '#b3c3ff'
                                    }*/

                                    Text {
                                        id: logoIcon
                                        Layout.alignment: Qt.AlignVCenter
                                        text: ""
                                        font.family: Parameters.iconFontBold
                                        font.pointSize: 22
                                        color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                    }

                                    Text {
                                        id: logoText
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "Stockman"
                                        font.family: Parameters.defaultFont
                                        font.underline: false
                                        font.pointSize: 18
                                        color: Qt.lighter(Parameters.mainHighlightBg, 4.2)
                                    }
                                }
                            }
                        }

                        Item { height: 16 }

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
                            id: firstTab
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
                                spacing: 0

                                 RowLayout {
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Rectangle {
                                        radius: 30
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        border.width: 2
                                        border.color: Parameters.highlightFg
                                        width: 540
                                        height: 52
                                        color: "#101a72"

                                        Rectangle {
                                            id: searchContainer
                                            anchors.centerIn: parent
                                            color: Parameters.shadeBgColor
                                            radius: 30
                                            height: 32
                                            width: 520

                                            RowLayout {
                                                anchors.fill: parent
                                                spacing: 4

                                                TextField {
                                                    id: searchField
                                                    /* | Qt.AlignLeft
                                                    
                                                    
                                                    
                                                    Layout.topMargin: 4
                                                    Layout.bottomMargin: 0*/

                                                    Layout.fillWidth: true
                                                    Layout.alignment: Qt.AlignLeft
                                                    Layout.leftMargin: 2
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    //Layout.preferredHeight: 32

                                                    background: Rectangle {
                                                        color: "transparent"
                                                        //Layout.alignment: Qt.AlignVCenter
                                                        height: 32
                                                    }

                                                    placeholderText: "󰡦"
                                                    placeholderTextColor: Parameters.mainHighlightBg
                                                    verticalAlignment: Text.AlignVCenter
                                                    font.family: Parameters.altFont
                                                    font.styleName: "Medium Oblique"
                                                    font.pointSize: 17
                                                    color: "#202020"
                                                    selectByMouse: true
                                                    mouseSelectionMode: TextField.SelectWords
                                                    onAccepted: {
                                                        root.search = searchField.text
                                                    }

                                                    HoverHandler {
                                                        enabled: parent.visible
                                                        cursorShape: Qt.IBeamCursor
                                                    }
                                                }

                                                MouseArea {
                                                    Layout.rightMargin: 16
                                                    Layout.topMargin: 2
                                                    Layout.bottomMargin: 2
                                                    Layout.preferredWidth: 18
                                                    Layout.preferredHeight: childrenRect.height

                                                    visible: (root.search != "")
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    enabled: true
                                                    onClicked: {
                                                        root.search = ""
                                                    }

                                                    Text {
                                                        anchors.centerIn: parent
                                                        font.family: Parameters.altFont
                                                        font.styleName: "Medium Oblique"
                                                        font.pointSize: 18
                                                        text: ""
                                                        color: Parameters.mainHighlightBg
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Button {
                                        id: searchSubmit
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "Pesquisar"
                                        implicitWidth: 84
                                        implicitHeight: 30

                                        onClicked: {
                                            root.search = searchField.text
                                        }

                                        contentItem: Text {
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.family: Parameters.defaultFont
                                            font.pointSize: 12
                                            text: searchSubmit.text
                                            color: '#f0f0f0'
                                        }
                                        
                                        background: Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            implicitWidth: 84
                                            implicitHeight: 38
                                            radius: searchContainer.radius
                                            color: searchSubmit.down ? Parameters.pressedButtonBg : searchSubmit.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                            border.width: 1
                                            border.color: Parameters.highlightFg
                                            
                                        }

                                        HoverHandler {
                                            enabled: parent.visible
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }
                                }

                                Item { height: 25 }

                                RowLayout {
                                    Layout.fillWidth: true
                                    height: 30
                                    spacing: 8
                                    Layout.leftMargin: 66
                                    Layout.rightMargin: 66

                                    Text {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignBottom
                                        Layout.bottomMargin: 4
                                        text: {
                                            if (root.search != "") {
                                                return "Mostrando resultados para a pesquisa " + "\"" + root.search + "\"" + ":"
                                            } else {
                                                return "Mostrando todos os itens:"
                                            }
                                        }
                                        font.family: Parameters.thinFont
                                        font.pointSize: 13
                                        color: '#0d0b29'
                                    }

                                    Button {
                                        id: addItem
                                        Layout.alignment: Qt.AlignVCenter
                                        text: ""
                                        Layout.bottomMargin: 8
                                        
                                        implicitWidth: 40
                                        implicitHeight: 40
                                        onClicked: {
                                           newItemDialog.open()
                                        }

                                        contentItem: Text {
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pointSize: 20
                                            text: addItem.text
                                            font.family: Parameters.iconFont
                                            color: '#f0f0f0'
                                        }
                                        
                                        background: Rectangle {
                                            id: addItemRect
                                            implicitWidth: 40
                                            implicitHeight: 40
                                            radius: implicitWidth * 0.5
                                            color: addItem.down ? Parameters.pressedButtonBg : addItem.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                            border.width: 1
                                            border.color: Parameters.highlightFg
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
                                    border.color: Parameters.shadeHightlightBg
                                    color: Parameters.mainBgColor
                                    Layout.leftMargin: 60
                                    Layout.rightMargin: 60
                                    clip: true

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
                                                property int initCFontSize: 15

                                                Rectangle {
                                                    Layout.horizontalStretchFactor: 3
                                                    Layout.fillWidth: true
                                                    Layout.preferredWidth: 1
                                                    Layout.preferredHeight: 40
                                                    color: Parameters.mainHighlightBg
                                                    border.width: 1
                                                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        color: "#f1f1f1"
                                                        font.family: Parameters.defaultFont
                                                        font.pointSize: initColumn.initCFontSize
                                                        text: "Nome do Produto"
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.horizontalStretchFactor: 1
                                                    Layout.fillWidth: true
                                                    Layout.preferredWidth: 1
                                                    Layout.preferredHeight: 40
                                                    color: Parameters.mainHighlightBg
                                                    border.width: 1
                                                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                                                    Text {
                                                        anchors.centerIn: parent
                                                        color: "#f1f1f1"
                                                        font.family: Parameters.defaultFont
                                                        font.pointSize: initColumn.initCFontSize
                                                        text: "Quantidade"
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.horizontalStretchFactor: 2
                                                    Layout.preferredWidth: 1
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 40
                                                    color: Parameters.mainHighlightBg
                                                    border.width: 1
                                                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                                                    Text {
                                                        anchors.centerIn: parent
                                                        color: "#f1f1f1"
                                                        font.family: Parameters.defaultFont
                                                        font.pointSize: initColumn.initCFontSize
                                                        text: "Valor (Custo)"
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.horizontalStretchFactor: 2
                                                    Layout.preferredWidth: 1
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 40
                                                    color: Parameters.mainHighlightBg
                                                    border.width: 1
                                                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                                                    Text {
                                                        anchors.centerIn: parent
                                                        color: "#f1f1f1"
                                                        font.family: Parameters.defaultFont
                                                        font.pointSize: initColumn.initCFontSize
                                                        text: "Valor (Venda)"
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.horizontalStretchFactor: 2
                                                    Layout.preferredWidth: 1
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 40
                                                    color: Parameters.mainHighlightBg
                                                    border.width: 1
                                                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                                                    Text {
                                                        anchors.centerIn: parent
                                                        color: "#f1f1f1"
                                                        font.family: Parameters.defaultFont
                                                        font.pointSize: initColumn.initCFontSize
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

                                                delegate: ProductLister {
                                                    id: delegate
                                                    sModel: root.sModel
                                                    searchTerm: root.search
                                                }

                                                model: stock_model.getEffectiveCount(root.search)

                                                ScrollBar.vertical: ScrollBar { }
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }

                        Rectangle {
                            id: thirdTab
                            anchors.fill: parent
                            color: containerRect.color
                        }

                        Rectangle {
                            id: fourthTab
                            anchors.fill: parent
                            color: containerRect.color
                        }
                    }
                }
            }

            Rectangle {
                id: newItemDialog
                anchors.fill: parent
                visible: false
                opacity: 0

                signal newAdded()

                Shortcut {
                    enabled: newItemDialog.visible
                    sequence: "Escape"
                    onActivated: {
                        newItemDialog.close()
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 170
                    }
                }

                function open() {
                    newItemDialog.visible = true
                    Qt.callLater(() => {
                        newItemDialog.opacity = 1.0
                    })
                }

                function close() {
                    newItemDialog.opacity = 0
                    closeDialog.restart()
                }

                Timer {
                    id: closeDialog
                    running: false
                    repeat: false
                    interval: 200
                    onTriggered: {
                        newItemDialog.visible = false
                    }
                }

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#ee000000"}
                    GradientStop { position: 0.4; color: '#ee151517'}
                    GradientStop { position: 0.6; color: '#ee262527'}
                    GradientStop { position: 0.7; color: '#ee201f21'}
                    GradientStop { position: 1.0; color: "#ee000000"}
                }

                MultiEffect {
                    source: newItemDialog
                    blurEnabled: true
                    blur: 0.7
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: childrenRect.width + 35
                    height: childrenRect.height + 30
                    radius: 30
                    color: Parameters.pressedButtonBg

                    GridLayout {
                        columns: 4
                        rows: 3
                        anchors.centerIn: parent
                        width: root.width * 0.67
                        columnSpacing: 1
                        rowSpacing: 2

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.columnSpan: 4
                            height: 55
                            color: Parameters.mainHighlightBg
                            topLeftRadius: 15
                            topRightRadius: 15

                            Text {
                                anchors.centerIn: parent
                                text: "Adicionar Novo Item"
                                color: Parameters.mainBgColor
                                font.family: Parameters.defaultFont
                                font.pointSize: 18
                            }
                        }

                        Rectangle {
                            Layout.horizontalStretchFactor: 3
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 40
                            color: Parameters.shadeBgColor
                            border.width: 1
                            border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)
                            
                            TextField {
                                id: addFName
                                background: Rectangle {
                                    color: "transparent"
                                }
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                anchors.rightMargin: 4
                                anchors.topMargin: 2
                                anchors.bottomMargin: 2
                                color: "#000000"
                                font.family: Parameters.defaultFont
                                font.pointSize: 15
                                placeholderText: "Nome do Produto"
                                validator: RegularExpressionValidator {
                                    regularExpression: /(.|\s)*\S(.|\s)*/
                                }
                                focus: true
                            }
                        }

                        Rectangle {
                            Layout.horizontalStretchFactor: 1
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 40
                            color: Parameters.shadeBgColor
                            border.width: 1
                            border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                            TextField {
                                id: addFQuant
                                background: Rectangle {
                                    color: "transparent"
                                }
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                anchors.rightMargin: 4
                                anchors.topMargin: 2
                                anchors.bottomMargin: 2
                                color: "#000000"
                                font.family: Parameters.defaultFont
                                font.pointSize: 15
                                placeholderText: "Quantidade"
                                validator: RegularExpressionValidator {
                                    regularExpression: /(.|\s)*\S(.|\s)*/
                                }
                                focus: true
                            }
                        }

                        Rectangle {
                            Layout.horizontalStretchFactor: 2
                            Layout.preferredWidth: 1
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: Parameters.shadeBgColor
                            border.width: 1
                            border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                            TextField {
                                id: addFCost
                                background: Rectangle {
                                    color: "transparent"
                                }
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                anchors.rightMargin: 4
                                anchors.topMargin: 2
                                anchors.bottomMargin: 2
                                color: "#000000"
                                font.family: Parameters.defaultFont
                                font.pointSize: 15
                                placeholderText: "Valor (Custo)"
                                validator: RegularExpressionValidator {
                                    regularExpression: /(.|\s)*\S(.|\s)*/
                                }
                                focus: true
                            }
                        }

                        Rectangle {
                            Layout.horizontalStretchFactor: 2
                            Layout.preferredWidth: 1
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: Parameters.shadeBgColor
                            border.width: 1
                            border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                            TextField {
                                id: addFSell
                                background: Rectangle {
                                    color: "transparent"
                                }
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                anchors.rightMargin: 4
                                anchors.topMargin: 2
                                anchors.bottomMargin: 2
                                color: "#000000"
                                font.family: Parameters.defaultFont
                                font.pointSize: 15
                                placeholderText: "Valor (Venda)"
                                validator: RegularExpressionValidator {
                                    regularExpression: /(.|\s)*\S(.|\s)*/
                                }
                                focus: true
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            Layout.columnSpan: 4
                            color: Parameters.highlightFg
                            bottomRightRadius: 15
                            bottomLeftRadius: 15

                            RowLayout {
                                anchors {
                                    top: parent.top
                                    bottom: parent.bottom
                                    right: parent.right
                                    topMargin: 2
                                    bottomMargin: 2
                                    rightMargin: 6
                                }
                                layoutDirection: Qt.RightToLeft
                                spacing: 6
                                
                                Button {
                                    id: addSubmit
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: false
                                    text: "OK" //"Adicionar"
                                    implicitWidth: 74
                                    implicitHeight: 34
 
                                    onClicked: {
                                        if (addFName.acceptableInput && addFQuant.acceptableInput && addFCost.acceptableInput && addFSell.acceptableInput) {

                                            stock_model.append(addFName.text, Number(addFQuant.text), Number(addFCost.text), Number(addFSell.text))

                                            newItemDialog.close()

                                            newItemDialog.newAdded()
                                        }
                                    }
 
                                    contentItem: Text {
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.family: Parameters.defaultFont
                                        font.pointSize: 12
                                        text: addSubmit.text
                                        color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                    }
                                    
                                    background: Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        implicitWidth: 74
                                        implicitHeight: 34
                                        radius: searchContainer.radius
                                        color: addSubmit.down ? Parameters.pressedButtonBg : addSubmit.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                        border.width: 2
                                        border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                    }
 
                                    HoverHandler {
                                        enabled: parent.visible
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }

                                Button {
                                    id: addCancel
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: false
                                    text: "Cancelar"
                                    implicitWidth: 82
                                    implicitHeight: 34
 
                                    onClicked: {
                                        newItemDialog.close()
                                    }
 
                                    contentItem: Text {
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.family: Parameters.defaultFont
                                        font.pointSize: 12
                                        text: addCancel.text
                                        color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                    }
                                    
                                    background: Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        implicitWidth: 82
                                        implicitHeight: 34
                                        radius: searchContainer.radius
                                        color: addCancel.down ? Parameters.pressedButtonBg : addCancel.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                        border.width: 2
                                        border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                    }
 
                                    HoverHandler {
                                        enabled: parent.visible
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: editItemDialog
                anchors.fill: parent
                visible: false
                opacity: 0
                property int callRow

                signal completedEdit()

                Shortcut {
                    enabled: editItemDialog.visible
                    sequence: "Escape"
                    onActivated: {
                        editItemDialog.close()
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 170
                    }
                }

                function open() {
                    editItemDialog.visible = true
                    Qt.callLater(() => {
                        editItemDialog.opacity = 1.0
                    })
                }

                function close() {
                    editItemDialog.opacity = 0
                    closeEditDialog.restart()
                }

                Timer {
                    id: closeEditDialog
                    running: false
                    repeat: false
                    interval: 200
                    onTriggered: {
                        editItemDialog.visible = false
                    }
                }

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#ee000000"}
                    GradientStop { position: 0.4; color: '#ee151517'}
                    GradientStop { position: 0.6; color: '#ee262527'}
                    GradientStop { position: 0.7; color: '#ee201f21'}
                    GradientStop { position: 1.0; color: "#ee000000"}
                }

                MultiEffect {
                    source: editItemDialog
                    blurEnabled: true
                    blur: 0.7
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: childrenRect.width + 35
                    height: childrenRect.height + 30
                    radius: 30
                    color: Parameters.pressedButtonBg

                    GridLayout {
                        columns: 4
                        rows: 3
                        anchors.centerIn: parent
                        width: root.width * 0.67
                        columnSpacing: 1
                        rowSpacing: 2

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.columnSpan: 4
                            height: 55
                            color: Parameters.mainHighlightBg
                            topLeftRadius: 15
                            topRightRadius: 15

                            Text {
                                anchors.centerIn: parent
                                text: "Editar Item"
                                color: Parameters.mainBgColor
                                font.family: Parameters.defaultFont
                                font.pointSize: 18
                            }
                        }

                        Rectangle {
                            Layout.horizontalStretchFactor: 3
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 40
                            color: Parameters.shadeBgColor
                            border.width: 1
                            border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)
                            
                            Text {
                                id: editFName
                                anchors.centerIn: parent
                                color: '#e4595959'
                                font.family: Parameters.altFont
                                font.styleName: "Medium Oblique"
                                font.pointSize: 15
                                text: stock_model.get(editItemDialog.callRow, "").name
                            }
                        }

                        Rectangle {
                            Layout.horizontalStretchFactor: 1
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 40
                            color: Parameters.shadeBgColor
                            border.width: 1
                            border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                            TextInput {
                                id: editFQuant
                                anchors.centerIn: parent
                                color: "#000000"
                                font.family: Parameters.defaultFont
                                font.pointSize: 15
                                text: stock_model.get(editItemDialog.callRow, "").quantity
                                validator: RegularExpressionValidator {
                                    regularExpression: /(.|\s)*\S(.|\s)*/
                                }
                                focus: true

                                HoverHandler {
                                    enabled: parent.visible
                                    cursorShape: Qt.IBeamCursor
                                }
                            }
                        }

                        Rectangle {
                            Layout.horizontalStretchFactor: 2
                            Layout.preferredWidth: 1
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: Parameters.shadeBgColor
                            border.width: 1
                            border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                            TextInput {
                                id: editFCost
                                anchors.centerIn: parent
                                color: "#000000"
                                font.family: Parameters.defaultFont
                                font.pointSize: 15
                                text: stock_model.get(editItemDialog.callRow, "").buyPrice
                                validator: RegularExpressionValidator {
                                    regularExpression: /(.|\s)*\S(.|\s)*/
                                }
                                focus: false

                                HoverHandler {
                                    enabled: parent.visible
                                    cursorShape: Qt.IBeamCursor
                                }
                            }
                        }

                        Rectangle {
                            Layout.horizontalStretchFactor: 2
                            Layout.preferredWidth: 1
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: Parameters.shadeBgColor
                            border.width: 1
                            border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                            TextInput {
                                id: editFSell
                                anchors.centerIn: parent
                                color: "#000000"
                                font.family: Parameters.defaultFont
                                font.pointSize: 15
                                text: stock_model.get(editItemDialog.callRow, "").sellPrice
                                validator: RegularExpressionValidator {
                                    regularExpression: /(.|\s)*\S(.|\s)*/
                                }
                                focus: false

                                HoverHandler {
                                    enabled: parent.visible
                                    cursorShape: Qt.IBeamCursor
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            Layout.columnSpan: 4
                            color: Parameters.highlightFg
                            bottomRightRadius: 15
                            bottomLeftRadius: 15

                            RowLayout {
                                anchors {
                                    top: parent.top
                                    bottom: parent.bottom
                                    right: parent.right
                                    topMargin: 2
                                    bottomMargin: 2
                                    rightMargin: 6
                                }
                                layoutDirection: Qt.RightToLeft
                                spacing: 6
                                
                                Button {
                                    id: editSubmit
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: false
                                    text: "OK" //"Adicionar"
                                    implicitWidth: 74
                                    implicitHeight: 34
 
                                    onClicked: {
                                        if (editFQuant.acceptableInput && editFCost.acceptableInput && editFSell.acceptableInput) {

                                            stock_model.edit(editItemDialog.callRow, Number(editFQuant.displayText), Number(editFCost.displayText), Number(editFSell.displayText))

                                            editItemDialog.close()

                                            editItemDialog.completedEdit()
                                        }
                                    }
 
                                    contentItem: Text {
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.family: Parameters.defaultFont
                                        font.pointSize: 12
                                        text: editSubmit.text
                                        color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                    }
                                    
                                    background: Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        implicitWidth: 74
                                        implicitHeight: 34
                                        radius: searchContainer.radius
                                        color: editSubmit.down ? Parameters.pressedButtonBg : editSubmit.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                        border.width: 2
                                        border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                    }
 
                                    HoverHandler {
                                        enabled: parent.visible
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }

                                Button {
                                    id: editCancel
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: false
                                    text: "Cancelar"
                                    implicitWidth: 82
                                    implicitHeight: 34
 
                                    onClicked: {
                                        editItemDialog.close()
                                    }
 
                                    contentItem: Text {
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.family: Parameters.defaultFont
                                        font.pointSize: 12
                                        text: editCancel.text
                                        color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                    }
                                    
                                    background: Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        implicitWidth: 82
                                        implicitHeight: 34
                                        radius: searchContainer.radius
                                        color: editCancel.down ? Parameters.pressedButtonBg : editCancel.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                        border.width: 2
                                        border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                    }
 
                                    HoverHandler {
                                        enabled: parent.visible
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }
                        }
                    }
                }
            }

    Rectangle {
        id: rmItemDialog
        anchors.fill: parent
        visible: false
        opacity: 0
        property int callRm
 
        signal itemRemoved()
 
        Shortcut {
            enabled: rmItemDialog.visible
            sequence: "Escape"
            onActivated: {
                rmItemDialog.close()
            }
        }
 
        Behavior on opacity {
            NumberAnimation {
                duration: 170
            }
        }
 
        function open() {
            rmItemDialog.visible = true
            Qt.callLater(() => {
                rmItemDialog.opacity = 1.0
            })
        }
 
        function close() {
            rmItemDialog.opacity = 0
            closeRemoveDialog.restart()
        }
 
        Timer {
            id: closeRemoveDialog
            running: false
            repeat: false
            interval: 200
            onTriggered: {
                rmItemDialog.visible = false
            }
        }
 
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ee000000"}
            GradientStop { position: 0.4; color: '#ee151517'}
            GradientStop { position: 0.6; color: '#ee262527'}
            GradientStop { position: 0.7; color: '#ee201f21'}
            GradientStop { position: 1.0; color: "#ee000000"}
        }
 
        MultiEffect {
            source: rmItemDialog
            blurEnabled: true
            blur: 0.7
        }
 
        Rectangle {
            anchors.centerIn: parent
            width: childrenRect.width + 35
            height: childrenRect.height + 30
            radius: 30
            color: Parameters.pressedButtonBg
 
            GridLayout {
                columns: 4
                rows: 3
                anchors.centerIn: parent
                width: root.width * 0.67
                columnSpacing: 1
                rowSpacing: 2
 
                Rectangle {
                    Layout.fillWidth: true
                    Layout.columnSpan: 4
                    height: 55
                    color: Parameters.mainHighlightBg
                    topLeftRadius: 15
                    topRightRadius: 15
 
                    Text {
                        anchors.centerIn: parent
                        text: "Remover Item"
                        color: Parameters.mainBgColor
                        font.family: Parameters.defaultFont
                        font.pointSize: 18
                    }
                }
 
                Rectangle {
                    Layout.horizontalStretchFactor: 3
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)
                    
                    Text {
                        id: removeFName
                        anchors.centerIn: parent
                        color: '#e4595959'
                        font.family: Parameters.altFont
                        font.styleName: "Medium Oblique"
                        font.pointSize: 15
                        text: stock_model.get(rmItemDialog.callRm, "").name
                    }
                }
 
                Rectangle {
                    Layout.horizontalStretchFactor: 1
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)
 
                    TextInput {
                        id: removeFQuant
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.pointSize: 15
                        text: stock_model.get(rmItemDialog.callRm, "").quantity
                        validator: RegularExpressionValidator {
                            regularExpression: /(.|\s)*\S(.|\s)*/
                        }
                        focus: true
 
                        HoverHandler {
                            enabled: parent.visible
                            cursorShape: Qt.IBeamCursor
                        }
                    }
                }
 
                Rectangle {
                    Layout.horizontalStretchFactor: 2
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)
 
                    TextInput {
                        id: removeFCost
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.pointSize: 15
                        text: stock_model.get(rmItemDialog.callRm, "").buyPrice
                        validator: RegularExpressionValidator {
                            regularExpression: /(.|\s)*\S(.|\s)*/
                        }
                        focus: false
 
                        HoverHandler {
                            enabled: parent.visible
                            cursorShape: Qt.IBeamCursor
                        }
                    }
                }
 
                Rectangle {
                    Layout.horizontalStretchFactor: 2
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)
 
                    TextInput {
                        id: removeFSell
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.pointSize: 15
                        text: stock_model.get(rmItemDialog.callRm, "").sellPrice
                        validator: RegularExpressionValidator {
                            regularExpression: /(.|\s)*\S(.|\s)*/
                        }
                        focus: false
 
                        HoverHandler {
                            enabled: parent.visible
                            cursorShape: Qt.IBeamCursor
                        }
                    }
                }
 
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    Layout.columnSpan: 4
                    color: Parameters.highlightFg
                    bottomRightRadius: 15
                    bottomLeftRadius: 15
 
                    RowLayout {
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            right: parent.right
                            topMargin: 2
                            bottomMargin: 2
                            rightMargin: 6
                        }
                        layoutDirection: Qt.RightToLeft
                        spacing: 6
                        
                        Button {
                            id: removeSubmit
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: false
                            text: "OK" //"Adicionar"
                            implicitWidth: 74
                            implicitHeight: 34
 
                            onClicked: {
                                console.log("Trying to destroy index: " + rmItemDialog.callRm)
                                stock_model.eliminate(parseInt(rmItemDialog.callRm))

                                rmItemDialog.close()

                                rmItemDialog.itemRemoved()
                            }
 
                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.pointSize: 12
                                text: removeSubmit.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }
                            
                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 74
                                implicitHeight: 34
                                radius: searchContainer.radius
                                color: removeSubmit.down ? Parameters.pressedButtonBg : removeSubmit.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                border.width: 2
                                border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }
 
                            HoverHandler {
                                enabled: parent.visible
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
 
                        Button {
                            id: removeCancel
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: false
                            text: "Cancelar"
                            implicitWidth: 82
                            implicitHeight: 34
 
                            onClicked: {
                                rmItemDialog.close()
                            }
 
                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.pointSize: 12
                                text: removeCancel.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }
                            
                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 82
                                implicitHeight: 34
                                radius: searchContainer.radius
                                color: removeCancel.down ? Parameters.pressedButtonBg : removeCancel.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                border.width: 2
                                border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }
 
                            HoverHandler {
                                enabled: parent.visible
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }
        }
    }

            // find a way to do error handling on the inputs
        }
    }
}
