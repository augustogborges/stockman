// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Stocker

ItemDelegate {
    id: delegate
    anchors.left: parent.left
    anchors.right: parent.right
    checkable: true
    height: 40
    property var sModel
    required property int index

    contentItem: RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        Layout.leftMargin: 0
        Layout.rightMargin: 0
        spacing: 0
        uniformCellSizes: false

        Rectangle {
            Layout.horizontalStretchFactor: 3
            //width: tableBox.implicitWidth * 0.5
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.preferredHeight: 40
            color: "#e0e0e0"
            border.width: 1
            border.color: '#b7484242'

            Text {
                anchors.centerIn: parent
                color: "#000000"
                font.family: "Roboto"
                font.pointSize: 13
                text: sModel.get(index).name
            }
        }

        Rectangle {
            Layout.horizontalStretchFactor: 1
            //width: tableBox.implicitWidth * 0.15
            Layout.preferredWidth: 1
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
                text: sModel.get(index).quantity
            }
        }

        Rectangle {
            Layout.horizontalStretchFactor: 2
            //width: tableBox.implicitWidth * 0.15
            Layout.preferredWidth: 1
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
                text: sModel.get(index).sellPrice
            }
        }

        Rectangle {
            Layout.horizontalStretchFactor: 2
            Layout.preferredWidth: 1
            //width: tableBox.implicitWidth * 0.1
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
                text: sModel.get(index).buyPrice
            }
        }

        Rectangle {
            Layout.horizontalStretchFactor: 2
            Layout.preferredWidth: 1
            //width: tableBox.implicitWidth * 0.1
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
                text: Number(sModel.get(index).sellPrice) - Number(sModel.get(index).buyPrice)
            }
        }
    }

    background: Rectangle {
        color: "transparent"
        width: parent.width
        height: parent.height
    }
}