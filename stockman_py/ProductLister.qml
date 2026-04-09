// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml
import Stocker

ItemDelegate {
    id: delegate
    anchors.left: parent.left
    anchors.right: parent.right
    checkable: true
    height: 40
    required property var sModel
    required property int index
    required property var searchTerm
    //required property var searcher

    /*Connections {
        target: searcher
        function onSearchChanged() {

        }
    }*/

    contentItem: RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        Layout.leftMargin: 0
        Layout.rightMargin: 0
        spacing: 0
        uniformCellSizes: false
        visible: childrenRect.visible

        Rectangle {
            Layout.horizontalStretchFactor: 3
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.preferredHeight: 40
            color: Parameters.shadeBgColor
            border.width: 1
            border.color: Parameters.mainHighlightBg
            visible: childrenRect.visible

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                spacing: 6

                Text {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    color: "#000000"
                    font.family: Parameters.altFont
                    font.styleName: "Medium"
                    font.pointSize: 14
                    visible: (text != undefined && text != null && text != "")
                    text: sModel.get(index, searchTerm).name
                }

                Button {
                    id: openOptButtons
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: false
                    text: ""
                    implicitWidth: 32
                    implicitHeight: 32

                    onClicked: {
                        optButtonsMenu.open()
                    }

                    HoverHandler {
                        enabled: parent.visible
                        cursorShape: Qt.PointingHandCursor
                    }

                    background: Rectangle {
                        radius: 16
                        color: Parameters.shadeHightlightBg
                    }

                    contentItem: Text {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: Parameters.iconFont
                        font.pointSize: 14
                        text: openOptButtons.text
                        color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                    }

                    Popup {
                        id: optButtonsMenu
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignRight
                        x: openOptButtons.width * 0.3
                        y: openOptButtons.height * 0.4
                        padding: 16
                        modal: true
                        focus: true
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

                        background: Rectangle {
                            topRightRadius: 20
                            bottomRightRadius: 20
                            bottomLeftRadius: 20
                            color: Parameters.shadeHightlightBg
                            visible: true
                            opacity: 1.0
                            scale: 0.9
                            border.width: 2
                            border.color: Parameters.highlightFg
                        }

                        contentItem: GridLayout {
                            id: menuGrid
                            rows: 2
                            columns: 2
                            rowSpacing: 6
                            columnSpacing: 6

                            Button {
                                id: editItem
                                Layout.alignment: Qt.AlignLeft
                                Layout.leftMargin: 2
                                Layout.fillWidth: false
                                text: ""
                                implicitWidth: 26
                                implicitHeight: 26

                                onClicked: {
                                    editItemDialog.callRow = index
                                    editItemDialog.open()
                                    optButtonsMenu.close()
                                }

                                HoverHandler {
                                    enabled: parent.visible
                                    cursorShape: Qt.PointingHandCursor
                                }

                                contentItem: Text {
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: Parameters.iconFontBold
                                    font.pointSize: 11
                                    text: editItem.text
                                    color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                }
                                
                                background: Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    implicitWidth: 26
                                    implicitHeight: 26
                                    radius: implicitHeight / 2
                                    color: editItem.down ? Parameters.pressedButtonBg : editItem.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                    border.width: 2
                                    border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                }
                            }

                            Text {
                                id: editButtonText
                                Layout.fillWidth: true
                                text: "Editar Item"
                                font.family: Parameters.defaultFont
                                font.pointSize: 12
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        editItemDialog.callRow = index
                                        editItemDialog.open()
                                        optButtonsMenu.close()
                                    }
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }

                            Button {
                                id: removeItem
                                Layout.alignment: Qt.AlignLeft
                                Layout.leftMargin: 2
                                Layout.fillWidth: false
                                text: ""
                                implicitWidth: 26
                                implicitHeight: 26

                                onClicked: {
                                    rmItemDialog.callRm = index
                                    rmItemDialog.open()
                                    optButtonsMenu.close()
                                }

                                HoverHandler {
                                    enabled: parent.visible
                                    cursorShape: Qt.PointingHandCursor
                                }

                                contentItem: Text {
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: Parameters.iconFontBold
                                    font.pointSize: 11
                                    text: removeItem.text
                                    color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                }
                                
                                background: Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    implicitWidth: 26
                                    implicitHeight: 26
                                    radius: implicitHeight / 2
                                    color: removeItem.down ? Parameters.pressedButtonBg : removeItem.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                    border.width: 2
                                    border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                }
                            }

                            Text {
                                id: removeButtonText
                                Layout.fillWidth: true
                                text: "Remover Item"
                                font.family: Parameters.defaultFont
                                font.pointSize: 12
                                color: Qt.lighter(Parameters.mainHighlightBg, 4.1)

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        rmItemDialog.callRm = index
                                        rmItemDialog.open()
                                        optButtonsMenu.close()
                                    }
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.horizontalStretchFactor: 1
            Layout.preferredWidth: 1
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Parameters.shadeBgColor
            border.width: 1
            border.color: Parameters.mainHighlightBg
            visible: childrenRect.visible

            Text {
                anchors.centerIn: parent
                color: "#000000"
                font.family: Parameters.thinFont
                font.pointSize: 14
                visible: (text != undefined && text != null && text != "")
                text: sModel.get(index, searchTerm).quantity
            }
        }

        Rectangle {
            Layout.horizontalStretchFactor: 2
            Layout.preferredWidth: 1
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Parameters.shadeBgColor
            border.width: 1
            border.color: Parameters.mainHighlightBg
            visible: childrenRect.visible

            Text {
                anchors.centerIn: parent
                color: "#000000"
                font.family: Parameters.thinFont
                font.pointSize: 14
                visible: (text != undefined && text != null && text != "")
                text: sModel.get(index, searchTerm).buyPrice
            }
        }

        Rectangle {
            Layout.horizontalStretchFactor: 2
            Layout.preferredWidth: 1
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Parameters.shadeBgColor
            border.width: 1
            border.color: Parameters.mainHighlightBg
            visible: childrenRect.visible

            Text {
                anchors.centerIn: parent
                color: "#000000"
                font.family: Parameters.thinFont
                font.pointSize: 14
                visible: (text != undefined && text != null && text != "")
                text: sModel.get(index, searchTerm).sellPrice
            }
        }

        Rectangle {
            Layout.horizontalStretchFactor: 2
            Layout.preferredWidth: 1
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Parameters.shadeBgColor
            border.width: 1
            border.color: Parameters.mainHighlightBg
            visible: childrenRect.visible

            Text {
                anchors.centerIn: parent
                color: "#000000"
                font.family: Parameters.thinFont
                font.pointSize: 14
                visible: (text != undefined && text != null && text != "")
                text: Number(sModel.get(index, searchTerm).sellPrice) - Number(sModel.get(index, searchTerm).buyPrice)
            }
        }
    }

    background: Rectangle {
        color: "transparent"
        width: parent.width
        height: parent.height
    }
}