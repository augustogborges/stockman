pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Effects
import QtQuick.Layouts
import QtQml
import QtGraphs

import Stocker
import Authenticator

Rectangle {
    id: containerRect
    anchors.fill: parent
    color: Parameters.mainBgColor

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
        }

        function onItemAction() {
            containerRect.reloadUI();
        }
    }

    function reloadUI() {
        root.sModel = "";
        stock_model.reloadDB();
        productsCount = stock_model.rowCount();
        usersCount = user_model.rowCount();
        listView.model = stock_model.getEffectiveCount(root.search);
        root.sModel = stock_model;
        stockProfitList.model = "";
        stockProfitList.model = Math.min(root.productsCount, 10);
        stockFillList.model = "";
        stockFillList.model = Math.min(root.productsCount, 10);
        if (stockOnlyDash.visible || root.loggedUser[1] == 2) {
            stockFillListSOD.model = "";
            stockFillListSOD.model = root.productsCount;
            stockFillChartSOD.regenGraph();
        }
        stockProfitChart.regenGraph();
        stockFillChart.regenGraph();
        smallestIndProfits.updateLowProfits();
        biggestIndProfits.updateHighProfits();
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
            Layout.preferredWidth: containerRect.width / 10.6
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
                    bottomMargin: containerRect.height - 315
                }

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: logoContainer.height
                    Layout.fillWidth: true
                    Layout.margins: 8

                    Rectangle {
                        id: logoContainer
                        anchors.centerIn: parent
                        height: 100
                        width: parent.width
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
                        id: logoRect
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
                                font.pointSize: 22
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            Text {
                                id: logoText
                                Layout.alignment: Qt.AlignVCenter
                                text: "Stockman"
                                font.family: Parameters.defaultFont
                                font.styleName: "Condensed Medium"
                                font.underline: false
                                font.pointSize: 18
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.2)
                            }
                        }
                    }
                }

                Item {
                    Layout.preferredHeight: 16
                }

                TabRect {
                    id: dashButton
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
                    buttonIndex: 1
                }

                TabRect {
                    id: usersButton
                    buttonIndex: 2
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
                                font.family: Parameters.thinFont
                                font.styleName: "Bold"
                                font.pixelSize: dashContainer.height * 0.04
                                color: "#000000"
                            }

                            Text {
                                Layout.alignment: Qt.AlignLeft
                                Layout.fillHeight: false
                                text: "Resumo Geral  |  " + new Date().toLocaleTimeString(Qt.locale("pt_BR"), Locale.ShortFormat) + " ⋅ " + new Date().toLocaleDateString(Qt.locale("pt_BR"), Locale.ShortFormat)
                                font.family: Parameters.defaultFont
                                font.styleName: "Condensed Medium"
                                font.pixelSize: dashContainer.height * 0.015
                                color: "#303030"
                            }

                            Item {
                                height: 10
                            }

                            Rectangle {
                                id: stockOnlyDash
                                visible: false
                                anchors.fill: parent
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
                                                    font.styleName: "Condensed Medium"
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
                                                            font.pixelSize: lowQuantityDisplayContainerSOD.height * 0.5
                                                            minimumPixelSize: 8
                                                            fontSizeMode: Text.Fit
                                                            text: ""
                                                            font.family: Parameters.iconFont
                                                            color: "#000000"
                                                        }

                                                        Text {
                                                            Layout.alignment: Qt.AlignVCenter
                                                            Layout.fillWidth: false
                                                            font.pixelSize: lowQuantityDisplayContainerSOD.height * 0.35
                                                            minimumPixelSize: 8
                                                            fontSizeMode: Text.Fit
                                                            text: stock_model.getLowQuantityTotal(containerRect.lowItemThreshold) + " itens precisam de reposição"
                                                            font.family: Parameters.thinFont
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
                                                                        font.styleName: "Condensed Medium"
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
                                                                labelFont: Parameters.defaultFont
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
                                                                        font.styleName: "Condensed Medium"
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
                                                        font.family: Parameters.thinFont
                                                        font.pixelSize: stockFillContainerSOD.height * 0.036
                                                        text: "Total de produtos:"
                                                        color: "#000000"
                                                    }

                                                    Text {
                                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                        font.family: Parameters.defaultFont
                                                        font.styleName: "Condensed Medium"
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
                                                        font.family: Parameters.thinFont
                                                        font.pixelSize: stockFillContainerSOD.height * 0.036
                                                        text: "Tipos de produtos:"
                                                        color: "#000000"
                                                    }

                                                    Text {
                                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                        font.family: Parameters.defaultFont
                                                        font.styleName: "Condensed Medium"
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

                                Item {
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
                                            anchors.topMargin: parent.height * 0.05
                                            anchors.bottomMargin: parent.height * 0.05
                                            anchors.leftMargin: parent.width * 0.1
                                            anchors.rightMargin: parent.width * 0.1

                                            ColumnLayout {
                                                Layout.fillHeight: true
                                                Layout.fillWidth: false
                                                Layout.preferredWidth: profitDistContainer.width * 0.4

                                                Text {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: false
                                                    font.pixelSize: parent.height * 0.05
                                                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                                                    text: "Distribuição de Lucro Potencial no Inventário"
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Condensed Medium"
                                                    color: "#000000"
                                                }

                                                Rectangle {
                                                    id: profitDistInfoContainer
                                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    Layout.topMargin: parent.height * 0.04
                                                    Layout.bottomMargin: parent.height * 0.04
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

                                                                Rectangle {
                                                                    id: profitColorBallDelegate
                                                                    Layout.fillHeight: false
                                                                    Layout.fillWidth: false
                                                                    Layout.alignment: Qt.AlignVCenter
                                                                    Layout.preferredHeight: profitDistInfoContainer.height * 0.065
                                                                    Layout.preferredWidth: height
                                                                    radius: height / 2
                                                                    color: firstTab.graphColors[index]
                                                                }

                                                                Text {
                                                                    Layout.fillWidth: true
                                                                    Layout.rightMargin: 12
                                                                    Layout.fillHeight: false
                                                                    Layout.alignment: Qt.AlignVCenter
                                                                    font.family: Parameters.defaultFont
                                                                    font.styleName: "Condensed Medium"
                                                                    font.pixelSize: profitDistInfoContainer.height * 0.08
                                                                    elide: Text.ElideRight
                                                                    color: "#000000"
                                                                    text: stock_model.getSortedByTotalProfit(index).name
                                                                }

                                                                Text {
                                                                    Layout.fillWidth: false
                                                                    Layout.fillHeight: false
                                                                    Layout.alignment: Qt.AlignVCenter
                                                                    font.family: Parameters.defaultFont
                                                                    font.styleName: "Condensed Medium"
                                                                    font.pixelSize: profitDistInfoContainer.height * 0.073
                                                                    color: "#000000"
                                                                    text: "R$" + stock_model.getSortedByTotalProfit(index).profit.toFixed(2).toString().replace(".", ",")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillHeight: true
                                                Layout.fillWidth: false
                                                Layout.preferredWidth: height
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
                                                        labelFont: Parameters.defaultFont
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
                                                            slice.labelVisible = true;
                                                            if (number >= 15) {
                                                                slice.labelPosition = PieSlice.LabelPosition.InsideHorizontal;
                                                            } else {
                                                                slice.labelPosition = PieSlice.LabelPosition.Outside;
                                                                slice.labelArmLengthFactor = 0.05;
                                                            }
                                                        }
                                                    }
                                                    Component.onCompleted: regenGraph()
                                                }
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
                                                Layout.preferredHeight: stockFillContainer.height * 0.08

                                                Text {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: false
                                                    font.pixelSize: stockFillContainer.height * 0.05
                                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                    text: "Composição do Estoque"
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Condensed Medium"
                                                    color: "#000000"
                                                }

                                                Rectangle {
                                                    id: lowQuantityDisplayContainer
                                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                                    Layout.preferredWidth: stockFillContainer.width * 0.4
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
                                                            font.pixelSize: lowQuantityDisplayContainer.height * 0.6
                                                            text: ""
                                                            font.family: Parameters.iconFont
                                                            color: "#000000"
                                                        }

                                                        Text {
                                                            Layout.alignment: Qt.AlignVCenter
                                                            Layout.fillWidth: false
                                                            font.pixelSize: lowQuantityDisplayContainer.height * 0.45
                                                            text: stock_model.getLowQuantityTotal(containerRect.lowItemThreshold) + " itens precisam de reposição"
                                                            font.family: Parameters.thinFont
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
                                                spacing: stockFillContainer.width * 0.027

                                                Item {
                                                    Layout.fillHeight: true
                                                    Layout.fillWidth: false
                                                    Layout.preferredWidth: stockFillContainer.width / 3.5

                                                    Rectangle {
                                                        id: stockFillGraphList
                                                        anchors.fill: parent
                                                        radius: Parameters.defaultRadius
                                                        color: "white"
                                                        border.width: 1
                                                        border.color: Parameters.lightBorder
                                                        clip: true

                                                        ListView {
                                                            id: stockFillList
                                                            anchors.fill: parent
                                                            anchors.leftMargin: parent.width * 0.03
                                                            anchors.rightMargin: parent.width * 0.03
                                                            anchors.topMargin: parent.height * 0.02
                                                            anchors.bottomMargin: parent.height * 0.02
                                                            orientation: ListView.Vertical
                                                            boundsBehavior: ListView.StopAtBounds

                                                            model: Math.min(containerRect.productsCount, 10)

                                                            delegate: Rectangle {
                                                                required property int index
                                                                anchors.left: parent.left
                                                                anchors.right: parent.right
                                                                height: stockFillGraphList.height * 0.13
                                                                color: "transparent"

                                                                RowLayout {
                                                                    anchors.fill: parent

                                                                    Rectangle {
                                                                        id: fillColorBallDelegate
                                                                        Layout.fillHeight: false
                                                                        Layout.fillWidth: false
                                                                        Layout.alignment: Qt.AlignVCenter
                                                                        Layout.preferredHeight: stockFillGraphList.height * 0.057
                                                                        Layout.preferredWidth: height
                                                                        radius: height / 2
                                                                        color: firstTab.graphColors[index]
                                                                    }

                                                                    Text {
                                                                        Layout.fillWidth: true
                                                                        Layout.fillHeight: false
                                                                        Layout.alignment: Qt.AlignVCenter
                                                                        font.family: Parameters.defaultFont
                                                                        font.styleName: "Condensed Medium"
                                                                        font.pixelSize: stockFillGraphList.height * 0.067
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
                                                    Layout.fillWidth: true

                                                    Rectangle {
                                                        id: stockFillGraph
                                                        anchors.fill: parent
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
                                                                labelFont: Parameters.defaultFont
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
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: false
                                                Layout.preferredHeight: stockFillContainer.height * 0.15

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
                                                        font.family: Parameters.thinFont
                                                        font.pixelSize: stockFillContainer.height * 0.036
                                                        text: "Total de produtos:"
                                                        color: "#000000"
                                                    }

                                                    Text {
                                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                        font.family: Parameters.defaultFont
                                                        font.styleName: "Condensed Medium"
                                                        font.pixelSize: stockFillContainer.height * 0.05
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
                                                        font.family: Parameters.thinFont
                                                        font.pixelSize: stockFillContainer.height * 0.036
                                                        text: "Tipos de produtos:"
                                                        color: "#000000"
                                                    }

                                                    Text {
                                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                                        font.family: Parameters.defaultFont
                                                        font.styleName: "Condensed Medium"
                                                        font.pixelSize: stockFillContainer.height * 0.05
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

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.topMargin: parent.height * 0.05
                                            anchors.bottomMargin: parent.height * 0.05
                                            anchors.leftMargin: parent.width * 0.05
                                            anchors.rightMargin: parent.width * 0.05

                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                font.family: Parameters.defaultFont
                                                font.styleName: "Condensed Medium"
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
                                                    anchors.centerIn: parent
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Condensed Medium"
                                                    font.pixelSize: parent.height * 0.33
                                                    text: "Receita Total: R$" + stock_model.getTotalStockSell().toFixed(2).toString().replace(".", ",")
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
                                                    anchors.centerIn: parent
                                                    font.family: Parameters.defaultFont
                                                    font.styleName: "Condensed Medium"
                                                    font.pixelSize: parent.height * 0.33
                                                    text: "Receita Total: R$" + stock_model.getTotalStockCost().toFixed(2).toString().replace(".", ",")
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
                                                font.styleName: "Condensed Medium"
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
                                                    font.styleName: "Condensed Medium"
                                                    font.pixelSize: parent.height * 0.33
                                                    text: biggestIndProfits.highestName1 + ": R$" + biggestIndProfits.highestProfit1
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
                                                    font.styleName: "Condensed Medium"
                                                    font.pixelSize: parent.height * 0.33
                                                    text: biggestIndProfits.highestName2 + ": R$" + biggestIndProfits.highestProfit2
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
                                                font.styleName: "Condensed Medium"
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
                                                    font.styleName: "Condensed Medium"
                                                    font.pixelSize: parent.height * 0.33
                                                    text: smallestIndProfits.lowestName1 + ": R$" + smallestIndProfits.lowestProfit1
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
                                                    font.styleName: "Condensed Medium"
                                                    font.pixelSize: parent.height * 0.33
                                                    text: smallestIndProfits.lowestName2 + ": R$" + smallestIndProfits.lowestProfit2
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
                                    radius: 30
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
                                    font.styleName: "Condensed Medium"
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
                                                font.styleName: "Condensed Medium"
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
                                                font.styleName: "Condensed Medium"
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
                                                font.styleName: "Condensed Medium"
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
                                                font.styleName: "Condensed Medium"
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
                                                font.styleName: "Condensed Medium"
                                                font.pointSize: initColumn.initCFontSize
                                                text: "Valor (Lucro)"
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
                            columns: 2
                            rows: 2

                            Text {
                                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                                font.family: Parameters.thinFont
                                font.styleName: "Bold"
                                text: "Usuários"
                                font.pixelSize: 22
                                color: "#000000"
                            }

                            Rectangle {
                                id: newUserButton
                                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                                Layout.preferredWidth: thirdTab.width / 12
                                Layout.preferredHeight: thirdTab.height / 30
                                radius: Parameters.defaultRadius

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
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Condensed Medium"
                                        font.pointSize: 16
                                        text: "+"
                                        color: "#ffffff"
                                        //style: Text.Outline
                                    }

                                    Text {
                                        font.family: Parameters.defaultFont
                                        font.styleName: "Condensed Medium"
                                        font.pointSize: 11
                                        text: "Novo Usuário"
                                        color: "#ffffff"
                                        //style: Text.Outline
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
                                Layout.columnSpan: 2
                                Layout.alignment: Qt.AlignLeft
                                font.family: Parameters.defaultFont
                                font.styleName: "Condensed Medium"
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
                                        font.styleName: "Condensed Medium"
                                        font.pixelSize: (userRect1.width * 0.12 + userRect1.height * 0.12) / 2
                                        text: "Total de Usuários"
                                        color: "#000000"
                                    }

                                    Text {
                                        Layout.rowSpan: 1
                                        font.family: Parameters.thinFont
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
                                        font.styleName: "Condensed Medium"
                                        font.pixelSize: (userRect2.width * 0.12 + userRect2.height * 0.12) / 2
                                        text: "Supervisão"
                                        color: "#000000"
                                    }

                                    Text {
                                        Layout.rowSpan: 1
                                        font.family: Parameters.thinFont
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
                                        font.styleName: "Condensed Medium"
                                        font.pixelSize: (userRect3.width * 0.12 + userRect3.height * 0.12) / 2
                                        text: "Estoque"
                                        color: "#000000"
                                    }

                                    Text {
                                        Layout.rowSpan: 1
                                        font.family: Parameters.thinFont
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
                                        font.styleName: "Condensed Medium"
                                        font.pixelSize: (userRect4.width * 0.12 + userRect4.height * 0.12) / 2
                                        text: "Financeiro"
                                        color: "#000000"
                                    }

                                    Text {
                                        Layout.rowSpan: 1
                                        font.family: Parameters.thinFont
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
                                                    font.styleName: "Condensed Medium"
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
                                                font.styleName: "Condensed Medium"
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
                                                font.styleName: "Condensed Medium"
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
                                            font.styleName: "Condensed Medium"
                                            font.pixelSize: userNameDisplay.height * 0.42
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
                                            font.styleName: "Condensed Medium"
                                            font.pixelSize: userNameDisplay.height * 0.42
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
                                            font.styleName: "Condensed Medium"
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
                                            font.styleName: "Condensed Medium"
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
                                                                font.styleName: "Condensed Medium"
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
                                                                    font.styleName: "Condensed Medium"
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
            width: childrenRect.width + 35
            height: childrenRect.height + 30
            radius: 30
            color: Parameters.pressedButtonBg

            ColumnLayout {
                anchors.centerIn: parent
                width: containerRect.width * 0.5
                spacing: containerRect.height * 0.006

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
                        font.styleName: "Condensed Medium"
                        font.pointSize: 18
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: containerRect.width * 0.012
                    Layout.rightMargin: containerRect.width * 0.012
                    spacing: containerRect.width * 0.001

                    Rectangle {
                        id: addUNameContainer
                        Layout.fillWidth: true
                        Layout.preferredWidth: containerRect.width * 0.3
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
                        Layout.preferredWidth: containerRect.width * 0.12
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
                                font.styleName: "Condensed Medium"
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
                            font.styleName: "Condensed Medium"
                            font.pixelSize: userLevelCombo.height * 0.47
                            color: userLevelCombo.displayText == "Cargo" ? "#bbbbbb" : userLevelCombo.popup.visible ? "#666666" : "#000000"
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            id: comboBg
                            Layout.fillWidth: true
                            Layout.preferredWidth: containerRect.width * 0.12
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
                    Layout.fillWidth: true
                    Layout.leftMargin: (containerRect.width * 0.5 - passwordWarn.width) / 2.3
                    Layout.rightMargin: (containerRect.width * 0.5 - passwordWarn.width) / 2.3
                    Layout.preferredHeight: 40
                    color: Parameters.shadeBgColor
                    border.width: 2
                    border.color: Parameters.lowCashRed
                    radius: 15

                    Text {
                        id: passwordWarn
                        anchors.centerIn: parent
                        font.family: Parameters.defaultFont
                        font.styleName: "Condensed Medium"
                        font.pixelSize: parent.height * 0.45
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        wrapMode: Text.Wrap
                        color: "#454545"
                        text: "A senha inicial será definida a seguir. O nome de usuário será criado a partir do nome completo."
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
                                font.styleName: "Condensed Medium"
                                font.pointSize: 12
                                text: addUSubmit.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 74
                                implicitHeight: 34
                                radius: searchContainer.radius
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
                                font.styleName: "Condensed Medium"
                                font.pointSize: 12
                                text: addUCancel.text
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                            }

                            background: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 82
                                implicitHeight: 34
                                radius: searchContainer.radius
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
                width: containerRect.width * 0.5 + 35
                height: tempMasterColumn.implicitHeight + 30
                radius: 30
                color: Parameters.pressedButtonBg

                ColumnLayout {
                    id: tempMasterColumn
                    anchors.centerIn: parent
                    width: containerRect.width * 0.5
                    spacing: containerRect.height * 0.006

                    Rectangle {
                        Layout.fillWidth: true
                        height: 55
                        color: Parameters.mainHighlightBg
                        topLeftRadius: 15
                        topRightRadius: 15

                        Text {
                            anchors.centerIn: parent
                            text: "Senha temporária do novo usuário"
                            color: Parameters.mainBgColor
                            font.family: Parameters.defaultFont
                            font.styleName: "Condensed Medium"
                            font.pointSize: 18
                            fontSizeMode: Text.Fit
                            minimumPixelSize: 10
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: containerRect.width * 0.1
                        Layout.rightMargin: containerRect.width * 0.1
                        Layout.preferredHeight: warnColumn.implicitHeight + containerRect.height * 0.04
                        color: Parameters.shadeBgColor
                        border.width: 2
                        border.color: Parameters.lowCashRed
                        radius: 15

                        ColumnLayout {
                            id: warnColumn
                            anchors.centerIn: parent
                            implicitWidth: parent.width - containerRect.width * 0.05

                            Text {
                                id: showUsernameDisplay
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Condensed Medium"
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
                                font.styleName: "Condensed Medium"
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
                                font.styleName: "Condensed Medium"
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
                                font.styleName: "Condensed Medium"
                                font.pixelSize: showUsernameDisplay.font.pixelSize
                                color: '#500d0d'
                                text: newUserDialog.userData.plainPasswd
                                wrapMode: Text.Wrap
                                Layout.preferredWidth: parent.implicitWidth
                            }

                            Text {
                                id: showTempPasswd2
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Condensed Medium"
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
                                font.styleName: "Condensed Medium"
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
                                    });
                                }

                                contentItem: Text {
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: Parameters.defaultFont
                                    font.styleName: "Condensed Medium"
                                    font.pointSize: 12
                                    text: addUSubmit.text
                                    color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                }

                                background: Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    implicitWidth: 74
                                    implicitHeight: 34
                                    radius: searchContainer.radius
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
            width: childrenRect.width + 35
            height: childrenRect.height + 30
            radius: 30
            color: Parameters.pressedButtonBg

            GridLayout {
                columns: 4
                rows: 3
                anchors.centerIn: parent
                width: containerRect.width * 0.67
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
                        font.styleName: "Condensed Medium"
                        font.pointSize: 18
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
                            font.styleName: "Condensed Medium"
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
                            font.styleName: "Condensed Medium"
                            font.pixelSize: fQuantRect.height * 0.54
                            placeholderText: "Valor (Venda)"
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
                            font.styleName: "Condensed Medium"
                            font.pixelSize: fCostRect.height * 0.54
                            placeholderText: "Valor (Venda)"
                            validator: RegularExpressionValidator {
                                regularExpression: /([\d])+([,.])*([\d]*)+/
                            }
                            focus: true
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
                                font.styleName: "Condensed Medium"
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
                                font.styleName: "Condensed Medium"
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
                            text: "OK" //"Adicionar"
                            implicitWidth: 74
                            implicitHeight: 34

                            onClicked: {
                                if (addFName.acceptableInput && addFQuant.acceptableInput && addFCost.acceptableInput && addFSell.acceptableInput) {
                                    stock_model.append(addFName.text, Number(addFQuant.text), parseFloat(addFCost.text), parseFloat(addFSell.text.replace(",", ".")));

                                    newItemDialog.close();

                                    containerRect.itemAction();
                                }
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Condensed Medium"
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
                                newItemDialog.close();
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Condensed Medium"
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
            width: childrenRect.width + 35
            height: childrenRect.height + 30
            radius: 30
            color: Parameters.pressedButtonBg

            GridLayout {
                columns: 4
                rows: 4
                anchors.centerIn: parent
                width: containerRect.width * 0.67
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
                        font.styleName: "Condensed Medium"
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
                        id: editNameText
                        anchors.centerIn: parent
                        color: '#000000'
                        font.family: Parameters.defaultFont
                        font.styleName: "Condensed Medium"
                        font.pointSize: 15
                        text: "Nome do Produto"
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
                        font.styleName: "Condensed Medium"
                        font.pointSize: 15
                        text: "Quantidade"
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
                        font.styleName: "Condensed Medium"
                        font.pointSize: 15
                        text: "Preço de Custo"
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
                        font.styleName: "Condensed Medium"
                        font.pointSize: 15
                        text: "Preço de Venda"
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
                            font.styleName: "Condensed Medium"
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

                        TextInput {
                            id: editFCost
                            anchors.centerIn: parent
                            color: "#000000"
                            font.family: Parameters.defaultFont
                            font.styleName: "Condensed Medium"
                            text: stock_model.get(editItemDialog.callRow, "").buyPrice
                            font.pixelSize: efCostRect.height * 0.54
                            validator: RegularExpressionValidator {
                                regularExpression: /([\d])+([,.])*([\d]*)+/
                            }
                            focus: true
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

                        TextInput {
                            id: editFSell
                            anchors.centerIn: parent
                            color: "#000000"
                            font.family: Parameters.defaultFont
                            font.styleName: "Condensed Medium"
                            text: stock_model.get(editItemDialog.callRow, "").sellPrice
                            font.pixelSize: efSellRect.height * 0.54
                            validator: RegularExpressionValidator {
                                regularExpression: /([\d])+([,.])*([\d]*)+/
                            }
                            focus: true
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
                                    stock_model.edit(editItemDialog.callRow, Number(editFQuant.displayText), Number(editFCost.displayText), Number(editFSell.displayText));

                                    editItemDialog.close();
                                }
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Condensed Medium"
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
                                editItemDialog.close();
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Condensed Medium"
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
            width: childrenRect.width + 35
            height: childrenRect.height + 30
            radius: 30
            color: Parameters.pressedButtonBg

            GridLayout {
                columns: 4
                rows: 4
                anchors.centerIn: parent
                width: containerRect.width * 0.67
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
                        font.styleName: "Condensed Medium"
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
                        anchors.centerIn: parent
                        color: '#000000'
                        font.family: Parameters.defaultFont
                        font.styleName: "Condensed Medium"
                        font.pointSize: parent.height * 0.44
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
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                    Text {
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Condensed Medium"
                        font.pointSize: parent.height * 0.44
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
                    color: Parameters.shadeBgColor
                    border.width: 1
                    border.color: Qt.darker(Parameters.mainHighlightBg, 2.5)

                    Text {
                        anchors.centerIn: parent
                        color: "#000000"
                        font.family: Parameters.defaultFont
                        font.styleName: "Condensed Medium"
                        font.pointSize: parent.height * 0.44
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        text: "Custo"
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
                        font.styleName: "Condensed Medium"
                        font.pointSize: parent.height * 0.44
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        text: "Venda"
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
                        font.styleName: "Condensed Medium"
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
                        font.styleName: "Condensed Medium"
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
                        font.styleName: "Condensed Medium"
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
                                font.styleName: "Condensed Medium"
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
                                rmItemDialog.close();
                            }

                            contentItem: Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Parameters.defaultFont
                                font.styleName: "Condensed Medium"
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
}
