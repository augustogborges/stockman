pragma ComponentBehavior: Bound
import QtQuick
import QtCore
import QtQuick.Controls.Fusion
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQml
import QtGraphs

import Stocker
import Authenticator

Rectangle {
    id: containerRect
    anchors.fill: parent
    color: Parameters.mainBgColor

    property real globalScaleWidth: ((containerRect.height + containerRect.width) / 2.42) - sidebarRect.width
    property real globalScaleHeight: (containerRect.height + containerRect.width) / 4.55

    property string search: ""
    property string userSearch: ""
    property string userFilter: userLevelSearcher.displayText
    property int productsCount: stock_model.rowCount()
    property int usersCount: user_model.rowCount()
    property var sModel: stock_model
    property var uModel: user_model
    property var loggedUser: []
    signal itemAction
    signal userAction
    signal userLogin
    property int lowItemThreshold: 10
    property int lowItems: stock_model.getLowQuantityTotal(containerRect.lowItemThreshold)
    property int viewIndex: 0

    onLoggedUserChanged: {
        if (loggedUser[0] && loggedUser[1]) {
            if (arguments[1] == 0) {
                dashButton.visible = true;
                itensButton.visible = true;
                usersButton.visible = true;
            } else if (loggedUser[1] == 1) {
                dashButton.visible = true;
                itensButton.visible = true;
                usersButton.visible = false;
            } else {
                //containerRect.viewIndex = 1;
                dashButton.visible = true;
                itensButton.visible = true;
                usersButton.visible = false;
                fullDash.visible = false;
                stockOnlyDash.visible = true;
                //itensButton.scale = 1;
                //itensButton.opacity = 1;
            }
        }
    }

    Connections {
        target: containerRect
        function onSearchChanged() {
            listView.model = stock_model.getEffectiveCount(containerRect.search);
        }

        function onUserSearchChanged() {
            usersList.model = 0;
            Qt.callLater(() => {
                usersList.model = user_model.getEffectiveCount(containerRect.userSearch, containerRect.userFilter);
            });
        }

        function onUserFilterChanged() {
            usersList.model = 0;
            Qt.callLater(() => {
                usersList.model = user_model.getEffectiveCount(containerRect.userSearch, containerRect.userFilter);
            });
        }

        function onUserAction() {
            user_model.reloadDB();
            containerRect.usersCount = user_model.rowCount();
            usersList.model = 0;
            Qt.callLater(() => {
                usersList.model = user_model.getEffectiveCount(containerRect.userSearch, containerRect.userFilter);
            });
        }

        function onItemAction() {
            containerRect.reloadUI();
        }
    }

    function reloadUI() {
        containerRect.sModel = "";
        stock_model.reloadDB();
        productsCount = stock_model.rowCount();
        usersCount = user_model.rowCount();
        listView.model = stock_model.getEffectiveCount(containerRect.search);
        containerRect.sModel = stock_model;
        stockProfitList.model = "";
        stockProfitList.model = Math.min(containerRect.productsCount, 10);
        stockFillList.model = "";
        stockFillList.model = Math.min(containerRect.productsCount, 10);
        if (stockOnlyDash.visible || containerRect.loggedUser[1] == 2) {
            stockFillListSOD.model = "";
            stockFillListSOD.model = containerRect.productsCount;
            stockFillChartSOD.regenGraph();
        }
        stockProfitChart.regenGraph();
        stockFillChart.regenGraph();
        smallestIndProfits.updateLowProfits();
        biggestIndProfits.updateHighProfits();
        financeSummary.regenSummary();
        containerRect.lowItems = stock_model.getLowQuantityTotal(containerRect.lowItemThreshold);
    }

    StockModel {
        id: stock_model
    }

    UserModel {
        id: user_model
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    GridLayout {
        anchors.fill: parent
        columns: 2
        rows: 1

        Rectangle {
            id: sidebarRect
            Layout.fillHeight: true
            Layout.fillWidth: false
            Layout.preferredWidth: 170
            Layout.maximumWidth: containerRect.width / 8
            topLeftRadius: 0
            bottomLeftRadius: 0
            topRightRadius: 3
            bottomRightRadius: 3
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop {
                    position: 0.0
                    color: Parameters.mainHighlightBg
                }
                GradientStop {
                    position: 0.45
                    color: Qt.lighter(Parameters.mainHighlightBg, 1.1)
                }
                GradientStop {
                    position: 0.5
                    color: Qt.lighter(Parameters.mainHighlightBg, 1.2)
                }
                GradientStop {
                    position: 0.66
                    color: Qt.lighter(Parameters.mainHighlightBg, 1.6)
                }
                GradientStop {
                    position: 0.75
                    color: Qt.lighter(Parameters.mainHighlightBg, 1.3)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.lighter(Parameters.mainHighlightBg, 1.1)
                }
            }

            ColumnLayout {
                id: sideTabs
                anchors {
                    top: parent.top
                    right: parent.right
                    left: parent.left
                    bottom: parent.bottom
                }
                spacing: 32

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: 110
                    Layout.maximumHeight: containerRect.globalScaleHeight / 6
                    Layout.fillWidth: true
                    Layout.margins: 8

                    Rectangle {
                        id: customLogoContainer
                        visible: customCLogo.filePath
                        anchors.fill: parent
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Image {
                            id: customCLogo
                            anchors.fill: parent
                            property string filePath: stock_model.getImgPath()
                            source: filePath
                            sourceClipRect: customLogoContainer
                            asynchronous: true
                            cache: true
                            fillMode: Image.PreserveAspectFit
                            sourceSize.width: 256
                            sourceSize.height: 256
                            visible: parent.visible
                        }
                    }

                    Rectangle {
                        id: logoContainer
                        visible: !customCLogo.visible
                        anchors.centerIn: parent
                        height: parent.height
                        width: parent.width
                        radius: Parameters.defaultRadius * 2
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: Qt.lighter(Parameters.mainHighlightBg, 1.66)
                            }
                            GradientStop {
                                position: 0.6
                                color: Qt.darker(Parameters.highlightFg, 1.2)
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.lighter(Parameters.highlightFg, 1.3)
                            }
                        }
                    }

                    Rectangle {
                        id: logoRect
                        visible: logoContainer.visible
                        anchors.centerIn: logoContainer
                        width: logoContainer.width - 8
                        height: logoContainer.height - 8
                        radius: logoContainer.radius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: Parameters.shadeHighlightBg
                            }
                            GradientStop {
                                position: 0.45
                                color: Qt.lighter(Parameters.shadeHighlightBg, 1.22)
                            }
                            GradientStop {
                                position: 0.5
                                color: Qt.lighter(Parameters.shadeHighlightBg, 1.31)
                            }
                            GradientStop {
                                position: 0.66
                                color: Qt.lighter(Parameters.shadeHighlightBg, 1.4)
                            }
                            GradientStop {
                                position: 0.75
                                color: Qt.lighter(Parameters.shadeHighlightBg, 1.29)
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.lighter(Parameters.shadeHighlightBg, 1.15)
                            }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                id: logoIcon
                                Layout.alignment: Qt.AlignVCenter
                                text: ""
                                font.family: Parameters.iconFontBold
                                font.pixelSize: containerRect.globalScaleHeight / 23
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 12
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            Text {
                                id: logoText
                                Layout.alignment: Qt.AlignVCenter
                                text: "Stockman"
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.underline: false
                                font.pixelSize: containerRect.globalScaleHeight / 24
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 10
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.2)
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: logoContainer.visible && !customLogoContainer.visible
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.RightButton | Qt.MiddleButton
                        onClicked: mouse => {
                            if (mouse.button == Qt.RightButton) {
                                photoPicker.open();
                            } else {
                                customCLogo.source = "";
                                customLogoContainer.visible = false;
                                logoContainer.visible = true;
                                stock_model.saveImgPath("");
                            }
                        }
                        preventStealing: enabled
                    }

                    FileDialog {
                        id: photoPicker
                        currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
                        nameFilters: ["Image Files (*.png *.jpg *.jpeg)"]
                        onAccepted: {
                            stock_model.saveImgPath(selectedFile);
                            customCLogo.source = selectedFile;
                            logoContainer.visible = false;
                            customLogoContainer.visible = true;
                        }
                    }
                }

                TabRect {
                    id: dashButton
                    Layout.fillHeight: false
                    buttonIndex: 0
                    Component.onCompleted: {
                        containerRect.viewIndex = 0;
                        usersButton.scale = 0.9;
                        itensButton.scale = 0.9;
                        dashButton.scale = 1;
                        usersButton.opacity = 0.95;
                        itensButton.opacity = 0.95;
                        dashButton.opacity = 1;
                    }
                }

                TabRect {
                    id: itensButton
                    Layout.fillHeight: false
                    buttonIndex: 1
                }

                TabRect {
                    id: usersButton
                    Layout.fillHeight: false
                    buttonIndex: 2
                }

                Item {
                    Layout.fillHeight: true
                }

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: userInfoContainer.height
                    Layout.fillWidth: true
                    Layout.margins: 8
                    visible: true

                    Rectangle {
                        id: userInfoContainer
                        anchors.centerIn: parent
                        implicitHeight: 100
                        implicitWidth: parent.width
                        radius: 30
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: Qt.lighter(Parameters.mainHighlightBg, 1.66)
                            }
                            GradientStop {
                                position: 0.6
                                color: Qt.darker(Parameters.highlightFg, 1.2)
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.lighter(Parameters.highlightFg, 1.3)
                            }
                        }
                    }

                    Rectangle {
                        id: userInfoRect
                        anchors.centerIn: userInfoContainer
                        width: userInfoContainer.width - 8
                        height: userInfoContainer.height - 8
                        radius: userInfoContainer.radius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: Parameters.shadeHighlightBg
                            }
                            GradientStop {
                                position: 0.45
                                color: Qt.lighter(Parameters.shadeHighlightBg, 1.22)
                            }
                            GradientStop {
                                position: 0.5
                                color: Qt.lighter(Parameters.shadeHighlightBg, 1.31)
                            }
                            GradientStop {
                                position: 0.66
                                color: Qt.lighter(Parameters.shadeHighlightBg, 1.4)
                            }
                            GradientStop {
                                position: 0.75
                                color: Qt.lighter(Parameters.shadeHighlightBg, 1.29)
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.lighter(Parameters.shadeHighlightBg, 1.15)
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            width: parent.width
                            height: parent.height

                            RowLayout {
                                id: logo2row
                                //Layout.fillHeight: false
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                                Layout.fillHeight: true
                                Layout.preferredHeight: parent.height / 4
                                Layout.verticalStretchFactor: 1
                                spacing: 4
                                //visible: !logoContainer.visible && customLogoContainer.visible

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    id: logo2Symbol
                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                                    Layout.topMargin: 2
                                    text: ""
                                    font.family: Parameters.iconFontBold
                                    font.pixelSize: userInfoRect.height * 0.15
                                    fontSizeMode: Text.Fit
                                    minimumPixelSize: 6
                                    color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                    visible: !logoContainer.visible && customLogoContainer.visible
                                }

                                Text {
                                    id: logo2Text
                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                                    Layout.topMargin: 2
                                    text: "Stockman"
                                    font.family: Parameters.defaultFont
                                    font.styleName: "Medium"
                                    font.underline: false
                                    font.pixelSize: userInfoRect.height * 0.14
                                    fontSizeMode: Text.Fit
                                    minimumPixelSize: 6
                                    color: Qt.lighter(Parameters.mainHighlightBg, 4.2)
                                    visible: !logoContainer.visible && customLogoContainer.visible
                                }

                                Item {
                                    Layout.fillWidth: true
                                }
                            }

                            /*Item {
                                Layout.fillHeight: logo2row.visible
                            }*/

                            RowLayout {
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.preferredHeight: parent.height / 2
                                Layout.verticalStretchFactor: 2
                                spacing: 6

                                Item {
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    id: usernameInitialsRect
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillWidth: false
                                    Layout.fillHeight: false
                                    Layout.preferredHeight: userInfoRect.height * 0.42
                                    Layout.preferredWidth: height
                                    radius: height / 2
                                    color: Parameters.highlightFg

                                    Text {
                                        anchors.centerIn: parent
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Medium"
                                        font.pixelSize: parent.height * 0.6
                                        fontSizeMode: Text.Fit
                                        minimumPixelSize: 8
                                        text: {
                                            let name = (user_model.getDisplayByUsername(containerRect.loggedUser[0])).split(" ");
                                            if (name.length == 1) {
                                                return name[0][0].toUpperCase() + name[0][1].toUpperCase();
                                            } else {
                                                let firstName = name[0];
                                                let lastName = name[name.length - 1];
                                                return firstName[0].toUpperCase() + lastName[0].toUpperCase();
                                            }
                                        }
                                        color: "#efefef"
                                    }
                                }

                                ColumnLayout {
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    Text {
                                        Layout.alignment: Qt.AlignLeft
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Medium"
                                        color: "#efefef"
                                        text: user_model.getDisplayByUsername(containerRect.loggedUser[0])
                                        font.pixelSize: usernameInitialsRect.height * 0.4
                                        fontSizeMode: Text.Fit
                                        minimumPixelSize: 6
                                        Layout.maximumWidth: userInfoRect.width * 0.6
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.alignment: Qt.AlignLeft
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Medium"
                                        color: "#efefef"
                                        text: containerRect.loggedUser[0]
                                        font.pixelSize: usernameInitialsRect.height * 0.3
                                        fontSizeMode: Text.Fit
                                        minimumPixelSize: 4
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }
                            }

                            /*Item {
                                Layout.fillHeight: true
                            }*/

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.preferredHeight: parent.height / 4
                                Layout.verticalStretchFactor: 1
                                Layout.bottomMargin: 2
                                //Layout.fillHeight: logo2row.visible
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                                //Layout.preferredHeight: logo2row.visible ? userInfoRect.height * 0.22 : undefined

                                RowLayout {
                                    id: userRoleInfo
                                    anchors.fill: parent
                                    spacing: 4

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        id: userRoleSymbol
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        font.family: Parameters.iconFontBold
                                        font.pixelSize: userInfoRect.height * 0.14
                                        fontSizeMode: Text.Fit
                                        minimumPixelSize: 6
                                        text: {
                                            switch (containerRect.loggedUser[1]) {
                                            case 0:
                                                return "";
                                            case 1:
                                                return "";
                                            case 2:
                                                return "";
                                            default:
                                                return;
                                            }
                                        }
                                        color: "#efefef"
                                    }

                                    Text {
                                        id: userRoleName
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Medium"
                                        font.pixelSize: userInfoRect.height * 0.13
                                        fontSizeMode: Text.Fit
                                        minimumPixelSize: 6
                                        text: {
                                            switch (containerRect.loggedUser[1]) {
                                            case 0:
                                                return "Supervisão";
                                            case 1:
                                                return "Financeiro";
                                            case 2:
                                                return "Estoque";
                                            default:
                                                return;
                                            }
                                        }
                                        color: "#efefef"
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: mainRect
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "transparent"

            StackLayout {
                id: switchableTabs
                anchors.fill: parent
                currentIndex: containerRect.viewIndex

                Rectangle {
                    id: firstTab
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    gradient: Parameters.whiteBgGradient
                    property list<color> graphColors: ['#049b43', '#31d100', '#26f9dd', '#308add', '#2a2cc2', '#7103d8', '#8f047c', '#f9af26', '#ce6300', '#9b0404']

                    Rectangle {
                        id: dashContainer
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                            topMargin: parent.height * 0.05
                            bottomMargin: parent.height * 0.05
                            leftMargin: parent.width * 0.04
                            rightMargin: parent.width * 0.04
                        }
                        color: "transparent"

                        ColumnLayout {
                            anchors.fill: parent

                            Text {
                                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                Layout.fillHeight: false
                                text: "Dashboard"
                                font.family: Parameters.defaultFont
                                font.styleName: "Bold"
                                font.pixelSize: dashContainer.height * 0.04
                                color: "#000000"
                            }

                            Text {
                                Layout.alignment: Qt.AlignLeft
                                Layout.fillHeight: false
                                text: "Resumo Geral  |  " + new Date().toLocaleTimeString(Qt.locale("pt_BR"), Locale.ShortFormat) + " ⋅ " + new Date().toLocaleDateString(Qt.locale("pt_BR"), Locale.ShortFormat)
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: dashContainer.height * 0.015
                                color: "#303030"
                            }

                            Item {
                                Layout.preferredHeight: 10
                            }

                            Rectangle {
                                id: stockOnlyDash
                                visible: false
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                Item {
                                    anchors.fill: parent
                                    //anchors.bottomMargin: parent.height * 0.2

                                    Rectangle {
                                        id: stockFillContainerSOD
                                        anchors.fill: parent
                                        radius: Parameters.defaultRadius

                                        color: Parameters.shadeBgColor

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.topMargin: parent.height * 0.05
                                            anchors.bottomMargin: parent.height * 0.05
                                            anchors.leftMargin: parent.width * 0.08
                                            anchors.rightMargin: parent.width * 0.08
                                            spacing: parent.height * 0.015

                                            RowLayout {
                                                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                                                Layout.fillHeight: false
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: stockFillContainerSOD.height * 0.08

                                                Text {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: false
                                                    font.pixelSize: stockFillContainerSOD.height * 0.05
                                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                    text: "Composição do Estoque"
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Medium"
                                                    color: "#000000"
                                                }

                                                Rectangle {
                                                    id: lowQuantityDisplayContainerSOD
                                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                                    Layout.preferredWidth: stockFillContainerSOD.width / 4.2
                                                    Layout.fillWidth: false
                                                    Layout.fillHeight: true
                                                    radius: width * 0.05
                                                    //color: '#75da2121'
                                                    gradient: Gradient {
                                                        orientation: Gradient.Horizontal
                                                        GradientStop {
                                                            position: 0.0
                                                            color: Qt.lighter(Parameters.lowCashRed, 1.35)
                                                        }
                                                        GradientStop {
                                                            position: 0.4
                                                            color: Qt.lighter(Parameters.lowCashRed, 1.55)
                                                        }
                                                        GradientStop {
                                                            position: 0.85
                                                            color: Qt.lighter(Parameters.lowCashRed, 1.45)
                                                        }
                                                    }

                                                    RowLayout {
                                                        anchors.fill: parent
                                                        anchors.topMargin: -parent.height * 0.03

                                                        Item {
                                                            Layout.fillWidth: true
                                                        }

                                                        Text {
                                                            Layout.alignment: Qt.AlignVCenter
                                                            Layout.fillWidth: false
                                                            font.pixelSize: lowQuantityDisplayContainerSOD.height * 0.42
                                                            minimumPixelSize: 8
                                                            fontSizeMode: Text.Fit
                                                            text: ""
                                                            font.family: Parameters.iconFont
                                                            color: "#000000"
                                                        }

                                                        Text {
                                                            Layout.alignment: Qt.AlignVCenter
                                                            Layout.fillWidth: false
                                                            font.pixelSize: lowQuantityDisplayContainerSOD.height * 0.3
                                                            minimumPixelSize: 8
                                                            fontSizeMode: Text.Fit
                                                            text: stock_model.getLowQuantityTotal(containerRect.lowItemThreshold) + " itens precisam de reposição"
                                                            font.family: Parameters.defaultFont
                                                            color: "#000000"
                                                        }

                                                        Item {
                                                            Layout.fillWidth: true
                                                        }
                                                    }
                                                }
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                spacing: stockFillContainerSOD.width * 0.027

                                                Item {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: false
                                                    Layout.preferredHeight: width
                                                    Layout.preferredWidth: stockFillContainerSOD.width / 4.2

                                                    Rectangle {
                                                        id: stockFillGraphListSOD
                                                        anchors.fill: parent
                                                        radius: Parameters.defaultRadius
                                                        color: "white"
                                                        border.width: 1
                                                        border.color: Parameters.lightBorder
                                                        clip: true

                                                        ListView {
                                                            id: stockFillListSOD
                                                            anchors.fill: parent
                                                            anchors.leftMargin: parent.width * 0.03
                                                            anchors.rightMargin: parent.width * 0.03
                                                            anchors.topMargin: parent.height * 0.02
                                                            anchors.bottomMargin: parent.height * 0.02
                                                            orientation: ListView.Vertical
                                                            boundsBehavior: ListView.StopAtBounds

                                                            model: containerRect.productsCount

                                                            delegate: Rectangle {
                                                                required property int index
                                                                anchors.left: parent.left
                                                                anchors.right: parent.right
                                                                height: stockFillGraphListSOD.height * 0.13
                                                                color: "transparent"

                                                                RowLayout {
                                                                    anchors.fill: parent

                                                                    Rectangle {
                                                                        id: fillColorBallDelegateSOD
                                                                        Layout.fillHeight: false
                                                                        Layout.fillWidth: false
                                                                        Layout.alignment: Qt.AlignVCenter
                                                                        Layout.preferredHeight: stockFillGraphListSOD.height * 0.035
                                                                        Layout.preferredWidth: height
                                                                        radius: height / 2
                                                                        color: firstTab.graphColors[index]
                                                                    }

                                                                    Text {
                                                                        Layout.fillWidth: true
                                                                        Layout.fillHeight: false
                                                                        Layout.alignment: Qt.AlignVCenter
                                                                        font.family: Parameters.defaultFont
                                                                        font.styleName: "Medium"
                                                                        font.pixelSize: stockFillGraphListSOD.height * 0.05
                                                                        fontSizeMode: Text.Fit
                                                                        minimumPixelSize: 10
                                                                        color: "#000000"
                                                                        renderType: Text.CurveRendering
                                                                        elide: Text.ElideRight
                                                                        text: stock_model.getSortedByStockQuantity(index, containerRect.lowItemThreshold).name
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }

                                                Item {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: false
                                                    Layout.preferredWidth: stockFillContainerSOD.width / 3

                                                    Rectangle {
                                                        id: stockFillGraphSOD
                                                        anchors.fill: parent
                                                        radius: Parameters.defaultRadius
                                                        border.width: 1
                                                        border.color: Parameters.lightBorder

                                                        GraphsView {
                                                            id: stockFillChartSOD
                                                            anchors.centerIn: parent
                                                            antialiasing: true
                                                            width: parent.width * 1.15
                                                            height: width
                                                            shadowVisible: true
                                                            theme: GraphsTheme {
                                                                labelTextColor: "#000000"
                                                                backgroundColor: "transparent"
                                                                labelBackgroundVisible: true
                                                                labelFont.family: Parameters.defaultFont
                                                                labelFont.styleName: "Medium"
                                                                labelFont.pointSize: stockFillChartSOD.width * 0.22
                                                                labelBorderVisible: true
                                                                labelsVisible: true
                                                            }

                                                            PieSeries {
                                                                id: stockPieSeriesSOD
                                                            }

                                                            function regenGraph() {
                                                                stockPieSeriesSOD.clear();
                                                                for (var i = 0; i < containerRect.productsCount; i++) {
                                                                    var number = stock_model.getSortedByStockQuantity(i, containerRect.lowItemThreshold).percentage;
                                                                    var slice = stockPieSeriesSOD.append(stock_model.getSortedByStockQuantity(i, containerRect.lowItemThreshold).percentage + "%", stock_model.getSortedByStockQuantity(i, containerRect.lowItemThreshold).percentage);
                                                                    slice.borderWidth = 0;
                                                                    slice.color = firstTab.graphColors[i];
                                                                    slice.label = stock_model.getSortedByStockQuantity(i, containerRect.lowItemThreshold).percentage + "%";
                                                                    if (number >= 10) {
                                                                        slice.labelVisible = true;
                                                                        slice.labelPosition = PieSlice.LabelPosition.InsideHorizontal;
                                                                    } //else {
                                                                    // slice.labelPosition = PieSlice.LabelPosition.Outside;
                                                                    // slice.labelArmLengthFactor = 0.07;
                                                                    //}
                                                                }
                                                            }
                                                            Component.onCompleted: regenGraph()
                                                        }
                                                    }
                                                }

                                                Item {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: false
                                                    Layout.preferredHeight: width
                                                    Layout.preferredWidth: stockFillContainerSOD.width / 4.2

                                                    Rectangle {
                                                        id: stockLowListSOD
                                                        anchors.fill: parent
                                                        radius: Parameters.defaultRadius
                                                        border.width: 3
                                                        border.color: Parameters.lowCashRed
                                                        clip: true
                                                        gradient: Gradient {
                                                            GradientStop {
                                                                position: 0.0
                                                                color: Qt.lighter(Parameters.lowCashRed, 1.85)
                                                            }
                                                            GradientStop {
                                                                position: 0.55
                                                                color: Qt.lighter(Parameters.lowCashRed, 2.1)
                                                            }
                                                            GradientStop {
                                                                position: 1.0
                                                                color: Qt.lighter(Parameters.lowCashRed, 2.3)
                                                            }
                                                        }

                                                        ListView {
                                                            id: lowListSOD
                                                            anchors.fill: parent
                                                            anchors.leftMargin: parent.width * 0.03
                                                            anchors.rightMargin: parent.width * 0.03
                                                            anchors.topMargin: parent.height * 0.02
                                                            anchors.bottomMargin: parent.height * 0.02
                                                            orientation: ListView.Vertical
                                                            boundsBehavior: ListView.StopAtBounds

                                                            model: stock_model.getLowQuantityTotal(containerRect.lowItemThreshold)

                                                            delegate: Rectangle {
                                                                required property int index
                                                                anchors.left: parent.left
                                                                anchors.right: parent.right
                                                                height: stockLowListSOD.height * 0.13
                                                                color: "transparent"

                                                                RowLayout {
                                                                    anchors.fill: parent

                                                                    Rectangle {
                                                                        id: monochromeBallDelegateSOD
                                                                        Layout.fillHeight: false
                                                                        Layout.fillWidth: false
                                                                        Layout.alignment: Qt.AlignVCenter
                                                                        Layout.preferredHeight: stockLowListSOD.height * 0.013
                                                                        Layout.preferredWidth: height
                                                                        radius: height / 2
                                                                        color: "#202020"
                                                                    }

                                                                    Text {
                                                                        Layout.fillWidth: true
                                                                        Layout.fillHeight: false
                                                                        Layout.alignment: Qt.AlignVCenter
                                                                        font.family: Parameters.defaultFont
                                                                        font.styleName: "Medium"
                                                                        font.pixelSize: stockLowListSOD.height * 0.042
                                                                        fontSizeMode: Text.Fit
                                                                        minimumPixelSize: 10
                                                                        color: "#000000"
                                                                        renderType: Text.CurveRendering
                                                                        elide: Text.ElideRight
                                                                        text: stock_model.getLowQuantityItems(index, containerRect.lowItemThreshold).name
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: false
                                                Layout.preferredHeight: stockFillContainerSOD.height * 0.15

                                                Rectangle {
                                                    Layout.alignment: Qt.AlignVCenter
                                                    Layout.fillHeight: false
                                                    Layout.preferredHeight: stockFillContainerSOD.height * 0.12
                                                    Layout.fillWidth: false
                                                    Layout.preferredWidth: height
                                                    radius: height / 2
                                                    color: '#0ac0e4'

                                                    Text {
                                                        anchors.centerIn: parent
                                                        font.family: Parameters.iconFont
                                                        font.pixelSize: stockFillContainerSOD.height * 0.08
                                                        text: ""
                                                        color: "#000000"
                                                    }
                                                }

                                                ColumnLayout {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true

                                                    Text {
                                                        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                                                        font.family: Parameters.defaultFont
                                                        font.pixelSize: stockFillContainerSOD.height * 0.036
                                                        text: "Total de produtos:"
                                                        color: "#000000"
                                                    }

                                                    Text {
                                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                        font.family: Parameters.defaultFont
                                                        font.styleName: "Medium"
                                                        font.pixelSize: stockFillContainerSOD.height * 0.05
                                                        text: stock_model.getTotalQuant()
                                                        color: "#000000"
                                                    }
                                                }

                                                Item {
                                                    Layout.preferredWidth: 6
                                                }

                                                Rectangle {
                                                    Layout.preferredWidth: 1
                                                    Layout.fillHeight: true
                                                    Layout.topMargin: 1
                                                    Layout.bottomMargin: 1
                                                    radius: 1
                                                    color: "#454545"
                                                }

                                                Item {
                                                    Layout.preferredWidth: 6
                                                }

                                                ColumnLayout {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true

                                                    Text {
                                                        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                                                        font.family: Parameters.defaultFont
                                                        font.pixelSize: stockFillContainerSOD.height * 0.036
                                                        text: "Tipos de produtos:"
                                                        color: "#000000"
                                                    }

                                                    Text {
                                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                        font.family: Parameters.defaultFont
                                                        font.styleName: "Medium"
                                                        font.pixelSize: stockFillContainerSOD.height * 0.05
                                                        text: containerRect.productsCount
                                                        color: "#000000"
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    MultiEffect {
                                        anchors.fill: stockFillContainerSOD
                                        source: stockFillContainerSOD

                                        autoPaddingEnabled: true
                                        shadowEnabled: true
                                        shadowOpacity: 0.8
                                        shadowScale: 0.99
                                        shadowVerticalOffset: 4
                                        shadowColor: "#000000"
                                    }
                                }
                            }

                            GridLayout {
                                id: fullDash
                                rows: 6
                                columns: 6
                                columnSpacing: 10
                                rowSpacing: 12
                                visible: true
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                Item {
                                    id: profitDistItem
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.rowSpan: 4
                                    Layout.columnSpan: 4

                                    Rectangle {
                                        id: profitDistContainer
                                        anchors.fill: parent
                                        radius: Parameters.defaultRadius
                                        color: Parameters.shadeBgColor

                                        RowLayout {
                                            anchors.fill: parent

                                            Item {
                                                Layout.preferredWidth: parent.width * 0.1
                                            }

                                            ColumnLayout {
                                                Layout.topMargin: parent.height * 0.05
                                                Layout.bottomMargin: parent.height * 0.05
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                Layout.preferredWidth: containerRect.globalScaleWidth * 0.165

                                                Text {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: false
                                                    font.pixelSize: (profitDistItem.width + 0.5 * profitDistItem.height) * 0.02
                                                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                                                    text: "Distribuição de Lucro Potencial no Inventário"
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Medium"
                                                    color: "#000000"
                                                }

                                                Rectangle {
                                                    id: profitDistInfoContainer
                                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    Layout.topMargin: parent.height * 0.04
                                                    Layout.bottomMargin: parent.height * 0.04
                                                    Layout.maximumHeight: profitDistItem.height * 0.7
                                                    Layout.maximumWidth: profitDistItem.width * 0.4
                                                    radius: Parameters.defaultRadius
                                                    color: "white"
                                                    border.width: 1
                                                    border.color: Parameters.lightBorder
                                                    clip: true

                                                    ListView {
                                                        id: stockProfitList
                                                        anchors.fill: parent
                                                        anchors.leftMargin: parent.width * 0.04
                                                        anchors.rightMargin: parent.width * 0.04
                                                        anchors.topMargin: parent.height * 0.02
                                                        anchors.bottomMargin: parent.height * 0.02
                                                        orientation: ListView.Vertical
                                                        boundsBehavior: ListView.StopAtBounds

                                                        model: Math.min(containerRect.productsCount, 10)

                                                        delegate: Rectangle {
                                                            required property int index
                                                            anchors.left: parent.left
                                                            anchors.right: parent.right
                                                            height: profitDistInfoContainer.height * 0.15
                                                            color: "transparent"

                                                            RowLayout {
                                                                anchors.fill: parent
                                                                height: parent.height

                                                                Rectangle {
                                                                    id: profitColorBallDelegate
                                                                    Layout.fillWidth: false
                                                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                                    Layout.preferredWidth: containerRect.globalScaleWidth / 78
                                                                    Layout.preferredHeight: width
                                                                    radius: width / 2
                                                                    color: firstTab.graphColors[index]
                                                                }

                                                                Text {
                                                                    Layout.maximumHeight: profitInfoDistContainer.height * 0.15
                                                                    Layout.fillWidth: true
                                                                    Layout.rightMargin: 12
                                                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                                    font.family: Parameters.defaultFont
                                                                    font.styleName: "Medium"
                                                                    font.pixelSize: containerRect.globalScaleWidth / 50
                                                                    fontSizeMode: Text.Fit
                                                                    minimumPixelSize: 6
                                                                    elide: Text.ElideRight
                                                                    color: "#000000"
                                                                    text: stock_model.getSortedByTotalProfit(index).name
                                                                }

                                                                Text {
                                                                    Layout.maximumHeight: profitInfoDistContainer.height * 0.15
                                                                    Layout.fillWidth: false
                                                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                                                                    font.family: Parameters.defaultFont
                                                                    font.styleName: "Medium"
                                                                    font.pixelSize: containerRect.globalScaleWidth / 50
                                                                    fontSizeMode: Text.Fit
                                                                    minimumPixelSize: 5
                                                                    color: "#000000"
                                                                    text: "R$" + stock_model.getSortedByTotalProfit(index).profit.toFixed(2).toString().replace(".", ",")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                Layout.topMargin: parent.height * 0.05
                                                Layout.bottomMargin: parent.height * 0.05
                                                //Layout.fillHeight: true
                                                //Layout.maximumHeight: parent.height * 0.8
                                                Layout.fillWidth: true
                                                //Layout.preferredWidth: height
                                                Layout.preferredWidth: containerRect.globalScaleWidth * 0.23
                                                Layout.preferredHeight: width
                                                Layout.maximumHeight: profitDistItem.height * 0.85
                                                Layout.maximumWidth: profitDistItem.height * 0.85
                                                radius: Parameters.defaultRadius
                                                color: "white"
                                                border.width: 1
                                                border.color: Parameters.lightBorder

                                                GraphsView {
                                                    id: stockProfitChart
                                                    anchors.centerIn: parent
                                                    antialiasing: true
                                                    width: parent.width * 1.25
                                                    height: width
                                                    shadowVisible: true
                                                    theme: GraphsTheme {
                                                        labelTextColor: "#000000"
                                                        backgroundColor: "transparent"
                                                        labelBackgroundVisible: true
                                                        labelFont.family: Parameters.defaultFont
                                                        labelFont.styleName: "Medium"
                                                        labelFont.pointSize: stockProfitChart.width * 0.22
                                                        labelBorderVisible: true
                                                        labelsVisible: true
                                                    }

                                                    PieSeries {
                                                        id: pieSeries
                                                    }

                                                    function regenGraph() {
                                                        pieSeries.clear();
                                                        for (var i = 0; i < containerRect.productsCount; i++) {
                                                            var number = stock_model.getSortedByTotalProfit(i).percentage;
                                                            var slice = pieSeries.append(stock_model.getSortedByTotalProfit(i).percentage + "%", stock_model.getSortedByTotalProfit(i).percentage);
                                                            slice.borderWidth = 0;
                                                            slice.color = firstTab.graphColors[i];
                                                            slice.label = stock_model.getSortedByTotalProfit(i).percentage + "%";
                                                            if (number >= 15) {
                                                                slice.labelVisible = true;
                                                                slice.labelPosition = PieSlice.LabelPosition.InsideHorizontal;
                                                            } else if (number >= 9) {
                                                                slice.labelVisible = true;
                                                                slice.labelPosition = PieSlice.LabelPosition.Outside;
                                                                slice.labelArmLengthFactor = 0.05;
                                                            } else {
                                                                PieSlice.LabelPosition.InsideHorizontal;
                                                                slice.labelVisible = false;
                                                            }
                                                        }
                                                    }
                                                    Component.onCompleted: regenGraph()
                                                }
                                            }

                                            Item {
                                                Layout.preferredWidth: parent.width * 0.1
                                            }
                                        }
                                    }

                                    MultiEffect {
                                        anchors.fill: profitDistContainer
                                        source: profitDistContainer

                                        autoPaddingEnabled: true
                                        shadowEnabled: true
                                        shadowOpacity: 0.8
                                        shadowScale: 0.99
                                        shadowVerticalOffset: 4
                                        shadowColor: "#000000"
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.rowSpan: 4
                                    Layout.columnSpan: 2

                                    Rectangle {
                                        id: stockFillContainer
                                        anchors.fill: parent
                                        radius: Parameters.defaultRadius
                                        color: Parameters.shadeBgColor
                                        clip: true

                                        ColumnLayout {
                                            anchors.fill: parent
                                            /*anchors.topMargin: parent.height * 0.05
                                            anchors.bottomMargin: parent.height * 0.05
                                            anchors.leftMargin: parent.width * 0.08
                                            anchors.rightMargin: parent.width * 0.08*/
                                            spacing: parent.height * 0.015

                                            RowLayout {
                                                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                                                Layout.topMargin: stockFillContainer.height * 0.05
                                                //Layout.leftMargin: stockFillContainer.width * 0.08
                                                //Layout.rightMargin: stockFillContainer.width * 0.08
                                                Layout.fillHeight: false
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: stockFillContainer.height * 0.08

                                                Item {
                                                    Layout.horizontalStretchFactor: 1
                                                    Layout.fillWidth: true
                                                    Layout.maximumWidth: stockFillContainer.width * 0.08
                                                    Layout.minimumWidth: 3
                                                    Layout.preferredWidth: 4
                                                }

                                                Text {
                                                    Layout.horizontalStretchFactor: 3
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: false
                                                    Layout.preferredWidth: implicitWidth
                                                    Layout.maximumWidth: stockFillContainer.width * 0.45
                                                    font.pixelSize: (stockFillContainer.width + 0.5 * stockFillContainer.height) * 0.027
                                                    //Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                                    Layout.alignment: Qt.AlignVCenter
                                                    text: "Composição do Estoque"
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Medium"
                                                    fontSizeMode: Text.Fit
                                                    minimumPixelSize: 7
                                                    elide: Text.ElideRight
                                                    color: "#000000"
                                                }

                                                Rectangle {
                                                    id: lowQuantityDisplayContainer
                                                    Layout.horizontalStretchFactor: 3
                                                    //Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                                    Layout.fillWidth: true
                                                    Layout.alignment: Qt.AlignVCenter
                                                    Layout.maximumWidth: stockFillContainer.width * 0.45
                                                    //Layout.preferredWidth: stockWarn1.implicitWidth + 12 + stockWarn2.implicitWidth
                                                    Layout.preferredWidth: stockFillContainer.width * 0.4
                                                    //Layout.minimumWidth: stockWarnLayout.width
                                                    //Layout.fillHeight: true
                                                    Layout.preferredHeight: stockWarn1.height * 1.55
                                                    radius: height * 0.22
                                                    color: '#75da2121'

                                                    property var goodGradient: Gradient {
                                                        orientation: Gradient.Horizontal
                                                        GradientStop {
                                                            position: 0.0
                                                            color: Qt.lighter(Parameters.cashGreen, 1.35)
                                                        }
                                                        GradientStop {
                                                            position: 0.4
                                                            color: Qt.lighter(Parameters.cashGreen, 1.55)
                                                        }
                                                        GradientStop {
                                                            position: 0.85
                                                            color: Qt.lighter(Parameters.cashGreen, 1.45)
                                                        }
                                                    }

                                                    property var badGradient: Gradient {
                                                        orientation: Gradient.Horizontal
                                                        GradientStop {
                                                            position: 0.0
                                                            color: Qt.lighter(Parameters.lowCashRed, 1.35)
                                                        }
                                                        GradientStop {
                                                            position: 0.4
                                                            color: Qt.lighter(Parameters.lowCashRed, 1.55)
                                                        }
                                                        GradientStop {
                                                            position: 0.85
                                                            color: Qt.lighter(Parameters.lowCashRed, 1.45)
                                                        }
                                                    }

                                                    gradient: containerRect.lowItems == 0 ? goodGradient : badGradient

                                                    RowLayout {
                                                        id: stockWarnLayout
                                                        anchors.fill: parent
                                                        anchors.leftMargin: 4
                                                        anchors.rightMargin: 4
                                                        implicitWidth: parent.width - 8
                                                        implicitHeight: parent.height

                                                        /*Item {
                                                            Layout.fillWidth: true
                                                        }*/

                                                        Text {
                                                            id: stockWarn1
                                                            //Layout.alignment: Qt.AlignVCenter
                                                            Layout.fillWidth: true
                                                            //font.pixelSize: stockFillContainer.width * 0.032
                                                            font.pixelSize: 17
                                                            fontSizeMode: Text.Fit
                                                            Layout.maximumWidth: stockFillContainer.width * 0.3
                                                            Layout.maximumHeight: stockFillContainer.height * 0.85
                                                            minimumPixelSize: 5
                                                            text: ""
                                                            font.family: Parameters.iconFont
                                                            color: "#000000"
                                                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                                            verticalAlignment: Text.AlignVCenter
                                                            horizontalAlignment: Text.AlignHCenter
                                                        }

                                                        Text {
                                                            id: stockWarn2
                                                            //Layout.alignment: Qt.AlignVCenter
                                                            Layout.fillWidth: true
                                                            //font.pixelSize: stockFillContainer.width * 0.027
                                                            font.pixelSize: 16
                                                            fontSizeMode: Text.Fit
                                                            Layout.maximumWidth: stockFillContainer.width * 0.8
                                                            Layout.minimumWidth: stockFillContainer.width * 0.2
                                                            Layout.maximumHeight: stockFillContainer.height * 0.85
                                                            minimumPixelSize: 8
                                                            text: containerRect.lowItems + " itens precisam de reposição"
                                                            font.family: Parameters.defaultFont
                                                            //Layout.maximumWidth: lowQuantityDisplayContainer.width
                                                            elide: Text.ElideRight
                                                            color: "#000000"
                                                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                                            verticalAlignment: Text.AlignVCenter
                                                            horizontalAlignment: Text.AlignHCenter
                                                        }

                                                        /*Item {
                                                            Layout.fillWidth: true
                                                        }*/
                                                    }

                                                    /*RowLayout {
                                                        anchors.fill: parent
                                                        anchors.topMargin: -parent.height * 0.03

                                                        Item {
                                                            Layout.fillWidth: true
                                                        }

                                                        Text {
                                                            Layout.alignment: Qt.AlignVCenter
                                                            Layout.fillWidth: false
                                                            font.pixelSize: lowQuantityDisplayContainer.width * 0.08
                                                            fontSizeMode: Text.Fit
                                                            minimumPixelSize: 7
                                                            text: ""
                                                            font.family: Parameters.iconFont
                                                            color: "#000000"
                                                        }

                                                        Text {
                                                            Layout.alignment: Qt.AlignVCenter
                                                            Layout.fillWidth: false
                                                            font.pixelSize: lowQuantityDisplayContainer.width * 0.07
                                                            fontSizeMode: Text.Fit
                                                            minimumPixelSize: 6
                                                            text: stock_model.getLowQuantityTotal(containerRect.lowItemThreshold) + " itens precisam de reposição"
                                                            font.family: Parameters.defaultFont
                                                            Layout.maximumWidth: lowQuantityDisplayContainer.width * 0.65
                                                            elide: Text.ElideRight
                                                            color: "#000000"
                                                        }

                                                        Item {
                                                            Layout.fillWidth: true
                                                        }
                                                    }*/
                                                }

                                                Item {
                                                    Layout.horizontalStretchFactor: 1
                                                    Layout.fillWidth: true
                                                    Layout.maximumWidth: stockFillContainer.width * 0.08
                                                    Layout.minimumWidth: 3
                                                    Layout.preferredWidth: 4
                                                }
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                Layout.leftMargin: stockFillContainer.width * 0.08
                                                Layout.rightMargin: stockFillContainer.width * 0.08
                                                spacing: stockFillContainer.width * 0.027

                                                Rectangle {
                                                    id: stockFillGraphList
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: false
                                                    Layout.preferredWidth: stockFillContainer.width / 3.5
                                                    radius: Parameters.defaultRadius
                                                    color: "white"
                                                    border.width: 1
                                                    border.color: Parameters.lightBorder
                                                    clip: true

                                                    ListView {
                                                        id: stockFillList
                                                        /*anchors {
                                                            left: parent.left
                                                            leftMargin: Math.max(2, parent.width * 0.03)
                                                            right: parent.right
                                                            rightMargin: Math.max(2, parent.width * 0.03)
                                                            verticalCenter: parent.verticalCenter
                                                        }
                                                        height: Math.min((parent.height - Math.max(2, parent.height * 0.04)), count * stockFillGraphList.height * 0.13)
                                                        width: parent.width*/
                                                        anchors.fill: parent
                                                        anchors.leftMargin: Math.max(2, parent.width * 0.03)
                                                        anchors.rightMargin: Math.max(2, parent.width * 0.03)
                                                        anchors.topMargin: Math.max(4, parent.height * 0.022)
                                                        anchors.bottomMargin: Math.max(4, parent.height * 0.022)
                                                        orientation: ListView.Vertical
                                                        boundsBehavior: ListView.StopAtBounds

                                                        model: Math.min(containerRect.productsCount, 10)

                                                        delegate: Rectangle {
                                                            required property int index
                                                            anchors.left: parent.left
                                                            anchors.right: parent.right
                                                            height: stockFillGraphList.height * 0.15
                                                            color: "transparent"

                                                            RowLayout {
                                                                anchors.fill: parent
                                                                anchors.leftMargin: 1
                                                                anchors.rightMargin: 1

                                                                Rectangle {
                                                                    id: fillColorBallDelegate
                                                                    Layout.fillHeight: false
                                                                    Layout.fillWidth: false
                                                                    Layout.alignment: Qt.AlignVCenter
                                                                    Layout.preferredHeight: (stockFillGraphList.width + 0.3 * stockFillGraphList.height) * 0.055
                                                                    Layout.preferredWidth: height
                                                                    radius: height / 2
                                                                    color: firstTab.graphColors[index]
                                                                }

                                                                Text {
                                                                    Layout.fillWidth: true
                                                                    Layout.fillHeight: false
                                                                    Layout.alignment: Qt.AlignVCenter
                                                                    font.family: Parameters.defaultFont
                                                                    font.styleName: "Medium"
                                                                    font.pixelSize: (stockFillGraphList.width + 0.3 * stockFillGraphList.height) * 0.08
                                                                    color: "#000000"
                                                                    //renderType: Text.CurveRendering
                                                                    elide: Text.ElideRight
                                                                    text: stock_model.getSortedByStockQuantity(index, containerRect.lowItemThreshold).name
                                                                }
                                                            }
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    id: stockFillGraph
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    Layout.maximumHeight: width
                                                    radius: Parameters.defaultRadius
                                                    border.width: 1
                                                    border.color: Parameters.lightBorder

                                                    GraphsView {
                                                        id: stockFillChart
                                                        anchors.centerIn: parent
                                                        antialiasing: true
                                                        width: parent.width * 1.22
                                                        height: width
                                                        shadowVisible: true
                                                        theme: GraphsTheme {
                                                            labelTextColor: "#000000"
                                                            backgroundColor: "transparent"
                                                            labelBackgroundVisible: true
                                                            labelFont.family: Parameters.defaultFont
                                                            labelFont.styleName: "Medium"
                                                            labelFont.pointSize: stockFillChart.width * 0.22
                                                            labelBorderVisible: true
                                                            labelsVisible: true
                                                        }

                                                        PieSeries {
                                                            id: stockPieSeries
                                                        }

                                                        function regenGraph() {
                                                            stockPieSeries.clear();
                                                            for (var i = 0; i < containerRect.productsCount; i++) {
                                                                var number = stock_model.getSortedByStockQuantity(i, containerRect.lowItemThreshold).percentage;
                                                                var slice = stockPieSeries.append(stock_model.getSortedByStockQuantity(i, containerRect.lowItemThreshold).percentage + "%", stock_model.getSortedByStockQuantity(i, containerRect.lowItemThreshold).percentage);
                                                                slice.borderWidth = 0;
                                                                slice.color = firstTab.graphColors[i];
                                                                slice.label = stock_model.getSortedByStockQuantity(i, containerRect.lowItemThreshold).percentage + "%";
                                                                if (number >= 10) {
                                                                    slice.labelVisible = true;
                                                                    slice.labelPosition = PieSlice.LabelPosition.InsideHorizontal;
                                                                }// else {
                                                                // slice.labelPosition = PieSlice.LabelPosition.Outside;
                                                                //slice.labelArmLengthFactor = 0.07;
                                                                //}
                                                            }
                                                        }
                                                        Component.onCompleted: regenGraph()
                                                    }
                                                }
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: false
                                                Layout.preferredHeight: stockFillContainer.height * 0.15
                                                Layout.bottomMargin: stockFillContainer.height * 0.05
                                                Layout.leftMargin: stockFillContainer.width * 0.08
                                                Layout.rightMargin: stockFillContainer.width * 0.08

                                                Rectangle {
                                                    Layout.alignment: Qt.AlignVCenter
                                                    Layout.fillHeight: false
                                                    Layout.preferredHeight: stockFillContainer.height * 0.12
                                                    Layout.fillWidth: false
                                                    Layout.preferredWidth: height
                                                    radius: height / 2
                                                    color: '#0ac0e4'

                                                    Text {
                                                        anchors.centerIn: parent
                                                        font.family: Parameters.iconFont
                                                        font.pixelSize: stockFillContainer.height * 0.08
                                                        text: ""
                                                        color: "#000000"
                                                    }
                                                }

                                                ColumnLayout {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true

                                                    Text {
                                                        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                                                        font.family: Parameters.defaultFont
                                                        font.pixelSize: stockFillContainer.width * 0.036
                                                        text: "Total de produtos:"
                                                        color: "#000000"
                                                    }

                                                    Text {
                                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                        font.family: Parameters.defaultFont
                                                        font.styleName: "Medium"
                                                        font.pixelSize: stockFillContainer.width * 0.05
                                                        text: stock_model.getTotalQuant()
                                                        color: "#000000"
                                                    }
                                                }

                                                Item {
                                                    Layout.preferredWidth: 3
                                                }

                                                Rectangle {
                                                    Layout.preferredWidth: 1
                                                    Layout.fillHeight: true
                                                    Layout.topMargin: 1
                                                    Layout.bottomMargin: 1
                                                    radius: 1
                                                    color: "#454545"
                                                }

                                                Item {
                                                    Layout.preferredWidth: 2
                                                }

                                                ColumnLayout {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: true

                                                    Text {
                                                        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                                                        font.family: Parameters.defaultFont
                                                        font.pixelSize: stockFillContainer.width * 0.036
                                                        text: "Tipos de produtos:"
                                                        color: "#000000"
                                                    }

                                                    Text {
                                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                        font.family: Parameters.defaultFont
                                                        font.styleName: "Medium"
                                                        font.pixelSize: stockFillContainer.width * 0.05
                                                        text: containerRect.productsCount
                                                        color: "#000000"
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    MultiEffect {
                                        anchors.fill: stockFillContainer
                                        source: stockFillContainer

                                        autoPaddingEnabled: true
                                        shadowEnabled: true
                                        shadowOpacity: 0.8
                                        shadowScale: 0.99
                                        shadowVerticalOffset: 4
                                        shadowColor: "#000000"
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.rowSpan: 2
                                    Layout.columnSpan: 2

                                    MultiEffect {
                                        anchors.fill: financeSummary
                                        source: financeSummary

                                        autoPaddingEnabled: true
                                        shadowEnabled: true
                                        shadowOpacity: 0.75
                                        shadowScale: 0.99
                                        shadowVerticalOffset: 4
                                        shadowColor: "#000000"
                                    }

                                    Rectangle {
                                        id: financeSummary
                                        anchors.fill: parent
                                        radius: Parameters.defaultRadius

                                        color: Parameters.shadeBgColor

                                        function regenSummary() {
                                            totalSellText.text = "Receita Total: R$" + stock_model.getTotalStockSell().toFixed(2).toString().replace(".", ",");
                                            totalCostText.text = "Custo Total: R$" + stock_model.getTotalStockCost().toFixed(2).toString().replace(".", ",");
                                        }

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.topMargin: parent.height * 0.05
                                            anchors.bottomMargin: parent.height * 0.05
                                            anchors.leftMargin: parent.width * 0.05
                                            anchors.rightMargin: parent.width * 0.05

                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                font.family: Parameters.defaultFont
                                                font.styleName: "Medium"
                                                font.pixelSize: financeSummary.width * 0.055
                                                text: "Resumo Financeiro"
                                                color: "#000000"
                                                fontSizeMode: Text.Fit
                                                minimumPixelSize: 10
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: false
                                                Layout.preferredHeight: financeSummary.height * 0.06
                                            }

                                            Rectangle {
                                                Layout.alignment: Qt.AlignHCenter
                                                radius: Parameters.defaultRadius * 2
                                                Layout.fillWidth: true
                                                Layout.fillHeight: false
                                                Layout.preferredHeight: financeSummary.height * 0.18

                                                gradient: Gradient {
                                                    orientation: Gradient.Horizontal
                                                    GradientStop {
                                                        position: 0.0
                                                        color: Qt.darker(Parameters.highlightFg, 1.07)
                                                    }
                                                    GradientStop {
                                                        position: 0.4
                                                        color: Qt.lighter(Parameters.shadeHighlightFg, 1.35)
                                                    }
                                                    GradientStop {
                                                        position: 0.85
                                                        color: Qt.lighter(Parameters.shadeHighlightFg, 1.55)
                                                    }
                                                }

                                                Text {
                                                    id: totalSellText
                                                    anchors.centerIn: parent
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Medium"
                                                    font.pixelSize: parent.height * 0.33
                                                    text: ("Receita Total: R$" + stock_model.getTotalStockSell().toFixed(2).toString().replace(".", ",")) || "Zero itens detectados"
                                                    fontSizeMode: Text.Fit
                                                    minimumPixelSize: 8
                                                }
                                            }

                                            Rectangle {
                                                Layout.alignment: Qt.AlignHCenter
                                                radius: Parameters.defaultRadius * 2
                                                Layout.fillWidth: true
                                                Layout.fillHeight: false
                                                Layout.preferredHeight: financeSummary.height * 0.18

                                                gradient: Gradient {
                                                    orientation: Gradient.Horizontal
                                                    GradientStop {
                                                        position: 0.0
                                                        color: Qt.lighter(Parameters.hoveredButtonBg, 1.85)
                                                    }
                                                    GradientStop {
                                                        position: 0.35
                                                        color: Qt.lighter(Parameters.hoveredButtonBg, 2)
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: Qt.lighter(Parameters.hoveredButtonBg, 2.15)
                                                    }
                                                }

                                                Text {
                                                    id: totalCostText
                                                    anchors.centerIn: parent
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Medium"
                                                    font.pixelSize: parent.height * 0.33
                                                    text: ("Custo Total: R$" + stock_model.getTotalStockCost().toFixed(2).toString().replace(".", ",")) || "Zero itens detectados"
                                                    fontSizeMode: Text.Fit
                                                    minimumPixelSize: 8
                                                }
                                            }
                                        }
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.rowSpan: 2
                                    Layout.columnSpan: 2

                                    MultiEffect {
                                        anchors.fill: biggestIndProfits
                                        source: biggestIndProfits

                                        autoPaddingEnabled: true
                                        shadowEnabled: true
                                        shadowOpacity: 0.75
                                        shadowScale: 0.99
                                        shadowVerticalOffset: 4
                                        shadowColor: "#000000"
                                    }

                                    Rectangle {
                                        id: biggestIndProfits
                                        anchors.fill: parent
                                        radius: Parameters.defaultRadius

                                        color: Parameters.shadeBgColor

                                        property string highestName1
                                        property string highestProfit1
                                        property string highestName2
                                        property string highestProfit2

                                        function updateHighProfits() {
                                            highestName1 = stock_model.getMostIndividualProfit().topOneName;
                                            highestProfit1 = stock_model.getMostIndividualProfit().topOneProf.toFixed(2).toString().replace(".", ",");
                                            highestName2 = stock_model.getMostIndividualProfit().topTwoName;
                                            highestProfit2 = stock_model.getMostIndividualProfit().topTwoProf.toFixed(2).toString().replace(".", ",");
                                        }

                                        Component.onCompleted: updateHighProfits()

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.topMargin: parent.height * 0.05
                                            anchors.bottomMargin: parent.height * 0.05
                                            anchors.leftMargin: parent.width * 0.05
                                            anchors.rightMargin: parent.width * 0.05

                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                font.family: Parameters.defaultFont
                                                font.styleName: "Medium"
                                                font.pixelSize: biggestIndProfits.width * 0.05
                                                fontSizeMode: Text.Fit
                                                minimumPixelSize: 10
                                                text: "Maiores lucros potenciais individuais"
                                                color: "#000000"
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: false
                                                Layout.preferredHeight: biggestIndProfits.height * 0.06
                                            }

                                            Rectangle {
                                                Layout.alignment: Qt.AlignHCenter
                                                radius: Parameters.defaultRadius * 2
                                                Layout.fillWidth: true
                                                Layout.fillHeight: false
                                                Layout.preferredHeight: biggestIndProfits.height * 0.18

                                                gradient: Gradient {
                                                    orientation: Gradient.Horizontal
                                                    GradientStop {
                                                        position: 0.0
                                                        color: Parameters.cashGreen
                                                    }
                                                    GradientStop {
                                                        position: 0.4
                                                        color: Qt.lighter(Parameters.cashGreen, 1.35)
                                                    }
                                                    GradientStop {
                                                        position: 0.85
                                                        color: Qt.lighter(Parameters.cashGreen, 1.55)
                                                    }
                                                }

                                                Text {
                                                    anchors.centerIn: parent
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Medium"
                                                    font.pixelSize: parent.height * 0.33
                                                    text: {
                                                        if (biggestIndProfits.highestName1 && biggestIndProfits.highestProfit1) {
                                                            return biggestIndProfits.highestName1 + ": R$" + biggestIndProfits.highestProfit1;
                                                        } else {
                                                            return "Necessário 3 itens para determinar";
                                                        }
                                                    }
                                                    fontSizeMode: Text.Fit
                                                    minimumPixelSize: 8
                                                }
                                            }

                                            Rectangle {
                                                Layout.alignment: Qt.AlignHCenter
                                                radius: Parameters.defaultRadius * 2
                                                Layout.fillWidth: true
                                                Layout.fillHeight: false
                                                Layout.preferredHeight: biggestIndProfits.height * 0.18

                                                gradient: Gradient {
                                                    orientation: Gradient.Horizontal
                                                    GradientStop {
                                                        position: 0.0
                                                        color: Parameters.cashCyan
                                                    }
                                                    GradientStop {
                                                        position: 0.35
                                                        color: Qt.lighter(Parameters.cashCyan, 1.35)
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: Qt.lighter(Parameters.cashCyan, 1.55)
                                                    }
                                                }

                                                Text {
                                                    anchors.centerIn: parent
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Medium"
                                                    font.pixelSize: parent.height * 0.33
                                                    text: {
                                                        if (biggestIndProfits.highestName2 && biggestIndProfits.highestProfit2) {
                                                            return biggestIndProfits.highestName2 + ": R$" + biggestIndProfits.highestProfit2;
                                                        } else {
                                                            return "Necessário 3 itens para determinar";
                                                        }
                                                    }
                                                    fontSizeMode: Text.Fit
                                                    minimumPixelSize: 8
                                                }
                                            }
                                        }
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.rowSpan: 2
                                    Layout.columnSpan: 2

                                    MultiEffect {
                                        anchors.fill: smallestIndProfits
                                        source: smallestIndProfits

                                        autoPaddingEnabled: true
                                        shadowEnabled: true
                                        shadowOpacity: 0.75
                                        shadowScale: 0.99
                                        shadowVerticalOffset: 4
                                        shadowColor: "#000000"
                                    }

                                    Rectangle {
                                        id: smallestIndProfits
                                        anchors.fill: parent
                                        radius: Parameters.defaultRadius

                                        color: Parameters.shadeBgColor

                                        property string lowestName1
                                        property string lowestProfit1
                                        property string lowestName2
                                        property string lowestProfit2

                                        function updateLowProfits() {
                                            lowestName1 = stock_model.getLeastIndividualProfit().topOneName;
                                            lowestProfit1 = stock_model.getLeastIndividualProfit().topOneProf.toFixed(2).toString().replace(".", ",");
                                            lowestName2 = stock_model.getLeastIndividualProfit().topTwoName;
                                            lowestProfit2 = stock_model.getLeastIndividualProfit().topTwoProf.toFixed(2).toString().replace(".", ",");
                                        }

                                        Component.onCompleted: updateLowProfits()

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.topMargin: parent.height * 0.05
                                            anchors.bottomMargin: parent.height * 0.05
                                            anchors.leftMargin: parent.width * 0.05
                                            anchors.rightMargin: parent.width * 0.05

                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                font.family: Parameters.defaultFont
                                                font.styleName: "Medium"
                                                font.pixelSize: biggestIndProfits.width * 0.05
                                                text: "Menores lucros potenciais individuais"
                                                color: "#000000"
                                                fontSizeMode: Text.Fit
                                                minimumPixelSize: 10
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: false
                                                Layout.preferredHeight: smallestIndProfits.height * 0.06
                                            }

                                            Rectangle {
                                                Layout.alignment: Qt.AlignHCenter
                                                radius: Parameters.defaultRadius * 2
                                                Layout.fillWidth: true
                                                Layout.fillHeight: false
                                                Layout.preferredHeight: smallestIndProfits.height * 0.18

                                                gradient: Gradient {
                                                    orientation: Gradient.Horizontal
                                                    GradientStop {
                                                        position: 0.0
                                                        color: Parameters.lowCashRed
                                                    }
                                                    GradientStop {
                                                        position: 0.4
                                                        color: Qt.lighter(Parameters.lowCashRed, 1.35)
                                                    }
                                                    GradientStop {
                                                        position: 0.85
                                                        color: Qt.lighter(Parameters.lowCashRed, 1.55)
                                                    }
                                                }

                                                Text {
                                                    anchors.centerIn: parent
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Medium"
                                                    font.pixelSize: parent.height * 0.33
                                                    text: {
                                                        if (smallestIndProfits.lowestName1 && smallestIndProfits.lowestProfit1) {
                                                            return smallestIndProfits.lowestName1 + ": R$" + smallestIndProfits.lowestProfit1;
                                                        } else {
                                                            return "Necessário 3 itens para determinar";
                                                        }
                                                    }
                                                    fontSizeMode: Text.Fit
                                                    minimumPixelSize: 8
                                                }
                                            }

                                            Rectangle {
                                                Layout.alignment: Qt.AlignHCenter
                                                radius: Parameters.defaultRadius * 2
                                                Layout.fillWidth: true
                                                Layout.fillHeight: false
                                                Layout.preferredHeight: smallestIndProfits.height * 0.18

                                                gradient: Gradient {
                                                    orientation: Gradient.Horizontal
                                                    GradientStop {
                                                        position: 0.0
                                                        color: Parameters.lowCashPink
                                                    }
                                                    GradientStop {
                                                        position: 0.35
                                                        color: Qt.lighter(Parameters.lowCashPink, 1.35)
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: Qt.lighter(Parameters.lowCashPink, 1.55)
                                                    }
                                                }

                                                Text {
                                                    anchors.centerIn: parent
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Medium"
                                                    font.pixelSize: parent.height * 0.33
                                                    text: {
                                                        if (smallestIndProfits.lowestName2 && smallestIndProfits.lowestProfit2) {
                                                            return smallestIndProfits.lowestName2 + ": R$" + smallestIndProfits.lowestProfit2;
                                                        } else {
                                                            return "Necessário 3 itens para determinar";
                                                        }
                                                    }
                                                    fontSizeMode: Text.Fit
                                                    minimumPixelSize: 8
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: secondTab
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    gradient: Parameters.whiteBgGradient

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.topMargin: 40
                        anchors.bottomMargin: 25
                        spacing: 0

                        RowLayout {
                            //anchors.horizontalCenter: parent.horizontalCenter
                            Layout.alignment: Qt.AlignVCenter

                            Item {
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                radius: 30
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                border.width: 2
                                border.color: Parameters.highlightFg
                                Layout.fillWidth: false
                                //Layout.preferredWidth: 540
                                Layout.preferredWidth: secondTab.width * 0.3
                                Layout.preferredHeight: 52
                                color: "#101a72"

                                Rectangle {
                                    id: searchContainer
                                    anchors.centerIn: parent
                                    color: Parameters.shadeBgColor
                                    radius: Parameters.defaultRadius * 2
                                    implicitHeight: 32
                                    implicitWidth: 0.965 * parent.width

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 4

                                        TextField {
                                            id: searchField
                                            /* | Qt.AlignLeft



                                                Layout.topMargin: 4
                                                Layout.bottomMargin: 0*/

                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                            Layout.leftMargin: 2
                                            //anchors.verticalCenter: parent.verticalCenter
                                            Layout.preferredHeight: 32

                                            background: Rectangle {
                                                color: "transparent"
                                                //Layout.alignment: Qt.AlignVCenter
                                                Layout.preferredHeight: 32
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
                                                containerRect.search = searchField.text;
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

                                            visible: (containerRect.search != "")
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            enabled: true
                                            onClicked: {
                                                containerRect.search = "";
                                                searchField.clear();
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
                                    containerRect.search = searchField.text;
                                }

                                contentItem: Text {
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: Parameters.defaultFont
                                    font.styleName: "Medium"
                                    font.pointSize: 12
                                    text: searchSubmit.text
                                    color: '#f0f0f0'
                                }

                                background: Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    implicitWidth: 84
                                    implicitHeight: 38
                                    radius: Parameters.defaultRadius * 2
                                    color: searchSubmit.down ? Parameters.pressedButtonBg : searchSubmit.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                    border.width: 1
                                    border.color: Parameters.highlightFg
                                }

                                HoverHandler {
                                    enabled: parent.visible
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }

                        Item {
                            Layout.preferredHeight: 25
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            spacing: 8
                            Layout.leftMargin: 66
                            Layout.rightMargin: 66

                            Text {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignBottom
                                Layout.bottomMargin: 4
                                text: {
                                    if (containerRect.search != "") {
                                        return "Mostrando resultados para a pesquisa " + "\"" + containerRect.search + "\"" + ":";
                                    } else {
                                        return "Mostrando todos os itens:";
                                    }
                                }
                                font.family: Parameters.defaultFont
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
                                    newItemDialog.open();
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
                            border.color: Parameters.shadeHighlightBg
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
                                    Layout.preferredHeight: 40
                                    color: "transparent"

                                    RowLayout {
                                        id: initColumn
                                        anchors.fill: parent
                                        Layout.leftMargin: 0
                                        Layout.rightMargin: 0
                                        spacing: 0
                                        uniformCellSizes: false
                                        property int initCFontSize: parent.width * 0.007 + 9

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
                                                font.styleName: "Medium"
                                                font.pixelSize: initColumn.initCFontSize
                                                fontSizeMode: Text.Fit
                                                minimumPixelSize: 8
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
                                                font.styleName: "Medium"
                                                font.pixelSize: initColumn.initCFontSize
                                                fontSizeMode: Text.Fit
                                                minimumPixelSize: 8
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
                                                font.styleName: "Medium"
                                                font.pixelSize: initColumn.initCFontSize
                                                fontSizeMode: Text.Fit
                                                minimumPixelSize: 8
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
                                                font.styleName: "Medium"
                                                font.pixelSize: initColumn.initCFontSize
                                                fontSizeMode: Text.Fit
                                                minimumPixelSize: 8
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
                                                font.styleName: "Medium"
                                                font.pixelSize: initColumn.initCFontSize
                                                fontSizeMode: Text.Fit
                                                minimumPixelSize: 8
                                                text: "Lucro (Por Unidade)"
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    //anchors.top: initCContainer.bottom
                                    //anchors.topMargin: -6
                                    Layout.topMargin: -6
                                    Layout.bottomMargin: 0
                                    Layout.leftMargin: 0
                                    Layout.rightMargin: 0
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: "transparent"
                                    //Layout.margins: 0

                                    ListView {
                                        id: listView
                                        anchors.fill: parent
                                        orientation: ListView.Vertical
                                        boundsBehavior: ListView.StopAtBounds

                                        delegate: ProductLister {
                                            id: delegate
                                            sModel: containerRect.sModel
                                            searchTerm: containerRect.search
                                        }

                                        model: stock_model.getEffectiveCount(containerRect.search)

                                        ScrollBar.vertical: ScrollBar {}
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: thirdTab
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    gradient: Parameters.whiteBgGradient

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.topMargin: parent.height * 0.05
                        anchors.bottomMargin: parent.height * 0.05
                        anchors.leftMargin: parent.width * 0.05
                        anchors.rightMargin: parent.width * 0.05
                        spacing: parent.height * 0.025

                        GridLayout {
                            Layout.alignment: Qt.AlignTop
                            Layout.fillWidth: true
                            Layout.fillHeight: false
                            columns: 3
                            rows: 2

                            Text {
                                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                                font.family: Parameters.defaultFont
                                font.styleName: "Bold"
                                text: "Usuários"
                                font.pixelSize: 22
                                color: "#000000"
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                id: newUserButton
                                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                                //Layout.preferredWidth: newUserBIcon.contentWidth + newUserBText.contentWidth + 18
                                Layout.preferredWidth: newUserBLayout.implicitWidth + 12
                                Layout.preferredHeight: containerRect.globalScaleHeight / 13
                                radius: width / 1.7

                                property var bgGradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop {
                                        position: 0.0
                                        color: Parameters.highlightFg
                                    }
                                    GradientStop {
                                        position: 0.5
                                        color: Qt.lighter(Parameters.shadeHighlightFg, 1.35)
                                    }
                                    GradientStop {
                                        position: 0.85
                                        color: Parameters.highlightFg
                                    }
                                }

                                gradient: bgGradient

                                color: Parameters.highlightFg

                                RowLayout {
                                    id: newUserBLayout
                                    anchors.fill: parent
                                    spacing: 0

                                    Item {
                                        Layout.preferredWidth: 8
                                    }

                                    Text {
                                        id: newUserBIcon
                                        font.family: Parameters.iconFontBold
                                        font.styleName: "Bold"
                                        font.pixelSize: 22
                                        text: ""
                                        color: "#ffffff"
                                        fontSizeMode: Text.Fit
                                        minimumPixelSize: 12
                                        horizontalAlignment: Text.AlignLeft
                                        verticalAlignment: Text.AlignVCenter
                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                        width: newUserButton.height - 4
                                    }

                                    Text {
                                        id: newUserBText
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Medium"
                                        font.pixelSize: 20
                                        text: "Novo Usuário"
                                        color: "#ffffff"
                                        fontSizeMode: Text.Fit
                                        minimumPixelSize: 12
                                        horizontalAlignment: Text.AlignRight
                                        verticalAlignment: Text.AlignVCenter
                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                                        width: containerRect.globalScaleWidth / 34
                                        Component.onCompleted: console.log(width, containerRect.globalScaleWidth / 28, containerRect.globalScaleWidth)
                                    }

                                    Item {
                                        Layout.preferredWidth: 8
                                    }
                                }

                                MouseArea {
                                    id: newUserPointHandler
                                    anchors.fill: newUserButton
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true

                                    onEntered: {
                                        newUserButton.gradient = null;
                                        newUserButton.color = Parameters.shadeHighlightFg;
                                    }

                                    onExited: {
                                        newUserButton.color = null;
                                        newUserButton.gradient = newUserButton.bgGradient;
                                    }

                                    onClicked: {
                                        userLevelCombo.displayText = "Cargo";
                                        newUserDialog.open();
                                    }
                                }
                            }

                            Text {
                                Layout.columnSpan: 3
                                Layout.alignment: Qt.AlignLeft
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                text: "Gerencie os acessos e permissões dos usuários do sistema."
                                font.pixelSize: 16
                                color: "#222222"
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                            Layout.fillHeight: false

                            spacing: thirdTab.width / 28

                            Rectangle {
                                id: userRect1
                                Layout.alignment: Qt.AlignTop
                                Layout.preferredWidth: thirdTab.width * 23 / 112 - thirdTab.width * 0.025
                                Layout.preferredHeight: thirdTab.height / 10

                                radius: Parameters.defaultRadius / 2

                                gradient: Parameters.whiteButtonGradient
                                border.width: 1
                                border.color: "#cacaca"

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.topMargin: parent.height * 0.1
                                    anchors.bottomMargin: parent.height * 0.1
                                    anchors.leftMargin: parent.width * 0.1
                                    anchors.rightMargin: parent.width * 0.1
                                    rows: 2
                                    columns: 2

                                    Rectangle {
                                        Layout.rowSpan: 2
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                        implicitHeight: userRect1.width * 0.18
                                        implicitWidth: implicitHeight
                                        radius: implicitHeight / 2
                                        color: '#0e6d45'

                                        Text {
                                            anchors.centerIn: parent
                                            font.family: Parameters.iconFontFilled
                                            font.pixelSize: parent.implicitHeight * 0.6
                                            text: ""
                                            color: Parameters.mainBgColor
                                        }
                                    }

                                    Text {
                                        Layout.rowSpan: 1
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Medium"
                                        font.pixelSize: (userRect1.width * 0.12 + userRect1.height * 0.12) / 2
                                        text: "Total de Usuários"
                                        color: "#000000"
                                    }

                                    Text {
                                        Layout.rowSpan: 1
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Bold"
                                        font.pixelSize: (userRect1.width * 0.14 + userRect1.height * 0.14) / 2
                                        text: containerRect.usersCount
                                        color: "#000000"
                                    }
                                }
                            }

                            Rectangle {
                                id: userRect2
                                Layout.alignment: Qt.AlignTop
                                Layout.preferredWidth: thirdTab.width * 23 / 112 - thirdTab.width * 0.025
                                Layout.preferredHeight: thirdTab.height / 10

                                radius: Parameters.defaultRadius / 2

                                gradient: Parameters.whiteButtonGradient
                                border.width: 1
                                border.color: "#cacaca"

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.topMargin: parent.height * 0.1
                                    anchors.bottomMargin: parent.height * 0.1
                                    anchors.leftMargin: parent.width * 0.1
                                    anchors.rightMargin: parent.width * 0.1
                                    rows: 2
                                    columns: 2

                                    Rectangle {
                                        Layout.rowSpan: 2
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                        implicitHeight: userRect2.width * 0.18
                                        implicitWidth: implicitHeight
                                        radius: implicitHeight / 2
                                        color: '#b93413'

                                        Text {
                                            anchors.centerIn: parent
                                            font.family: Parameters.iconFontFilled
                                            font.pixelSize: parent.implicitHeight * 0.6
                                            text: ""
                                            color: Parameters.mainBgColor
                                        }
                                    }

                                    Text {
                                        Layout.rowSpan: 1
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Medium"
                                        font.pixelSize: (userRect2.width * 0.12 + userRect2.height * 0.12) / 2
                                        text: "Supervisão"
                                        color: "#000000"
                                    }

                                    Text {
                                        Layout.rowSpan: 1
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Bold"
                                        font.pixelSize: (userRect2.width * 0.14 + userRect2.height * 0.14) / 2
                                        text: containerRect.uModel.getEffectiveCount("", "Supervisão")
                                        color: "#000000"
                                    }
                                }
                            }

                            Rectangle {
                                id: userRect3
                                Layout.alignment: Qt.AlignTop
                                Layout.preferredWidth: thirdTab.width * 23 / 112 - thirdTab.width * 0.025
                                Layout.preferredHeight: thirdTab.height / 10

                                radius: Parameters.defaultRadius / 2

                                gradient: Parameters.whiteButtonGradient
                                border.width: 1
                                border.color: "#cacaca"

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.topMargin: parent.height * 0.1
                                    anchors.bottomMargin: parent.height * 0.1
                                    anchors.leftMargin: parent.width * 0.1
                                    anchors.rightMargin: parent.width * 0.1
                                    rows: 2
                                    columns: 2

                                    Rectangle {
                                        Layout.rowSpan: 2
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                        implicitHeight: userRect3.width * 0.18
                                        implicitWidth: implicitHeight
                                        radius: implicitHeight / 2
                                        color: '#3d419c'

                                        Text {
                                            anchors.centerIn: parent
                                            font.family: Parameters.iconFontFilled
                                            font.pixelSize: parent.implicitHeight * 0.6
                                            text: ""
                                            color: Parameters.mainBgColor
                                        }
                                    }

                                    Text {
                                        Layout.rowSpan: 1
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Medium"
                                        font.pixelSize: (userRect3.width * 0.12 + userRect3.height * 0.12) / 2
                                        text: "Estoque"
                                        color: "#000000"
                                    }

                                    Text {
                                        Layout.rowSpan: 1
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Bold"
                                        font.pixelSize: (userRect3.width * 0.14 + userRect3.height * 0.14) / 2
                                        text: containerRect.uModel.getEffectiveCount("", "Estoque")
                                        color: "#000000"
                                    }
                                }
                            }

                            Rectangle {
                                id: userRect4
                                Layout.alignment: Qt.AlignTop
                                Layout.preferredWidth: thirdTab.width * 23 / 112 - thirdTab.width * 0.025
                                Layout.preferredHeight: thirdTab.height / 10

                                radius: Parameters.defaultRadius / 2

                                gradient: Parameters.whiteButtonGradient
                                border.width: 1
                                border.color: "#cacaca"

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.topMargin: parent.height * 0.1
                                    anchors.bottomMargin: parent.height * 0.1
                                    anchors.leftMargin: parent.width * 0.1
                                    anchors.rightMargin: parent.width * 0.1
                                    rows: 2
                                    columns: 2

                                    Rectangle {
                                        Layout.rowSpan: 2
                                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                        implicitHeight: userRect4.width * 0.18
                                        implicitWidth: implicitHeight
                                        radius: implicitHeight / 2
                                        color: '#f9af26'

                                        Text {
                                            anchors.centerIn: parent
                                            font.family: Parameters.iconFontFilled
                                            font.pixelSize: parent.implicitHeight * 0.6
                                            text: ""
                                            color: Parameters.mainBgColor
                                        }
                                    }

                                    Text {
                                        Layout.rowSpan: 1
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Medium"
                                        font.pixelSize: (userRect4.width * 0.12 + userRect4.height * 0.12) / 2
                                        text: "Financeiro"
                                        color: "#000000"
                                    }

                                    Text {
                                        Layout.rowSpan: 1
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Bold"
                                        font.pixelSize: (userRect4.width * 0.14 + userRect4.height * 0.14) / 2
                                        text: containerRect.uModel.getEffectiveCount("", "Financeiro")
                                        color: "#000000"
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: tableBg
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            gradient: Gradient {
                                GradientStop {
                                    color: "#f2f2f2"
                                    position: 0.0
                                }
                                GradientStop {
                                    color: "#fefefe"
                                    position: 0.4
                                }
                            }

                            radius: Parameters.defaultRadius

                            Rectangle {
                                id: topTableRect
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                }
                                height: parent.height * 0.085
                                color: Parameters.shadeHighlightBg
                                topLeftRadius: Parameters.defaultRadius
                                topRightRadius: Parameters.defaultRadius

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.topMargin: topTableRect.height * 0.1
                                    anchors.bottomMargin: topTableRect.height * 0.1
                                    anchors.leftMargin: topTableRect.width * 0.012
                                    anchors.rightMargin: topTableRect.width * 0.012
                                    spacing: topTableRect.width * 0.006

                                    Rectangle {
                                        id: userSearchContainer
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.horizontalStretchFactor: 2
                                        Layout.preferredWidth: 2
                                        color: "#ffffff"
                                        radius: Parameters.defaultRadius

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.topMargin: parent.height * 0.05
                                            anchors.bottomMargin: parent.height * 0.05
                                            anchors.leftMargin: parent.width * 0.05
                                            anchors.rightMargin: parent.width * 0.05
                                            spacing: parent.width * 0.03

                                            Text {
                                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                                font.family: Parameters.iconFontBold
                                                font.pixelSize: userSearchContainer.height * 0.4
                                                text: ""
                                                color: "#000000"
                                            }

                                            TextField {
                                                id: userSearchField
                                                Layout.fillWidth: true
                                                Layout.fillHeight: false
                                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                                                background: Rectangle {
                                                    color: "transparent"
                                                    Layout.preferredHeight: userSearchContainer.height * 0.75
                                                }

                                                placeholderText: "Buscar usuários"
                                                placeholderTextColor: Parameters.dimmedBgColor
                                                verticalAlignment: Text.AlignVCenter
                                                font.family: Parameters.altFont
                                                font.styleName: "Medium Oblique"
                                                font.pixelSize: userSearchContainer.height * 0.4
                                                color: "#202020"
                                                selectByMouse: true
                                                mouseSelectionMode: TextField.SelectWords
                                                onAccepted: containerRect.userSearch = userSearchField.text

                                                HoverHandler {
                                                    enabled: parent.visible
                                                    cursorShape: Qt.IBeamCursor
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: userJobFilterContainer
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.horizontalStretchFactor: 1
                                        Layout.preferredWidth: 1
                                        //implicitWidth: topTableRect.width * 0.2
                                        color: "#ffffff"
                                        radius: Parameters.defaultRadius

                                        ComboBox {
                                            id: userLevelSearcher
                                            model: ["Estoque", "Financeiro", "Supervisão"]
                                            anchors.fill: parent
                                            anchors.margins: 1
                                            displayText: "Cargo"
                                            onDisplayTextChanged: containerRect.userFilter = displayText
                                            onActivated: {
                                                displayText = model[index];
                                                Qt.callLater(() => {
                                                    containerRect.userFilter = displayText;
                                                });
                                            }
                                            property int indexNum: -1

                                            delegate: ItemDelegate {
                                                id: userSearcherDelegate

                                                required property var model
                                                required property int index

                                                onIndexChanged: userLevelSearcher.indexNum = index

                                                width: userLevelSearcher.width - 2

                                                background: Rectangle {
                                                    anchors.top: userSearcherDelegate.index == 0 ? parent.top : undefined
                                                    anchors.topMargin: userSearcherDelegate.index == 0 ? 1 : undefined
                                                    anchors.left: parent.left
                                                    anchors.right: parent.right
                                                    anchors.leftMargin: 3
                                                    anchors.rightMargin: 1
                                                    width: userSearcherDelegate.width
                                                    height: (userSearcherDelegate.index == 0 || userSearcherDelegate.index == 2) ? userSearcherDelegate.height : userSearcherDelegate.height - 2
                                                    color: userSearcherDelegate.index === userLevelSearcher.currentIndex ? Parameters.hoveredButtonBg : userSearcherDelegHoverer.hovered ? Qt.lighter(Parameters.dimmedBgColor, 1.2) : Parameters.mainBgColor
                                                    topLeftRadius: userSearcherDelegate.index == 0 ? Parameters.defaultRadius : 0
                                                    topRightRadius: userSearcherDelegate.index == 0 ? Parameters.defaultRadius : 0
                                                    bottomLeftRadius: userSearcherDelegate.index == 2 ? Parameters.defaultRadius : 0
                                                    bottomRightRadius: userSearcherDelegate.index == 2 ? Parameters.defaultRadius : 0

                                                    HoverHandler {
                                                        id: userSearcherDelegHoverer
                                                        enabled: parent.visible
                                                    }
                                                }

                                                contentItem: Text {
                                                    text: userSearcherDelegate.model[userLevelSearcher.textRole]
                                                    color: userSearcherDelegate.index === userLevelSearcher.currentIndex ? "#fafafa" : "#000000"
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Medium"
                                                    font.pixelSize: userLevelSearcher.height * 0.42
                                                    elide: Text.ElideRight
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                            }

                                            indicator: Canvas {
                                                id: userSearcherCanvas
                                                x: userLevelSearcher.width - width - userLevelSearcher.rightPadding
                                                y: userLevelSearcher.topPadding + (userLevelSearcher.availableHeight - height) / 2
                                                width: 12
                                                height: 8
                                                contextType: "2d"

                                                Connections {
                                                    target: userLevelSearcher
                                                    function onPressedChanged() {
                                                        userSearcherCanvas.requestPaint();
                                                    }
                                                }

                                                onPaint: {
                                                    context.reset();
                                                    context.moveTo(0, 0);
                                                    context.lineTo(width, 0);
                                                    context.lineTo(width / 2, height);
                                                    context.closePath();
                                                    context.fillStyle = "#000000";
                                                    context.fill();
                                                }
                                            }

                                            contentItem: Text {
                                                id: uSearcherText
                                                leftPadding: 4
                                                rightPadding: userLevelSearcher.indicator.width + userLevelSearcher.spacing

                                                text: userLevelSearcher.displayText
                                                font.family: Parameters.defaultFont
                                                font.styleName: "Medium"
                                                font.pixelSize: userLevelSearcher.height * 0.47
                                                color: userLevelSearcher.displayText == "Cargo" ? "#bbbbbb" : userLevelSearcher.popup.visible ? "#666666" : "#000000"
                                                verticalAlignment: Text.AlignVCenter
                                                elide: Text.ElideRight
                                            }

                                            background: Rectangle {
                                                id: uSearcherBg
                                                anchors.fill: parent
                                                anchors.margins: 1
                                                radius: Parameters.defaultRadius
                                                color: Parameters.shadeBgColor
                                                border.width: userLevelSearcher.visualFocus ? 1 : 0
                                                border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)
                                            }

                                            popup: Popup {
                                                id: uSearcherPopup
                                                y: userLevelSearcher.height - 1
                                                width: userLevelSearcher.width
                                                height: Math.min(contentItem.implicitHeight, userLevelSearcher.Window.height - topMargin - bottomMargin) + 2
                                                padding: 0

                                                contentItem: ListView {
                                                    clip: true
                                                    implicitHeight: contentHeight
                                                    model: userLevelSearcher.popup.visible ? userLevelSearcher.delegateModel : null
                                                    currentIndex: userLevelSearcher.highlightedIndex
                                                }

                                                background: Rectangle {
                                                    color: Parameters.pressedButtonBg
                                                    radius: Parameters.defaultRadius
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (uSearcherText.color == Parameters.lowCashRed) {
                                                        uSearcherText.color = userLevelSearcher.displayText == "Cargo" ? "#bbbbbb" : userLevelSearcher.popup.visible ? "#666666" : "#000000";
                                                    }
                                                    uSearcherBg.border.width = userLevelSearcher.visualFocus ? 1 : 0;
                                                    uSearcherBg.border.color = Qt.darker(Parameters.mainHighlightBg, 2.5);
                                                    if (uSearcherPopup.visible) {
                                                        uSearcherPopup.close();
                                                    } else {
                                                        uSearcherPopup.open();
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    /*Item {
                                        Layout.fillWidth: false
                                        Layout.preferredWidth: (topTableRect.width * 0.26)
                                    }*/

                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.horizontalStretchFactor: 1
                                        Layout.preferredWidth: 1
                                        //implicitWidth: topTableRect.width * 0.15
                                        property var highlightGradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop {
                                                position: 0.0
                                                color: Qt.lighter(Parameters.shadeHighlightFg, 1.25)
                                            }
                                            GradientStop {
                                                position: 0.5
                                                color: Qt.lighter(Parameters.shadeHighlightFg, 1.4)
                                            }
                                            GradientStop {
                                                position: 0.85
                                                color: Qt.lighter(Parameters.shadeHighlightFg, 1.2)
                                            }
                                        }
                                        gradient: ((containerRect.userSearch && containerRect.userSearch != "") || (containerRect.userFilter && containerRect.userFilter != "Cargo")) ? highlightGradient : null
                                        color: ((containerRect.userSearch && containerRect.userSearch != "") || (containerRect.userFilter && containerRect.userFilter != "Cargo")) ? null : "#ffffff"
                                        radius: Parameters.defaultRadius

                                        RowLayout {
                                            anchors.centerIn: parent

                                            Text {
                                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                                font.family: Parameters.iconFont
                                                font.pixelSize: userSearchContainer.height * 0.4
                                                text: ""
                                                color: ((containerRect.userSearch && containerRect.userSearch != "") || (containerRect.userFilter && containerRect.userFilter != "Cargo")) ? "#ffffff" : "#000000"
                                            }

                                            Text {
                                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                                font.family: Parameters.defaultFont
                                                font.styleName: "Medium"
                                                font.pixelSize: userSearchContainer.height * 0.4
                                                text: "Limpar filtros"
                                                color: ((containerRect.userSearch && containerRect.userSearch != "") || (containerRect.userFilter && containerRect.userFilter != "Cargo")) ? "#ffffff" : "#000000"
                                            }
                                        }

                                        MouseArea {
                                            enabled: parent.visible
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                containerRect.userSearch = "";
                                                userLevelSearcher.displayText = "Cargo";
                                                containerRect.userFilter = "Cargo";
                                                userSearchField.clear();
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: titleDisplayRow
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: topTableRect.bottom
                                }
                                height: parent.height * 0.07
                                color: '#d1cfcf'
                                z: 2

                                RowLayout {
                                    anchors.fill: parent
                                    uniformCellSizes: false

                                    Rectangle {
                                        id: displayNameDisplay
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        color: "transparent"
                                        radius: Parameters.defaultRadius

                                        Text {
                                            anchors.centerIn: parent
                                            font.family: Parameters.defaultFont
                                            font.styleName: "Medium"
                                            font.pixelSize: userNameDisplay.height * 0.34
                                            fontSizeMode: Text.Fit
                                            minimumPixelSize: 9
                                            text: "Nome Completo"
                                            color: "#000000"
                                        }
                                    }

                                    Rectangle {
                                        id: userNameDisplay
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        color: "transparent"
                                        radius: Parameters.defaultRadius

                                        Text {
                                            anchors.centerIn: parent
                                            font.family: Parameters.defaultFont
                                            font.styleName: "Medium"
                                            font.pixelSize: userNameDisplay.height * 0.34
                                            fontSizeMode: Text.Fit
                                            minimumPixelSize: 9
                                            text: "Nome do Usuário"
                                            color: "#000000"
                                        }
                                    }

                                    Rectangle {
                                        id: userJobDisplay
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        color: "transparent"
                                        radius: Parameters.defaultRadius

                                        Text {
                                            anchors.centerIn: parent
                                            font.family: Parameters.defaultFont
                                            font.styleName: "Medium"
                                            font.pixelSize: userNameDisplay.height * 0.42
                                            fontSizeMode: Text.Fit
                                            minimumPixelSize: 9
                                            text: "Cargo"
                                            color: "#000000"
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        color: "transparent"
                                        radius: Parameters.defaultRadius

                                        Text {
                                            anchors.centerIn: parent
                                            font.family: Parameters.defaultFont
                                            font.styleName: "Medium"
                                            font.pixelSize: userNameDisplay.height * 0.42
                                            fontSizeMode: Text.Fit
                                            minimumPixelSize: 9
                                            text: "Ações"
                                            color: "#000000"
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: mainTable
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: titleDisplayRow.bottom
                                    bottom: parent.bottom
                                }
                                color: "transparent"

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Rectangle {
                                        id: separator1
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 1
                                        radius: 1
                                        color: "#404040"
                                    }

                                    ListView {
                                        id: usersList
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        orientation: ListView.Vertical
                                        boundsBehavior: ListView.StopAtBounds

                                        model: user_model.getEffectiveCount(containerRect.userSearch, containerRect.userFilter)

                                        delegate: ItemDelegate {
                                            id: userDelegate
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            checkable: true
                                            height: 46
                                            required property int index

                                            background: Rectangle {
                                                color: "transparent"
                                                width: parent.width
                                                height: parent.height
                                            }

                                            contentItem: Rectangle {
                                                height: 46
                                                color: "transparent"

                                                ColumnLayout {
                                                    anchors.fill: parent

                                                    RowLayout {
                                                        uniformCellSizes: false

                                                        Rectangle {
                                                            id: userDisplayNameDelegate
                                                            Layout.fillHeight: true
                                                            Layout.fillWidth: true
                                                            color: "transparent"
                                                            radius: Parameters.defaultRadius

                                                            Text {
                                                                anchors.centerIn: parent
                                                                font.family: Parameters.defaultFont
                                                                font.styleName: "Medium"
                                                                font.pixelSize: parent.height * 0.6
                                                                fontSizeMode: Text.Fit
                                                                minimumPixelSize: 7
                                                                text: containerRect.uModel.get(index, containerRect.userSearch, containerRect.userFilter).displayName
                                                                color: "#000000"
                                                            }
                                                        }

                                                        Rectangle {
                                                            id: userNameDelegate
                                                            Layout.fillHeight: true
                                                            Layout.fillWidth: true
                                                            color: "transparent"
                                                            radius: Parameters.defaultRadius

                                                            Text {
                                                                anchors.centerIn: parent
                                                                font.family: Parameters.altFont
                                                                font.styleName: "Bold"
                                                                font.pixelSize: parent.height * 0.67
                                                                fontSizeMode: Text.Fit
                                                                minimumPixelSize: 7
                                                                text: containerRect.uModel.get(index, containerRect.userSearch, containerRect.userFilter).username
                                                                color: "#000000"
                                                            }
                                                        }

                                                        Rectangle {
                                                            id: userJobDelegate
                                                            Layout.fillHeight: true
                                                            Layout.fillWidth: true
                                                            color: "transparent"
                                                            radius: Parameters.defaultRadius

                                                            RowLayout {
                                                                anchors.fill: parent
                                                                spacing: 5

                                                                Item {
                                                                    Layout.fillWidth: true
                                                                }

                                                                Text {
                                                                    Layout.fillWidth: false
                                                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                                                    verticalAlignment: Text.AlignVCenter
                                                                    font.family: Parameters.iconFontBold
                                                                    font.pixelSize: userJobDelegate.height * 0.6
                                                                    text: {
                                                                        const perms = containerRect.uModel.get(index, containerRect.userSearch, containerRect.userFilter).level;
                                                                        if (perms == 0) {
                                                                            return "";
                                                                        } else if (perms == 1) {
                                                                            return "";
                                                                        } else if (perms == 2) {
                                                                            return "";
                                                                        }
                                                                    }
                                                                    color: "#000000"
                                                                }

                                                                Text {
                                                                    Layout.fillWidth: false
                                                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                                                    verticalAlignment: Text.AlignVCenter
                                                                    font.family: Parameters.defaultFont
                                                                    font.styleName: "Medium"
                                                                    font.pixelSize: userJobDelegate.height * 0.6
                                                                    fontSizeMode: Text.Fit
                                                                    minimumPixelSize: 7
                                                                    text: {
                                                                        const perms = containerRect.uModel.get(index, containerRect.userSearch, containerRect.userFilter).level;
                                                                        if (perms == 0) {
                                                                            return "Supervisão";
                                                                        } else if (perms == 1) {
                                                                            return "Financeiro";
                                                                        } else if (perms == 2) {
                                                                            return "Estoque";
                                                                        }
                                                                    }
                                                                    color: "#000000"
                                                                }

                                                                Item {
                                                                    Layout.fillWidth: true
                                                                }
                                                            }
                                                        }

                                                        /*Item {
                                                            Layout.fillWidth: false
                                                            Layout.preferredWidth: (topTableRect.width * 0.12)
                                                        }*/

                                                        Rectangle {
                                                            Layout.fillHeight: true
                                                            Layout.fillWidth: true
                                                            //implicitWidth: topTableRect.width * 0.15
                                                            color: "transparent"
                                                            radius: 0

                                                            RowLayout {
                                                                anchors.fill: parent

                                                                Item {
                                                                    Layout.fillWidth: true
                                                                }

                                                                Button {
                                                                    id: editUserButton
                                                                    text: qsTr("")
                                                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                                                                    onClicked: {
                                                                        editUserDialog.ueCallRow = userDelegate.index;
                                                                        editUserDialog.open();
                                                                    }

                                                                    contentItem: Text {
                                                                        text: editUserButton.text
                                                                        font.family: Parameters.iconFontBold
                                                                        font.pixelSize: 18
                                                                        color: editUserButton.hovered ? Parameters.mainBgColor : "#000000"
                                                                        horizontalAlignment: Text.AlignHCenter
                                                                        verticalAlignment: Text.AlignVCenter
                                                                    }

                                                                    background: Rectangle {
                                                                        implicitWidth: 28
                                                                        implicitHeight: implicitWidth
                                                                        color: editUserButton.down ? Parameters.highlightFg : editUserButton.hovered ? Parameters.hoveredButtonBg : Parameters.mainBgColor
                                                                        border.width: 1
                                                                        border.color: editUserButton.hovered ? "#cccccc" : "#000000"
                                                                        radius: implicitWidth / 2
                                                                    }

                                                                    HoverHandler {
                                                                        enabled: parent.visible
                                                                        cursorShape: Qt.PointingHandCursor
                                                                    }
                                                                }

                                                                Button {
                                                                    id: rmUserButton
                                                                    text: qsTr("")
                                                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                                                                    onClicked: {
                                                                        rmUserDialog.rmuCallRow = userDelegate.index;
                                                                        rmUserDialog.open();
                                                                    }

                                                                    contentItem: Text {
                                                                        text: rmUserButton.text
                                                                        font.family: Parameters.iconFontBold
                                                                        font.pixelSize: 18
                                                                        color: rmUserButton.hovered ? Parameters.mainBgColor : "#000000"
                                                                        horizontalAlignment: Text.AlignHCenter
                                                                        verticalAlignment: Text.AlignVCenter
                                                                    }

                                                                    background: Rectangle {
                                                                        implicitWidth: 28
                                                                        implicitHeight: implicitWidth
                                                                        color: rmUserButton.down ? Parameters.highlightFg : rmUserButton.hovered ? Parameters.hoveredButtonBg : Parameters.mainBgColor
                                                                        border.width: 1
                                                                        border.color: rmUserButton.hovered ? "#cccccc" : "#000000"
                                                                        radius: implicitWidth / 2
                                                                    }

                                                                    HoverHandler {
                                                                        enabled: parent.visible
                                                                        cursorShape: Qt.PointingHandCursor
                                                                    }
                                                                }

                                                                Item {
                                                                    Layout.fillWidth: true
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Rectangle {
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: 1
                                                        radius: 1
                                                        color: "#404040"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: newUserDialog
        anchors.fill: parent
        visible: false
        opacity: 0
        property string createdUser
        property var userData

        Shortcut {
            enabled: newUserDialog.visible
            sequence: "Escape"
            onActivated: {
                newUserDialog.close();
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 170
            }
        }

        function open() {
            newUserDialog.visible = true;
            Qt.callLater(() => {
                newUserDialog.opacity = 1.0;
            });
        }

        function close() {
            newUserDialog.opacity = 0;
            closeNewUserDialog.restart();
        }

        Timer {
            id: closeNewUserDialog
            running: false
            repeat: false
            interval: 200
            onTriggered: {
                newUserDialog.visible = false;
            }
        }

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#ee000000"
            }
            GradientStop {
                position: 0.4
                color: '#ee151517'
            }
            GradientStop {
                position: 0.6
                color: '#ee262527'
            }
            GradientStop {
                position: 0.7
                color: '#ee201f21'
            }
            GradientStop {
                position: 1.0
                color: "#ee000000"
            }
        }

        MultiEffect {
            source: newUserDialog
            blurEnabled: true
            blur: 0.7
        }

        Rectangle {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: sidebarRect.width / 2
            width: containerRect.globalScaleWidth + containerRect.globalScaleWidth / 25
            height: 190 + containerRect.globalScaleWidth / 27
            radius: 30
            color: Parameters.pressedButtonBg

            ColumnLayout {
                anchors.centerIn: parent
                width: containerRect.globalScaleWidth
                spacing: containerRect.globalScaleHeight * 0.006

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    color: Parameters.mainHighlightBg
                    topLeftRadius: 15
                    topRightRadius: 15

                    Text {
                        anchors.centerIn: parent
                        text: "Adicionar Novo Usuário"
                        color: Parameters.mainBgColor
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 26
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: containerRect.globalScaleWidth * 0.012
                    Layout.rightMargin: containerRect.globalScaleWidth * 0.012
                    spacing: containerRect.globalScaleWidth * 0.001

                    Rectangle {
                        id: addUNameContainer
                        Layout.fillWidth: true
                        Layout.preferredWidth: containerRect.globalScaleWidth * 0.3
                        Layout.horizontalStretchFactor: 3
                        radius: Parameters.defaultRadius
                        Layout.preferredHeight: 40
                        color: Parameters.shadeBgColor
                        border.width: 1
                        border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.IBeamCursor
                            onClicked: {
                                addUNameContainer.border.width = 1;
                                addUNameContainer.border.color = Qt.darker(Parameters.mainHighlightBg, 2.5);
                                addUName.placeholderTextColor = "#bbbbbb";
                                addUName.forceActiveFocus();
                            }

                            TextField {
                                id: addUName
                                background: Rectangle {
                                    color: "transparent"
                                }
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                anchors.rightMargin: 4
                                anchors.topMargin: 2
                                anchors.bottomMargin: 2
                                color: "#000000"
                                font.family: Parameters.altFont
                                font.styleName: "Bold"
                                font.pixelSize: userLevelCombo.height * 0.47
                                placeholderText: "Nome Completo do Usuário"
                                placeholderTextColor: "#bbbbbb"
                                validator: RegularExpressionValidator {
                                    regularExpression: /(.|\s)*\S(.|\s)*/
                                }
                                focus: true
                                onPressed: {
                                    addUNameContainer.border.width = 1;
                                    addUNameContainer.border.color = Qt.darker(Parameters.mainHighlightBg, 2.5);
                                    addUName.placeholderTextColor = "#bbbbbb";
                                }
                            }
                        }
                    }

                    ComboBox {
                        id: userLevelCombo
                        model: ["Estoque", "Financeiro", "Supervisão"]
                        Layout.fillWidth: true
                        Layout.preferredWidth: containerRect.globalScaleWidth * 0.12
                        Layout.horizontalStretchFactor: 1
                        Layout.preferredHeight: 40
                        displayText: "Cargo"
                        onActivated: displayText = model[index]

                        delegate: ItemDelegate {
                            id: userComboDelegate

                            required property var model
                            required property int index

                            width: userLevelCombo.width

                            background: Rectangle {
                                width: userComboDelegate.width - 1
                                height: userComboDelegate.height
                                color: userComboDelegate.index === userLevelCombo.currentIndex ? Parameters.hoveredButtonBg : userComboDelHoverer.hovered ? Qt.lighter(Parameters.dimmedBgColor, 1.2) : Parameters.mainBgColor
                                topLeftRadius: userComboDelegate.index === 0 ? Parameters.defaultRadius : 0
                                topRightRadius: userComboDelegate.index === 0 ? Parameters.defaultRadius : 0
                                bottomLeftRadius: userComboDelegate.index === 2 ? Parameters.defaultRadius : 0
                                bottomRightRadius: userComboDelegate.index === 2 ? Parameters.defaultRadius : 0

                                HoverHandler {
                                    id: userComboDelHoverer
                                    enabled: parent.visible
                                }
                            }

                            contentItem: Text {
                                text: userComboDelegate.model[userLevelCombo.textRole]
                                color: userComboDelegate.index === userLevelCombo.currentIndex ? "#fafafa" : "#000000"
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: userLevelCombo.height * 0.42
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        indicator: Canvas {
                            id: userComboCanvas
                            x: userLevelCombo.width - width - userLevelCombo.rightPadding
                            y: userLevelCombo.topPadding + (userLevelCombo.availableHeight - height) / 2
                            width: 12
                            height: 8
                            contextType: "2d"

                            Connections {
                                target: userLevelCombo
                                function onPressedChanged() {
                                    userComboCanvas.requestPaint();
                                }
                            }

                            onPaint: {
                                context.reset();
                                context.moveTo(0, 0);
                                context.lineTo(width, 0);
                                context.lineTo(width / 2, height);
                                context.closePath();
                                context.fillStyle = "#000000";
                                context.fill();
                            }
                        }

                        contentItem: Text {
                            id: comboText
                            leftPadding: 4
                            rightPadding: userLevelCombo.indicator.width + userLevelCombo.spacing

                            text: userLevelCombo.displayText
                            font.family: Parameters.defaultFont
                            font.styleName: "Medium"
                            font.pixelSize: userLevelCombo.height * 0.47
                            color: userLevelCombo.displayText == "Cargo" ? "#bbbbbb" : userLevelCombo.popup.visible ? "#666666" : "#000000"
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            id: comboBg
                            Layout.fillWidth: true
                            Layout.preferredWidth: containerRect.globalScaleWidth * 0.12
                            Layout.horizontalStretchFactor: 1
                            radius: Parameters.defaultRadius
                            Layout.preferredHeight: 40
                            color: Parameters.shadeBgColor
                            border.width: userLevelCombo.visualFocus ? 1 : 0
                            border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)
                        }

                        popup: Popup {
                            id: comboPopup
                            y: userLevelCombo.height - 1
                            width: userLevelCombo.width
                            height: Math.min(contentItem.implicitHeight, userLevelCombo.Window.height - topMargin - bottomMargin)
                            padding: 1

                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: userLevelCombo.popup.visible ? userLevelCombo.delegateModel : null
                                currentIndex: userLevelCombo.highlightedIndex
                            }

                            background: Rectangle {
                                color: Parameters.pressedButtonBg
                                radius: Parameters.defaultRadius
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (comboText.color == Parameters.lowCashRed) {
                                    comboText.color = userLevelCombo.displayText == "Cargo" ? "#bbbbbb" : userLevelCombo.popup.visible ? "#666666" : "#000000";
                                }
                                comboBg.border.width = userLevelCombo.visualFocus ? 1 : 0;
                                comboBg.border.color = Qt.darker(Parameters.mainHighlightBg, 2.5);
                                if (comboPopup.visible) {
                                    comboPopup.close();
                                } else {
                                    comboPopup.open();
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: passwordWarn.contentWidth + 16
                    Layout.maximumWidth: containerRect.globalScaleWidth
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignHCenter
                    color: Parameters.shadeBgColor
                    border.width: 2
                    border.color: Parameters.lowCashRed
                    radius: 15

                    Text {
                        id: passwordWarn
                        anchors.centerIn: parent
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 16
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        wrapMode: Text.Wrap
                        color: "#454545"
                        text: "A senha inicial será definida a seguir. O nome de usuário será criado a partir do nome completo."
                        width: containerRect.globalScaleWidth * 0.8
                        height: parent.height - 8
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
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
                            id: addUSubmit
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: false
                            text: "OK"
                            implicitWidth: 74
                            implicitHeight: 34

                            onClicked: {
                                if (addUName.acceptableInput && userLevelCombo.displayText != "Cargo") {
                                    let level = userLevelCombo.displayText == "Supervisão" ? 0 : userLevelCombo.displayText == "Financeiro" ? 1 : 2;

                                    newUserDialog.userData = containerRect.uModel.genNewUser(addUName.text);
                                    Qt.callLater(() => {
                                        containerRect.uModel.appendNewUser(newUserDialog.userData.displayName, newUserDialog.userData.username, newUserDialog.userData.hashedPasswd, level);
                                    });

                                    newUserDialog.createdUser = addUName.text;

                                    newTempPasswdWarn.open();

                                    //newUserDialog.close()

                                    containerRect.userAction();
                                } else {
                                    if (!addUName.acceptableInput) {
                                        addUNameContainer.border.width = 3;
                                        addUNameContainer.border.color = Parameters.lowCashRed;
                                        addUName.placeholderTextColor = Parameters.lowCashRed;
                                    }
                                    if (userLevelCombo.displayText == "Cargo") {
                                        comboText.color = Parameters.lowCashRed;
                                        comboBg.border.color = Parameters.lowCashRed;
                                        comboBg.border.width = 3;
                                    }
                                }
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pointSize: 12
                                text: addUSubmit.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 74
                                implicitHeight: 34
                                radius: Parameters.defaultRadius * 2
                                color: addUSubmit.down ? Parameters.pressedButtonBg : addUSubmit.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                border.width: 2
                                border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            HoverHandler {
                                enabled: parent.visible
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        Button {
                            id: addUCancel
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: false
                            text: "Cancelar"
                            implicitWidth: 82
                            implicitHeight: 34

                            onClicked: {
                                newUserDialog.close();
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pointSize: 12
                                text: addUCancel.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 82
                                implicitHeight: 34
                                radius: Parameters.defaultRadius * 2
                                color: addUCancel.down ? Parameters.pressedButtonBg : addUCancel.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
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

        Rectangle {
            id: newTempPasswdWarn
            anchors.fill: parent
            color: "transparent"
            visible: false
            opacity: 0
            scale: 0.85

            Behavior on scale {
                NumberAnimation {
                    duration: 200
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 170
                }
            }

            function open() {
                newTempPasswdWarn.visible = true;
                Qt.callLater(() => {
                    newTempPasswdWarn.opacity = 1.0;
                    newTempPasswdWarn.scale = 1.0;
                });
            }

            Rectangle {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: sidebarRect.width / 2
                width: containerRect.globalScaleWidth + containerRect.globalScaleWidth / 25
                height: 180 + containerRect.globalScaleWidth / 27
                radius: 30
                color: Parameters.pressedButtonBg

                ColumnLayout {
                    id: tempMasterColumn
                    anchors.centerIn: parent
                    width: containerRect.globalScaleWidth * 0.5
                    spacing: containerRect.globalScaleHeight * 0.006

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 55
                        color: Parameters.mainHighlightBg
                        topLeftRadius: 15
                        topRightRadius: 15

                        Text {
                            anchors.centerIn: parent
                            text: "Senha temporária do novo usuário"
                            color: Parameters.mainBgColor
                            font.family: Parameters.defaultFont
                            font.styleName: "Medium"
                            font.pixelSize: 26
                            fontSizeMode: Text.Fit
                            minimumPixelSize: 10
                            width: parent.width - 4
                            height: parent.height - 4
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: containerRect.globalScaleWidth * 0.1
                        Layout.rightMargin: containerRect.globalScaleWidth * 0.1
                        Layout.preferredHeight: warnColumn.implicitHeight + containerRect.globalScaleHeight * 0.04
                        color: Parameters.shadeBgColor
                        border.width: 2
                        border.color: Parameters.lowCashRed
                        radius: 15

                        ColumnLayout {
                            id: warnColumn
                            anchors.centerIn: parent
                            implicitWidth: parent.width - containerRect.globalScaleWidth * 0.05

                            Text {
                                id: showUsernameDisplay
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: 18
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 10
                                color: "#000000"
                                text: "Essa é o username desse usuário, que deverá ser utilizado no login: "
                                wrapMode: Text.Wrap
                                Layout.preferredWidth: parent.implicitWidth
                            }

                            TextInput {
                                id: showUsername1
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: showUsernameDisplay.font.pixelSize
                                color: '#0a0b46'
                                text: newUserDialog.userData.username
                                wrapMode: Text.Wrap
                                Layout.preferredWidth: parent.implicitWidth
                                readOnly: true
                            }

                            Text {
                                id: showTempPasswdWarning
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: 18
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 10
                                color: "#000000"
                                text: "Essa é a senha temporária desse usuário: "
                                wrapMode: Text.Wrap
                                Layout.preferredWidth: parent.implicitWidth
                            }

                            TextInput {
                                id: showTempPasswd1
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: showUsernameDisplay.font.pixelSize
                                color: '#500d0d'
                                text: newUserDialog.userData.plainPasswd
                                wrapMode: Text.Wrap
                                Layout.preferredWidth: parent.implicitWidth
                                readOnly: true
                            }

                            Text {
                                id: showTempPasswd2
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: 18
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 10
                                color: "#000000"
                                text: "Essa senha só será usada para o primeiro login, e será trocada após sua conclusão."
                                wrapMode: Text.Wrap
                                Layout.preferredWidth: parent.implicitWidth
                            }

                            Text {
                                id: showTempPasswd3
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: 18
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 10
                                color: "#000000"
                                text: "Anote-a, pois não será possível fazer o login sem ela, e ela somente será mostrada aqui agora."
                                wrapMode: Text.Wrap
                                Layout.preferredWidth: parent.implicitWidth
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
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
                                id: confirmSeenPasswdWarn
                                Layout.alignment: Qt.AlignVCenter
                                Layout.fillWidth: false
                                text: "OK"
                                implicitWidth: 74
                                implicitHeight: 34

                                onClicked: {
                                    newTempPasswdWarn.visible = false;
                                    newUserDialog.close();
                                    Qt.callLater(() => {
                                        addUName.clear();
                                        delete newUserDialog.userData.plainPasswd;
                                        containerRect.userAction();
                                    });
                                }

                                contentItem: Text {
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: Parameters.defaultFont
                                    font.styleName: "Medium"
                                    font.pointSize: 12
                                    text: confirmSeenPasswdWarn.text
                                    color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                }

                                background: Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    implicitWidth: 74
                                    implicitHeight: 34
                                    radius: Parameters.defaultRadius * 2
                                    color: confirmSeenPasswdWarn.down ? Parameters.pressedButtonBg : confirmSeenPasswdWarn.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
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
    }

    Rectangle {
        id: editUserDialog
        anchors.fill: parent
        visible: false
        opacity: 0
        property int ueCallRow
        property string userData1: ""
        property string userData2: ""

        Shortcut {
            enabled: editUserDialog.visible
            sequence: "Escape"
            onActivated: {
                editUserDialog.close();
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 170
            }
        }

        function open() {
            editUserDialog.visible = true;
            Qt.callLater(() => {
                editUserDialog.opacity = 1.0;
            });
        }

        function close() {
            editUserDialog.opacity = 0;
            closeEUserDialog.restart();
        }

        Timer {
            id: closeEUserDialog
            running: false
            repeat: false
            interval: 200
            onTriggered: {
                editUserDialog.visible = false;
            }
        }

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#ee000000"
            }
            GradientStop {
                position: 0.4
                color: '#ee151517'
            }
            GradientStop {
                position: 0.6
                color: '#ee262527'
            }
            GradientStop {
                position: 0.7
                color: '#ee201f21'
            }
            GradientStop {
                position: 1.0
                color: "#ee000000"
            }
        }

        MultiEffect {
            source: editUserDialog
            blurEnabled: true
            blur: 0.7
        }

        Rectangle {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: sidebarRect.width / 2
            width: containerRect.globalScaleWidth + containerRect.globalScaleWidth / 25
            height: 180 + containerRect.globalScaleWidth / 27
            radius: 30
            color: Parameters.pressedButtonBg

            GridLayout {
                columns: 4
                rows: 4
                anchors.centerIn: parent
                width: containerRect.globalScaleWidth
                columnSpacing: 1
                rowSpacing: 2

                Rectangle {
                    Layout.fillWidth: true
                    Layout.columnSpan: 4
                    Layout.preferredHeight: 55
                    color: Parameters.mainHighlightBg
                    topLeftRadius: 15
                    topRightRadius: 15

                    Text {
                        anchors.centerIn: parent
                        text: "Editar Usuário"
                        color: Parameters.mainBgColor
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 26
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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
                        anchors.centerIn: parent
                        color: '#000000'
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Nome Completo"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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

                    Text {
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Username"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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

                    Text {
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Cargo"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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

                    Text {
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Senha"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    id: editUDNRect
                    Layout.horizontalStretchFactor: 3
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.IBeamCursor
                        onClicked: editUDisplayName.forceActiveFocus()

                        TextInput {
                            id: editUDisplayName
                            anchors.centerIn: parent
                            color: "#000000"
                            font.family: Parameters.defaultFont
                            font.styleName: "Medium"
                            font.pointSize: editUDNRect.height * 0.45
                            text: user_model.get(editUserDialog.ueCallRow, "", "").displayName
                        }
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

                    Text {
                        id: editUUsername
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pointSize: parent.height * 0.48
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        text: user_model.get(editUserDialog.ueCallRow, "", "").username
                    }
                }

                Rectangle {
                    id: editULevelRect
                    Layout.horizontalStretchFactor: 2
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                    ComboBox {
                        id: editULevelCombo
                        model: ["Estoque", "Financeiro", "Supervisão"]
                        anchors.fill: parent
                        anchors.margins: 2
                        displayText: {
                            let userLevel = parseInt(user_model.getUserLevel(editUUsername.text));
                            switch (userLevel) {
                            case 0:
                                return "Supervisão";
                            case 1:
                                return "Financeiro";
                            default:
                                return "Estoque";
                            }
                        }
                        onActivated: displayText = model[index]

                        delegate: ItemDelegate {
                            id: editLevelDelegate

                            required property var model
                            required property int index

                            width: editULevelCombo.width

                            background: Rectangle {
                                width: editLevelDelegate.width - 1
                                height: editLevelDelegate.height
                                color: editLevelDelegate.index === editULevelCombo.currentIndex ? Parameters.hoveredButtonBg : eLDelegHoverer.hovered ? Qt.lighter(Parameters.dimmedBgColor, 1.2) : Parameters.mainBgColor
                                topLeftRadius: editLevelDelegate.index === 0 ? Parameters.defaultRadius : 0
                                topRightRadius: editLevelDelegate.index === 0 ? Parameters.defaultRadius : 0
                                bottomLeftRadius: editLevelDelegate.index === 2 ? Parameters.defaultRadius : 0
                                bottomRightRadius: editLevelDelegate.index === 2 ? Parameters.defaultRadius : 0

                                HoverHandler {
                                    id: eLDelegHoverer
                                    enabled: parent.visible
                                }
                            }

                            contentItem: Text {
                                text: editLevelDelegate.model[editULevelCombo.textRole]
                                color: editLevelDelegate.index === editULevelCombo.currentIndex ? "#fafafa" : "#000000"
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: editULevelCombo.height * 0.55
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        indicator: Canvas {
                            id: editLevelCanvas
                            x: editULevelCombo.width - width - editULevelCombo.rightPadding
                            y: editULevelCombo.topPadding + (editULevelCombo.availableHeight - height) / 2
                            width: 12
                            height: 8
                            contextType: "2d"

                            Connections {
                                target: editULevelCombo
                                function onPressedChanged() {
                                    editLevelCanvas.requestPaint();
                                }
                            }

                            onPaint: {
                                context.reset();
                                context.moveTo(0, 0);
                                context.lineTo(width, 0);
                                context.lineTo(width / 2, height);
                                context.closePath();
                                context.fillStyle = "#000000";
                                context.fill();
                            }
                        }

                        contentItem: Text {
                            id: eLText
                            leftPadding: 4
                            rightPadding: editULevelCombo.indicator.width + editULevelCombo.spacing

                            text: editULevelCombo.displayText
                            font.family: Parameters.defaultFont
                            font.styleName: "Medium"
                            font.pixelSize: editULevelCombo.height * 0.55
                            color: editULevelCombo.displayText == "Cargo" ? "#bbbbbb" : editULevelCombo.popup.visible ? "#666666" : "#000000"
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            id: editLevelBg
                            Layout.fillWidth: true
                            Layout.preferredWidth: containerRect.globalScaleWidth * 0.12
                            Layout.horizontalStretchFactor: 1
                            radius: Parameters.defaultRadius
                            Layout.preferredHeight: 40
                            color: Parameters.shadeBgColor
                            border.width: editULevelCombo.visualFocus ? 1 : 0
                            border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)
                        }

                        popup: Popup {
                            id: editLevelPopup
                            y: editULevelCombo.height - 1
                            width: editULevelCombo.width
                            height: Math.min(contentItem.implicitHeight, editULevelCombo.Window.height - topMargin - bottomMargin)
                            padding: 1

                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: editULevelCombo.popup.visible ? editULevelCombo.delegateModel : null
                                currentIndex: editULevelCombo.highlightedIndex
                            }

                            background: Rectangle {
                                color: Parameters.pressedButtonBg
                                radius: Parameters.defaultRadius
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (eLText.color == Parameters.lowCashRed) {
                                    eLText.color = editULevelCombo.popup.visible ? "#666666" : "#000000";
                                }
                                editLevelBg.border.width = editULevelCombo.visualFocus ? 1 : 0;
                                editLevelBg.border.color = Qt.darker(Parameters.mainHighlightBg, 2.5);
                                if (editLevelPopup.visible) {
                                    editLevelPopup.close();
                                } else {
                                    editLevelPopup.open();
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: userPassResetRect
                    Layout.horizontalStretchFactor: 2
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                    CheckBox {
                        id: resetPassCheck
                        text: qsTr("Trocar Senha?")
                        checked: false
                        anchors.centerIn: parent
                        implicitWidth: targetWidth + passCheckText.width + 7
                        property real targetWidth: containerRect.globalScaleWidth / 55

                        indicator: Rectangle {
                            implicitHeight: resetPassCheck.targetWidth
                            implicitWidth: resetPassCheck.targetWidth
                            color: Parameters.mainBgColor
                            border.color: resetPassCheck.down ? Parameters.pressedButtonBg : resetPassCheck.checked ? Qt.darker(Parameters.mainHighlightBg, 2.5) : Parameters.hoveredButtonBg
                            x: resetPassCheck.leftPadding * 1.3
                            y: parent.height / 2 - height / 2
                            radius: 4

                            Rectangle {
                                width: resetPassCheck.targetWidth * 0.64
                                height: resetPassCheck.targetWidth * 0.64
                                x: (resetPassCheck.targetWidth - resetPassCheck.targetWidth * 0.64) / 2
                                y: (resetPassCheck.targetWidth - resetPassCheck.targetWidth * 0.64) / 2
                                radius: 3
                                color: (resetPassCheck.down || resetPassCheck.checked) ? Parameters.mainHighlightBg : Parameters.shadeBgColor
                                visible: resetPassCheck.checked
                            }
                        }

                        contentItem: Text {
                            id: passCheckText
                            text: resetPassCheck.text
                            font.family: Parameters.defaultFont
                            font.styleName: "Medium"
                            font.pixelSize: 18
                            fontSizeMode: Text.Fit
                            minimumPixelSize: 6
                            color: "#000000"
                            verticalAlignment: Text.AlignVCenter
                            //horizontalAlignment: Text.AlignHCenter
                            //Layout.alignment: Qt.AlignVCenter
                            leftPadding: resetPassCheck.targetWidth + 4 + resetPassCheck.leftPadding * 0.3
                            height: resetPassCheck.targetWidth
                            width: userPassResetRect.width - (resetPassCheck.targetWidth + 8)
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
                            left: parent.left
                            topMargin: 2
                            bottomMargin: 2
                            rightMargin: 6
                            leftMargin: 12
                        }
                        layoutDirection: Qt.RightToLeft
                        spacing: 6

                        Button {
                            id: eUserSubmit
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: false
                            text: "OK"
                            implicitWidth: 74
                            implicitHeight: 34

                            onClicked: {
                                if (editUDisplayName.acceptableInput && editULevelCombo.displayText) {
                                    let targetLevel = 2;
                                    switch (editULevelCombo.displayText) {
                                    case "Estoque":
                                        targetLevel = 2;
                                        break;
                                    case "Financeiro":
                                        targetLevel = 1;
                                        break;
                                    case "Supervisão":
                                        targetLevel = 0;
                                        break;
                                    }
                                    if (user_model.get(editUserDialog.ueCallRow, "", "").level == 0 && user_model.getEffectiveCount("", "Supervisão") == 1 && targetLevel !== 0) {
                                        userEditException.visible = true;
                                    } else if ((user_model.getEffectiveCount("", "Supervisão") > 1 || user_model.get(editUserDialog.ueCallRow, "", "").level != 0) || targetLevel === 0) {
                                        if (resetPassCheck.checked) {
                                            userEditException.visible = false;
                                            editUserDialog.userData1 = editUUsername.text;
                                            editUserDialog.userData2 = user_model.editUser(editUUsername.text, true, true, targetLevel);
                                            editTempPasswdWarn.open();
                                        } else {
                                            userEditException.visible = false;
                                            user_model.editUser(editUUsername.text, false, true, targetLevel);
                                            editUserDialog.close();
                                            containerRect.userAction();
                                        }
                                    }
                                }
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pointSize: 12
                                text: eUserSubmit.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 74
                                implicitHeight: 34
                                radius: Parameters.defaultRadius * 2
                                color: eUserSubmit.down ? Parameters.pressedButtonBg : eUserSubmit.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                border.width: 2
                                border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            HoverHandler {
                                enabled: parent.visible
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        Button {
                            id: eUserCancel
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: false
                            text: "Cancelar"
                            implicitWidth: 82
                            implicitHeight: 34

                            onClicked: {
                                userEditException.visible = false;
                                editUserDialog.close();
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pointSize: 12
                                text: eUserCancel.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 82
                                implicitHeight: 34
                                radius: Parameters.defaultRadius * 2
                                color: eUserCancel.down ? Parameters.pressedButtonBg : eUserCancel.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                border.width: 2
                                border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            HoverHandler {
                                enabled: parent.visible
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            id: userEditException
                            visible: false
                            Layout.alignment: Qt.AlignVCenter
                            font.pixelSize: editUDNRect.height * 0.42
                            color: '#570c12'
                            fontSizeMode: Text.Fit
                            minimumPixelSize: 6
                            text: "Não é possível mudar o cargo de um usuário, quando este é o único supervisor."
                        }
                    }
                }
            }
        }

        Rectangle {
            id: editTempPasswdWarn
            anchors.fill: parent
            color: "transparent"
            visible: false
            opacity: 0
            scale: 0.85

            Behavior on scale {
                NumberAnimation {
                    duration: 200
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 170
                }
            }

            function open() {
                editTempPasswdWarn.visible = true;
                Qt.callLater(() => {
                    editTempPasswdWarn.opacity = 1.0;
                    editTempPasswdWarn.scale = 1.0;
                });
            }

            Rectangle {
                anchors.centerIn: parent
                width: containerRect.globalScaleWidth + containerRect.globalScaleWidth / 25
                height: editTDColumn.implicitHeight + 30
                radius: 30
                color: Parameters.pressedButtonBg

                ColumnLayout {
                    id: editTDColumn
                    anchors.centerIn: parent
                    width: containerRect.globalScaleWidth
                    spacing: containerRect.globalScaleHeight * 0.006

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 55
                        color: Parameters.mainHighlightBg
                        topLeftRadius: 15
                        topRightRadius: 15

                        Text {
                            anchors.centerIn: parent
                            text: "Senha temporária do novo usuário"
                            color: Parameters.mainBgColor
                            font.family: Parameters.defaultFont
                            font.styleName: "Medium"
                            font.pixelSize: 26
                            fontSizeMode: Text.Fit
                            minimumPixelSize: 10
                            width: parent.width - 4
                            height: parent.height - 4
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: containerRect.globalScaleWidth * 0.1
                        Layout.rightMargin: containerRect.globalScaleWidth * 0.1
                        Layout.preferredHeight: tWarnColumn.implicitHeight + containerRect.globalScaleHeight * 0.04
                        color: Parameters.shadeBgColor
                        border.width: 2
                        border.color: Parameters.lowCashRed
                        radius: 15

                        ColumnLayout {
                            id: tWarnColumn
                            anchors.centerIn: parent
                            implicitWidth: parent.width - containerRect.globalScaleWidth * 0.05

                            Text {
                                id: editedUnameDisplay
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: 18
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 10
                                color: "#000000"
                                text: "Nova senha criada para o seguinte usuário: "
                                wrapMode: Text.Wrap
                                Layout.preferredWidth: parent.implicitWidth
                            }

                            TextInput {
                                id: editedUname1
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: editedUnameDisplay.font.pixelSize
                                color: '#0a0b46'
                                text: editUserDialog.userData1
                                wrapMode: Text.Wrap
                                Layout.preferredWidth: parent.implicitWidth
                                readOnly: true
                            }

                            Text {
                                id: editedTempWarning
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: 18
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 10
                                color: "#000000"
                                text: "Essa é a nova senha temporária criada: "
                                wrapMode: Text.Wrap
                                Layout.preferredWidth: parent.implicitWidth
                            }

                            TextInput {
                                id: editedTempPasswd1
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: editedUnameDisplay.font.pixelSize
                                color: '#500d0d'
                                text: editUserDialog.userData2
                                wrapMode: Text.Wrap
                                Layout.preferredWidth: parent.implicitWidth
                                readOnly: true
                            }

                            Text {
                                id: editedTempPasswd2
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: 18
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 10
                                color: "#000000"
                                text: "Essa senha só será usada para o próximo login, e será trocada após sua conclusão."
                                wrapMode: Text.Wrap
                                Layout.preferredWidth: parent.implicitWidth
                            }

                            Text {
                                id: editedTempPasswd3
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: 18
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 10
                                color: "#000000"
                                text: "Anote-a, pois não será possível fazer o login sem ela, e ela somente será mostrada aqui agora."
                                wrapMode: Text.Wrap
                                Layout.preferredWidth: parent.implicitWidth
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
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
                                id: editedPasswdSeenConfirm
                                Layout.alignment: Qt.AlignVCenter
                                Layout.fillWidth: false
                                text: "OK"
                                implicitWidth: 74
                                implicitHeight: 34

                                onClicked: {
                                    editTempPasswdWarn.visible = false;
                                    editUserDialog.close();
                                    Qt.callLater(() => {
                                        editUserDialog.userData2 = "redacted";
                                        containerRect.userAction();
                                    });
                                }

                                contentItem: Text {
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: Parameters.defaultFont
                                    font.styleName: "Medium"
                                    font.pointSize: 12
                                    text: editedPasswdSeenConfirm.text
                                    color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                }

                                background: Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    implicitWidth: 74
                                    implicitHeight: 34
                                    radius: Parameters.defaultRadius * 2
                                    color: editedPasswdSeenConfirm.down ? Parameters.pressedButtonBg : editedPasswdSeenConfirm.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
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
    }

    Rectangle {
        id: rmUserDialog
        anchors.fill: parent
        visible: false
        opacity: 0
        property int rmuCallRow

        Shortcut {
            enabled: rmUserDialog.visible
            sequence: "Escape"
            onActivated: {
                rmUserDialog.close();
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 170
            }
        }

        function open() {
            rmUserDialog.visible = true;
            Qt.callLater(() => {
                rmUserDialog.opacity = 1.0;
            });
        }

        function close() {
            rmUserDialog.opacity = 0;
            closeRmUserDialog.restart();
        }

        Timer {
            id: closeRmUserDialog
            running: false
            repeat: false
            interval: 200
            onTriggered: {
                rmUserDialog.visible = false;
            }
        }

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#ee000000"
            }
            GradientStop {
                position: 0.4
                color: '#ee151517'
            }
            GradientStop {
                position: 0.6
                color: '#ee262527'
            }
            GradientStop {
                position: 0.7
                color: '#ee201f21'
            }
            GradientStop {
                position: 1.0
                color: "#ee000000"
            }
        }

        MultiEffect {
            source: rmUserDialog
            blurEnabled: true
            blur: 0.7
        }

        Rectangle {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: sidebarRect.width / 2
            width: containerRect.globalScaleWidth + containerRect.globalScaleWidth / 25
            height: 180 + containerRect.globalScaleWidth / 27
            radius: 30
            color: Parameters.pressedButtonBg

            GridLayout {
                columns: 3
                rows: 4
                anchors.centerIn: parent
                width: containerRect.globalScaleWidth
                columnSpacing: 1
                rowSpacing: 2

                Rectangle {
                    Layout.fillWidth: true
                    Layout.columnSpan: 3
                    Layout.preferredHeight: 55
                    color: Parameters.mainHighlightBg
                    topLeftRadius: 15
                    topRightRadius: 15

                    Text {
                        anchors.centerIn: parent
                        text: "Remover Usuário"
                        color: Parameters.mainBgColor
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 26
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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
                        anchors.centerIn: parent
                        color: '#000000'
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Nome Completo"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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

                    Text {
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Username"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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

                    Text {
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Cargo"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: parent.height * 0.54
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        text: user_model.get(rmUserDialog.rmuCallRow, "", "").displayName
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

                    Text {
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: parent.height * 0.54
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        text: user_model.get(rmUserDialog.rmuCallRow, "", "").username
                    }
                }

                Rectangle {
                    id: rmUserLevelRect
                    Layout.horizontalStretchFactor: 2
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                    Text {
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: parent.height * 0.54
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        text: {
                            let levelData = user_model.get(rmUserDialog.rmuCallRow, "", "").level;
                            switch (parseInt(levelData)) {
                            case 0:
                                return "Supervisão";
                            case 1:
                                return "Financeiro";
                            case 2:
                                return "Estoque";
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    Layout.columnSpan: 3
                    color: Parameters.highlightFg
                    bottomRightRadius: 15
                    bottomLeftRadius: 15

                    RowLayout {
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            right: parent.right
                            left: parent.left
                            topMargin: 2
                            bottomMargin: 2
                            rightMargin: 6
                            leftMargin: 12
                        }
                        layoutDirection: Qt.RightToLeft
                        spacing: 6

                        Button {
                            id: rmUserSubmit
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: false
                            text: "OK"
                            implicitWidth: 74
                            implicitHeight: 34

                            onClicked: {
                                if (containerRect.usersCount > 1) {
                                    user_model.rmUser(rmUserDialog.rmuCallRow);
                                    containerRect.userAction();
                                    rmUserDialog.close();
                                } else {
                                    userRmException.visible = true;
                                }
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pointSize: 12
                                text: rmUserSubmit.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 74
                                implicitHeight: 34
                                radius: Parameters.defaultRadius * 2
                                color: rmUserSubmit.down ? Parameters.pressedButtonBg : rmUserSubmit.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                border.width: 2
                                border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            HoverHandler {
                                enabled: parent.visible
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        Button {
                            id: rmUserCancel
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: false
                            text: "Cancelar"
                            implicitWidth: 82
                            implicitHeight: 34

                            onClicked: {
                                userRmException.visible = false;
                                rmUserDialog.close();
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pointSize: 12
                                text: rmUserCancel.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 82
                                implicitHeight: 34
                                radius: Parameters.defaultRadius * 2
                                color: rmUserCancel.down ? Parameters.pressedButtonBg : rmUserCancel.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                border.width: 2
                                border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            HoverHandler {
                                enabled: parent.visible
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            id: userRmException
                            visible: false
                            Layout.alignment: Qt.AlignVCenter
                            font.pixelSize: rmUserLevelRect.height * 0.42
                            color: '#570c12'
                            fontSizeMode: Text.Fit
                            minimumPixelSize: 6
                            text: "Não é possível remover o único usuário."
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: newItemDialog
        anchors.fill: parent
        visible: false
        opacity: 0

        Shortcut {
            enabled: newItemDialog.visible
            sequence: "Escape"
            onActivated: {
                newItemDialog.close();
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 170
            }
        }

        function open() {
            newItemDialog.visible = true;
            Qt.callLater(() => {
                newItemDialog.opacity = 1.0;
            });
        }

        function close() {
            newItemDialog.opacity = 0;
            closeDialog.restart();
        }

        Timer {
            id: closeDialog
            running: false
            repeat: false
            interval: 200
            onTriggered: {
                newItemDialog.visible = false;
            }
        }

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#ee000000"
            }
            GradientStop {
                position: 0.4
                color: '#ee151517'
            }
            GradientStop {
                position: 0.6
                color: '#ee262527'
            }
            GradientStop {
                position: 0.7
                color: '#ee201f21'
            }
            GradientStop {
                position: 1.0
                color: "#ee000000"
            }
        }

        MultiEffect {
            source: newItemDialog
            blurEnabled: true
            blur: 0.7
        }

        Rectangle {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: sidebarRect.width / 2
            width: containerRect.globalScaleWidth + containerRect.globalScaleWidth / 25
            height: 140 + containerRect.globalScaleWidth / 27
            radius: 30
            color: Parameters.pressedButtonBg

            GridLayout {
                columns: 4
                rows: 3
                anchors.centerIn: parent
                width: containerRect.globalScaleWidth
                columnSpacing: 1
                rowSpacing: 2

                Rectangle {
                    Layout.fillWidth: true
                    Layout.columnSpan: 4
                    Layout.preferredHeight: 55
                    color: Parameters.mainHighlightBg
                    topLeftRadius: 15
                    topRightRadius: 15

                    Text {
                        anchors.centerIn: parent
                        text: "Adicionar Novo Item"
                        color: Parameters.mainBgColor
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 26
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    id: fNameRect
                    Layout.horizontalStretchFactor: 3
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.IBeamCursor
                        onClicked: addFName.forceActiveFocus()

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
                            font.styleName: "Medium"
                            font.pixelSize: fNameRect.height * 0.6
                            placeholderText: "Nome do Produto"
                            validator: RegularExpressionValidator {
                                regularExpression: /(.|\s)*\S(.|\s)*/
                            }
                            focus: true
                        }
                    }
                }

                Rectangle {
                    id: fQuantRect
                    Layout.horizontalStretchFactor: 1
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.IBeamCursor
                        onClicked: addFQuant.forceActiveFocus()

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
                            font.styleName: "Medium"
                            font.pixelSize: fQuantRect.height * 0.54
                            placeholderText: "Quantidade"
                            validator: RegularExpressionValidator {
                                regularExpression: /([\d])+/
                            }
                            focus: true
                        }
                    }
                }

                Rectangle {
                    id: fCostRect
                    Layout.horizontalStretchFactor: 2
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.IBeamCursor
                        onClicked: addFCost.forceActiveFocus()

                        RowLayout {
                            anchors.fill: parent
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: 3
                                text: "R$"
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: fCostRect.height * 0.5
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 8
                                color: "#000000"
                            }

                            TextField {
                                id: addFCost
                                Layout.alignment: Qt.AlignVCenter
                                background: Rectangle {
                                    color: "transparent"
                                }
                                Layout.fillWidth: true
                                Layout.rightMargin: 4
                                Layout.topMargin: 2
                                Layout.bottomMargin: 2
                                color: "#000000"
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: fCostRect.height * 0.54
                                placeholderText: "Valor (Custo)"
                                validator: RegularExpressionValidator {
                                    regularExpression: /([\d])+([,.])*([\d]*)+/
                                }
                                focus: true
                            }
                        }
                    }
                }

                Rectangle {
                    id: fSellRect
                    Layout.horizontalStretchFactor: 2
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.IBeamCursor
                        onClicked: addFSell.forceActiveFocus()

                        RowLayout {
                            anchors.fill: parent
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: 3
                                text: "R$"
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: fSellRect.height * 0.5
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 8
                                color: "#000000"
                            }

                            TextField {
                                id: addFSell
                                Layout.alignment: Qt.AlignVCenter
                                background: Rectangle {
                                    color: "transparent"
                                }
                                Layout.fillWidth: true
                                Layout.rightMargin: 4
                                Layout.topMargin: 2
                                Layout.bottomMargin: 2
                                color: "#000000"
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: fSellRect.height * 0.54
                                placeholderText: "Valor (Venda)"
                                validator: RegularExpressionValidator {
                                    regularExpression: /([\d])+([,.])*([\d]*)+/
                                }
                                focus: true
                            }
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
                            id: addSubmit
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: false
                            text: "OK"
                            implicitWidth: 74
                            implicitHeight: 34

                            onClicked: {
                                if (addFName.acceptableInput && addFQuant.acceptableInput && addFCost.acceptableInput && addFSell.acceptableInput) {
                                    stock_model.append(addFName.text, Number(addFQuant.text), parseFloat(addFCost.text.replace(",", ".")), parseFloat(addFSell.text.replace(",", ".")));

                                    newItemDialog.close();

                                    containerRect.itemAction();
                                    addFName.clear();
                                    addFQuant.clear();
                                    addFCost.clear();
                                    addFSell.clear();
                                }
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pointSize: 12
                                text: addSubmit.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 74
                                implicitHeight: 34
                                radius: Parameters.defaultRadius * 2
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
                                newItemDialog.close();
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pointSize: 12
                                text: addCancel.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 82
                                implicitHeight: 34
                                radius: Parameters.defaultRadius * 2
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

        Shortcut {
            enabled: editItemDialog.visible
            sequence: "Escape"
            onActivated: {
                editItemDialog.close();
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 170
            }
        }

        function open() {
            editItemDialog.visible = true;
            Qt.callLater(() => {
                editItemDialog.opacity = 1.0;
            });
        }

        function close() {
            editItemDialog.opacity = 0;
            closeEditDialog.restart();
        }

        Timer {
            id: closeEditDialog
            running: false
            repeat: false
            interval: 200
            onTriggered: {
                editItemDialog.visible = false;
            }
        }

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#ee000000"
            }
            GradientStop {
                position: 0.4
                color: '#ee151517'
            }
            GradientStop {
                position: 0.6
                color: '#ee262527'
            }
            GradientStop {
                position: 0.7
                color: '#ee201f21'
            }
            GradientStop {
                position: 1.0
                color: "#ee000000"
            }
        }

        MultiEffect {
            source: editItemDialog
            blurEnabled: true
            blur: 0.7
        }

        Rectangle {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: sidebarRect.width / 2
            width: containerRect.globalScaleWidth + containerRect.globalScaleWidth / 25
            height: 180 + containerRect.globalScaleWidth / 27
            radius: 30
            color: Parameters.pressedButtonBg

            GridLayout {
                columns: 4
                rows: 4
                anchors.centerIn: parent
                width: containerRect.globalScaleWidth
                columnSpacing: 1
                rowSpacing: 2

                Rectangle {
                    Layout.fillWidth: true
                    Layout.columnSpan: 4
                    Layout.preferredHeight: 55
                    color: Parameters.mainHighlightBg
                    topLeftRadius: 15
                    topRightRadius: 15

                    Text {
                        anchors.centerIn: parent
                        text: "Editar Item"
                        color: Parameters.mainBgColor
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 26
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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
                        id: editNameText
                        anchors.centerIn: parent
                        color: '#000000'
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Nome do Produto"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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

                    Text {
                        id: editQuantText
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Quantidade"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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

                    Text {
                        id: editCostText
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Preço de Custo"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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

                    Text {
                        id: editSellText
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Preço de Venda"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    id: efNameRect
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
                        font.pixelSize: efNameRect.height * 0.6
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        text: stock_model.get(editItemDialog.callRow, "").name
                    }
                }

                Rectangle {
                    id: efQuantRect
                    Layout.horizontalStretchFactor: 1
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.IBeamCursor
                        onClicked: editFQuant.forceActiveFocus()

                        TextInput {
                            id: editFQuant
                            anchors.centerIn: parent
                            color: "#000000"
                            font.family: Parameters.defaultFont
                            font.styleName: "Medium"
                            text: stock_model.get(editItemDialog.callRow, "").quantity
                            font.pixelSize: efQuantRect.height * 0.54
                            validator: RegularExpressionValidator {
                                regularExpression: /([\d])+/
                            }
                            focus: true
                        }
                    }
                }

                Rectangle {
                    id: efCostRect
                    Layout.horizontalStretchFactor: 2
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.IBeamCursor
                        onClicked: editFCost.forceActiveFocus()

                        RowLayout {
                            anchors.fill: parent
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: 3
                                text: "R$"
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: efCostRect.height * 0.5
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 8
                                color: "#000000"
                            }

                            TextInput {
                                id: editFCost
                                color: "#000000"
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                text: parseFloat(stock_model.get(editItemDialog.callRow, "").buyPrice).toFixed(2).toString().replace(".", ",")
                                font.pixelSize: efCostRect.height * 0.54
                                validator: RegularExpressionValidator {
                                    regularExpression: /([\d])+([,.])*([\d]*)+/
                                }
                                focus: true
                            }
                        }
                    }
                }

                Rectangle {
                    id: efSellRect
                    Layout.horizontalStretchFactor: 2
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.IBeamCursor
                        onClicked: editFSell.forceActiveFocus()

                        RowLayout {
                            anchors.fill: parent
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: 3
                                text: "R$"
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pixelSize: efSellRect.height * 0.5
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 8
                                color: "#000000"
                            }

                            TextInput {
                                id: editFSell
                                color: "#000000"
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                text: parseFloat(stock_model.get(editItemDialog.callRow, "").sellPrice).toFixed(2).toString().replace(".", ",")
                                font.pixelSize: efSellRect.height * 0.54
                                validator: RegularExpressionValidator {
                                    regularExpression: /([\d])+([,.])*([\d]*)+/
                                }
                                focus: true
                            }
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
                                    stock_model.edit(editItemDialog.callRow, Number(editFQuant.displayText), parseFloat(editFCost.displayText.replace(",", ".")), parseFloat(editFSell.displayText.replace(",", ".")));

                                    containerRect.itemAction();

                                    editItemDialog.close();
                                }
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pointSize: 12
                                text: editSubmit.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 74
                                implicitHeight: 34
                                radius: Parameters.defaultRadius * 2
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
                                editItemDialog.close();
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pointSize: 12
                                text: editCancel.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 82
                                implicitHeight: 34
                                radius: Parameters.defaultRadius * 2
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

        Shortcut {
            enabled: rmItemDialog.visible
            sequence: "Escape"
            onActivated: {
                rmItemDialog.close();
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 170
            }
        }

        function open() {
            rmItemDialog.visible = true;
            Qt.callLater(() => {
                rmItemDialog.opacity = 1.0;
            });
        }

        function close() {
            rmItemDialog.opacity = 0;
            closeRemoveDialog.restart();
        }

        Timer {
            id: closeRemoveDialog
            running: false
            repeat: false
            interval: 200
            onTriggered: {
                rmItemDialog.visible = false;
            }
        }

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#ee000000"
            }
            GradientStop {
                position: 0.4
                color: '#ee151517'
            }
            GradientStop {
                position: 0.6
                color: '#ee262527'
            }
            GradientStop {
                position: 0.7
                color: '#ee201f21'
            }
            GradientStop {
                position: 1.0
                color: "#ee000000"
            }
        }

        MultiEffect {
            source: rmItemDialog
            blurEnabled: true
            blur: 0.7
        }

        Rectangle {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: sidebarRect.width / 2
            width: containerRect.globalScaleWidth + containerRect.globalScaleWidth / 25
            height: 180 + containerRect.globalScaleWidth / 27
            radius: 30
            color: Parameters.pressedButtonBg

            GridLayout {
                columns: 4
                rows: 4
                anchors.centerIn: parent
                width: containerRect.globalScaleWidth
                columnSpacing: 1
                rowSpacing: 2

                Rectangle {
                    Layout.fillWidth: true
                    Layout.columnSpan: 4
                    Layout.preferredHeight: 55
                    color: Parameters.mainHighlightBg
                    topLeftRadius: 15
                    topRightRadius: 15

                    Text {
                        anchors.centerIn: parent
                        text: "Remover Item"
                        color: Parameters.mainBgColor
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 26
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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
                        anchors.centerIn: parent
                        color: '#000000'
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Nome do Produto"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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

                    Text {
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Quantidade"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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

                    Text {
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Custo"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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

                    Text {
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pixelSize: 18
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 7
                        text: "Venda"
                        width: parent.width - 4
                        height: parent.height - 4
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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
                        font.pointSize: parent.height * 0.6
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
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

                    Text {
                        id: removeFQuant
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pointSize: parent.height * 0.54
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        text: stock_model.get(rmItemDialog.callRm, "").quantity
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

                    Text {
                        id: removeFCost
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pointSize: parent.height * 0.54
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        text: stock_model.get(rmItemDialog.callRm, "").buyPrice
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

                    Text {
                        id: removeFSell
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Medium"
                        font.pointSize: parent.height * 0.54
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        text: stock_model.get(rmItemDialog.callRm, "").sellPrice
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
                                stock_model.eliminate(parseInt(rmItemDialog.callRm));

                                rmItemDialog.close();

                                containerRect.itemAction();
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pointSize: 12
                                text: removeSubmit.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 74
                                implicitHeight: 34
                                radius: Parameters.defaultRadius * 2
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
                                rmItemDialog.close();
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Medium"
                                font.pointSize: 12
                                text: removeCancel.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 82
                                implicitHeight: 34
                                radius: Parameters.defaultRadius * 2
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
}
