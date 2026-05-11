import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import QtQuick.Effects

import Authenticator

Item {
    id: loginContainer
    anchors.fill: parent
    signal userLogin(username: string, level: int)
    property bool noExistingUsers: user_model.getEffectiveCount("", 0) == 0

    MultiEffect {
        anchors.fill: loginContent
        source: loginContent

        blurEnabled: true
        blur: 1.0
        shadowEnabled: true
        shadowColor: Parameters.pressedButtonBg
        shadowScale: 1.0
        shadowBlur: 0.8
    }

    Rectangle {
        id: loginContent
        anchors.fill: parent
        visible: true
        scale: 1
        opacity: 1
        z: 1
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop {
                position: 0.0
                color: Parameters.mainHighlightBg
            }
            GradientStop {
                position: 0.35
                color: Qt.lighter(Parameters.mainHighlightBg, 1.2)
            }
            GradientStop {
                position: 0.4
                color: Qt.lighter(Parameters.mainHighlightBg, 1.3)
            }
            GradientStop {
                position: 0.56
                color: Qt.lighter(Parameters.mainHighlightBg, 1.6)
            }
            GradientStop {
                position: 0.71
                color: Qt.lighter(Parameters.mainHighlightBg, 1.4)
            }
            GradientStop {
                position: 1.0
                color: Qt.lighter(Parameters.mainHighlightBg, 1)
            }
        }

        UserModel {
            id: user_model
        }

        signal login(username: string, level: int)

        onLogin: {
            loginFade.username = arguments[0];
            loginFade.userlevel = arguments[1];
            loginContainer.opacity = 0;
            loginFade.restart();
        }

        Behavior on opacity {
            enabled: parent.visible
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuad
            }
        }

        Timer {
            id: loginFade
            property string username
            property int userlevel
            running: false
            repeat: false
            interval: 250
            onTriggered: {
                loginContent.visible = false;
                loginContainer.userLogin(username, userlevel);
            }
        }

        Rectangle {
            id: tempPassDialog
            anchors.fill: parent
            visible: false
            opacity: 0.0
            property string targetUsername
            property int targetLevel
            z: 2

            Behavior on opacity {
                NumberAnimation {
                    duration: 170
                }
            }

            function open() {
                tempPassDialog.visible = true;
                Qt.callLater(() => {
                    tempPassDialog.opacity = 1.0;
                });
            }

            function close() {
                tempPassDialog.opacity = 0;
                closetempPassDialog.restart();
            }

            Timer {
                id: closetempPassDialog
                running: false
                repeat: false
                interval: 200
                onTriggered: {
                    tempPassDialog.visible = false;
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
                source: tempPassDialog
                blurEnabled: true
                blur: 0.7
            }

            Rectangle {
                id: passContainer
                anchors.centerIn: parent
                width: childrenRect.width + 35
                height: childrenRect.height + 30
                radius: 30
                color: Parameters.pressedButtonBg
                property bool hideChars: true

                ColumnLayout {
                    anchors.centerIn: parent
                    width: loginContent.width * 0.42
                    spacing: loginContent.height * 0.006

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 55
                        color: Parameters.mainHighlightBg
                        topLeftRadius: 15
                        topRightRadius: 15

                        Text {
                            anchors.centerIn: parent
                            text: "Defina uma nova senha:"
                            color: Parameters.mainBgColor
                            font.family: Parameters.defaultFont
                            font.styleName: "Condensed Medium"
                            font.pointSize: 18
                        }
                    }

                    Rectangle {
                        id: tempPassC1
                        Layout.fillWidth: true
                        Layout.leftMargin: loginContent.width * 0.01
                        Layout.rightMargin: loginContent.width * 0.01
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
                                smallPassWarn.visible = false;
                                tempPassC1.border.width = 1;
                                tempPassC1.border.color = Qt.darker(Parameters.mainHighlightBg, 2.5);
                                tempPassTF1.placeholderTextColor = "#bbbbbb";
                                tempPassTF1.forceActiveFocus();
                            }

                            TextField {
                                id: tempPassTF1
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
                                font.pixelSize: tempPassC1.height * 0.47
                                placeholderText: "Nova Senha"
                                echoMode: passContainer.hideChars ? TextInput.Password : TextInput.Normal
                                passwordMaskDelay: 300
                                placeholderTextColor: "#bbbbbb"
                                validator: RegularExpressionValidator {
                                    regularExpression: /(.|\s)*\S(.|\s)*/
                                }
                                focus: true
                                onPressed: {
                                    smallPassWarn.visible = false;
                                    tempPassC1.border.width = 1;
                                    tempPassC1.border.color = Qt.darker(Parameters.mainHighlightBg, 2.5);
                                    tempPassTF1.placeholderTextColor = "#bbbbbb";
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: tempPassC2
                        Layout.fillWidth: true
                        Layout.leftMargin: loginContent.width * 0.01
                        Layout.rightMargin: loginContent.width * 0.01
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
                                smallPassWarn.visible = false;
                                tempPassC2.border.width = 1;
                                tempPassC2.border.color = Qt.darker(Parameters.mainHighlightBg, 2.5);
                                tempPassTF2.placeholderTextColor = "#bbbbbb";
                                tempPassTF2.forceActiveFocus();
                            }

                            TextField {
                                id: tempPassTF2
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
                                font.pixelSize: tempPassC2.height * 0.47
                                placeholderText: "Confirme a Senha"
                                echoMode: passContainer.hideChars ? TextInput.Password : TextInput.Normal
                                passwordMaskDelay: 300
                                placeholderTextColor: "#bbbbbb"
                                validator: RegularExpressionValidator {
                                    regularExpression: /(.|\s)*\S(.|\s)*/
                                }
                                focus: true
                                onPressed: {
                                    smallPassWarn.visible = false;
                                    tempPassC2.border.width = 1;
                                    tempPassC2.border.color = Qt.darker(Parameters.mainHighlightBg, 2.5);
                                    tempPassTF2.placeholderTextColor = "#bbbbbb";
                                }
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
                                left: parent.left
                                topMargin: 2
                                bottomMargin: 2
                                rightMargin: 6
                                leftMargin: 8
                            }
                            layoutDirection: Qt.LeftToRight
                            spacing: 6

                            Button {
                                id: showTempPasses
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                                Layout.fillWidth: false
                                Layout.fillHeight: false
                                text: passContainer.hideChars ? "" : ""
                                implicitWidth: implicitHeight
                                implicitHeight: 28

                                onClicked: {
                                    passContainer.hideChars = !passContainer.hideChars
                                }

                                contentItem: Text {
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: Parameters.iconFontBold
                                    font.pixelSize: showTempPasses.implicitHeight * 0.55
                                    fontSizeMode: Text.Fit
                                    minimumPixelSize: 6
                                    text: showTempPasses.text
                                    color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                }

                                background: Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    implicitWidth: implicitHeight
                                    implicitHeight: 28
                                    radius: implicitHeight / 2
                                    color: showTempPasses.down ? Parameters.pressedButtonBg : showTempPasses.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                    border.width: 2
                                    border.color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                }

                                HoverHandler {
                                    enabled: parent.visible
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                id: smallPassWarn
                                visible: false
                                font.family: Parameters.defaultFont
                                font.styleName: "Condensed Medium"
                                font.pixelSize: 18
                                style: Text.Outline
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 6
                                text: "As senhas devem ter mais de 10 caracteres!"
                                color: Parameters.mainBgColor
                            }

                            Item { Layout.fillWidth: true }

                            Button {
                                id: tempPassSubmit
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                                Layout.fillWidth: false
                                text: "OK"
                                implicitWidth: 74
                                implicitHeight: 34

                                onClicked: {
                                    if (tempPassTF1.acceptableInput && tempPassTF1.text.length >= 10 && tempPassTF2.acceptableInput && tempPassTF2.text.length >= 10 && (tempPassTF1.text == tempPassTF2.text)) {
                                        user_model.newUserPasswd(tempPassDialog.targetUsername, tempPassTF1.text);

                                        loginContent.login(tempPassDialog.targetUsername, tempPassDialog.targetLevel);

                                        tempPassDialog.close();
                                    } else {
                                        if ((tempPassTF1.acceptableInput && tempPassTF2.acceptableInput) && tempPassTF1.text != tempPassTF2.text) {
                                            tempPassC1.border.width = 2;
                                            tempPassC1.border.color = "#f9af26";
                                            tempPassC2.border.width = 2;
                                            tempPassC2.border.color = '#f98c26'
                                        }
                                        
                                        if (!tempPassTF1.acceptableInput || tempPassTF1.text.length < 10) {
                                            tempPassC1.border.width = 2;
                                            tempPassC1.border.color = Parameters.lowCashRed;
                                        }
                                        
                                        if (!tempPassTF2.acceptableInput || tempPassTF2.text.length < 10) {
                                            tempPassC2.border.width = 2;
                                            tempPassC2.border.color = Parameters.lowCashRed;
                                        }

                                        if (tempPassTF1.text.length < 10 || tempPassTF2.text.length < 10) {
                                            smallPassWarn.visible = true;
                                        }
                                    }
                                }

                                contentItem: Text {
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: Parameters.defaultFont
                                    font.styleName: "Condensed Medium"
                                    font.pointSize: 12
                                    text: tempPassSubmit.text
                                    color: Qt.lighter(Parameters.mainHighlightBg, 4.1)
                                }

                                background: Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    implicitWidth: 74
                                    implicitHeight: 34
                                    radius: Parameters.defaultRadius * 2
                                    color: tempPassSubmit.down ? Parameters.pressedButtonBg : tempPassSubmit.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
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

        ColumnLayout {
            anchors.fill: parent
            spacing: 24

            Item {
                Layout.fillHeight: true
                Layout.verticalStretchFactor: 5
            }

            Rectangle {
                id: logologinContent
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                Layout.preferredHeight: 96
                Layout.minimumHeight: 96
                Layout.maximumHeight: 96
                Layout.preferredWidth: loginContent.width / 12
                radius: 32
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

                Rectangle {
                    id: logologinRect
                    anchors.centerIn: logologinContent
                    width: logologinContent.width - 8
                    height: logologinContent.height - 8
                    radius: logologinContent.radius
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
                            font.styleName: "Condensed Medium"
                            font.underline: false
                            font.pointSize: 18
                            color: Qt.lighter(Parameters.mainHighlightBg, 4.2)
                        }
                    }
                }
            }

            //Item { Layout.fillHeight: true; Layout.verticalStretchFactor: 1 }

            Rectangle {
                color: "transparent"
                Layout.preferredWidth: loginMainColumn.implicitWidth
                Layout.preferredHeight: loginMainColumn.implicitHeight
                Layout.alignment: Qt.AlignHCenter

                ColumnLayout {
                    id: loginMainColumn
                    anchors.fill: parent
                    spacing: 18

                    Text {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        Layout.fillHeight: false
                        font.family: Parameters.defaultFont
                        font.styleName: "Condensed Medium"
                        font.pointSize: 26
                        text: {
                            if (!loginContainer.noExistingUsers) {
                                return "Faça Login";
                            } else {
                                return "Faça o primeiro login";
                            }
                        }
                        color: Parameters.mainBgColor
                    }

                    Text {
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        font.family: Parameters.thinFont
                        font.pointSize: 17
                        text: {
                            if (!loginContainer.noExistingUsers) {
                                return "Entre para gerenciar seu estoque";
                            } else {
                                return "Crie uma conta para utilizar o gerenciador de estoque";
                            }
                        }
                        color: Parameters.shadeBgColor
                    }

                    Rectangle {
                        id: userContainer
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: false
                        Layout.fillHeight: false
                        Layout.preferredWidth: loginContent.width / 6.4
                        Layout.preferredHeight: 60
                        color: "transparent"

                        Text {
                            id: userLabel
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            font.family: Parameters.defaultFont
                            font.styleName: "Condensed Medium"
                            font.pointSize: 12
                            text: "Usuário"
                            color: Parameters.shadeBgColor
                        }

                        TextField {
                            id: usernameInput
                            anchors.top: userLabel.bottom
                            anchors.topMargin: 4
                            anchors.left: parent.left
                            anchors.right: parent.right

                            background: Rectangle {
                                width: userContainer.width
                                height: 36
                                radius: 12

                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop {
                                        position: 0.0
                                        color: Parameters.mainBgColor
                                    }
                                    GradientStop {
                                        position: 0.6
                                        color: Parameters.shadeBgColor
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: Parameters.mainBgColor
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.IBeamCursor
                                    onClicked: usernameInput.forceActiveFocus()

                                    onEntered: {
                                        userLabel.color = Parameters.shadeBgColor;
                                        usernameInput.color = Parameters.shadeHighlightBg;
                                        usernameInput.placeholderTextColor = Parameters.dimmedHighlightBg;
                                    }
                                }
                            }

                            font.family: Parameters.defaultFont
                            font.styleName: "Condensed Medium"
                            font.pointSize: 12
                            color: Parameters.shadeHighlightBg
                            selectionColor: Parameters.highlightFg

                            placeholderText: "   Usuário"
                            placeholderTextColor: Parameters.dimmedHighlightBg
                            topPadding: 8
                            leftPadding: 8
                            rightPadding: 8
                        }
                    }

                    Rectangle {
                        id: passwdContainer
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: false
                        Layout.fillHeight: false
                        Layout.preferredWidth: loginContent.width / 6.4
                        Layout.preferredHeight: 60
                        color: "transparent"

                        RowLayout {
                            id: passwdInputRow
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            anchors.right: parent.right
                            anchors.rightMargin: 4
                            spacing: 6

                            Text {
                                id: passwdLabel
                                Layout.alignment: Qt.AlignVCenter
                                Layout.fillWidth: false
                                font.family: Parameters.defaultFont
                                font.styleName: "Condensed Medium"
                                font.pointSize: 12
                                text: "Senha"
                                color: Parameters.shadeBgColor
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Button {
                                id: showPasswd
                                Layout.alignment: Qt.AlignVCenter
                                Layout.fillWidth: false
                                text: passwdInput.shouldHideChars ? "" : ""
                                implicitWidth: 18
                                implicitHeight: 18

                                onClicked: {
                                    passwdInput.shouldHideChars = !passwdInput.shouldHideChars;
                                }

                                contentItem: Text {
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: Parameters.iconFontBold
                                    font.pointSize: 9
                                    text: showPasswd.text
                                    //color: '#f0f0f0'
                                    color: Parameters.shadeHighlightBg
                                }

                                background: Rectangle {
                                    anchors.fill: parent
                                    implicitWidth: parent.implicitWidth
                                    implicitHeight: parent.implicitHeight
                                    radius: implicitHeight / 2
                                    //color: showPasswd.down ? Parameters.pressedButtonBg : showPasswd.hovered ? Parameters.hoveredButtonBg : Parameters.stdButtonBg
                                    color: (showPasswd.hovered || showPasswd.down) ? Parameters.dimmedBgColor : Parameters.mainBgColor
                                    border.width: 2
                                    border.color: passwdInput.shouldHideChars ? Parameters.highlightFg : "#dc2332"
                                }

                                HoverHandler {
                                    enabled: parent.visible
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }

                        TextField {
                            id: passwdInput
                            anchors.top: passwdInputRow.bottom
                            anchors.topMargin: 4
                            anchors.left: parent.left
                            anchors.right: parent.right
                            width: passwdContainer.width
                            height: 36

                            property bool shouldHideChars: true

                            background: Rectangle {
                                width: parent.width
                                height: parent.height
                                radius: 12

                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop {
                                        position: 0.0
                                        color: Parameters.mainBgColor
                                    }
                                    GradientStop {
                                        position: 0.6
                                        color: Parameters.shadeBgColor
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: Parameters.mainBgColor
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.IBeamCursor
                                    onClicked: passwdInput.forceActiveFocus()

                                    onEntered: {
                                        passwdLabel.color = Parameters.shadeBgColor;
                                        passwdInput.color = Parameters.shadeHighlightBg;
                                        passwdInput.placeholderTextColor = Parameters.dimmedHighlightBg;
                                    }
                                }
                            }

                            font.family: Parameters.defaultFont
                            font.styleName: "Condensed Medium"
                            font.pointSize: 12
                            color: Parameters.shadeHighlightBg
                            selectionColor: Parameters.highlightFg
                            echoMode: shouldHideChars ? TextInput.Password : TextInput.Normal
                            passwordMaskDelay: 340

                            placeholderText: "   Senha"
                            placeholderTextColor: Parameters.dimmedHighlightBg
                            leftPadding: 8
                            rightPadding: 8
                        }
                    }

                    Item {
                        Layout.preferredHeight: 1
                    }

                    Rectangle {
                        id: loginSubmit
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillHeight: false
                        Layout.preferredWidth: loginContent.width / 9.6
                        Layout.preferredHeight: 40
                        radius: 15

                        property var bgGradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: Parameters.highlightFg
                            }
                            GradientStop {
                                position: 0.5
                                color: Qt.lighter(Parameters.shadeHighlightFg, 1.1)
                            }
                            GradientStop {
                                position: 0.85
                                color: Parameters.highlightFg
                            }
                        }

                        gradient: bgGradient

                        color: Parameters.highlightFg

                        Text {
                            anchors.centerIn: parent
                            font.family: Parameters.defaultFont
                            font.styleName: "Condensed Medium"
                            font.pointSize: 11
                            text: {
                                if (!loginContainer.noExistingUsers) {
                                    return "Entrar";
                                } else {
                                    return "Criar Conta";
                                }
                            }
                            color: "#ffffff"
                            //style: Text.Outline
                        }

                        MouseArea {
                            id: loginSubmitPointHandler
                            anchors.fill: loginSubmit
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onEntered: {
                                loginSubmit.gradient = null;
                                loginSubmit.color = Parameters.shadeHighlightFg;
                            }

                            onExited: {
                                loginSubmit.color = null;
                                loginSubmit.gradient = loginSubmit.bgGradient;
                            }

                            onClicked: {
                                if (usernameInput.text != "" && passwdInput.text != "") {
                                    if (loginContainer.noExistingUsers) {
                                        user_model.setFirstUser(usernameInput.text, passwdInput.text, 0);
                                        loginContent.login(usernameInput.text, 0);
                                    } else {
                                        if (user_model.checkLogin(usernameInput.text, passwdInput.text) == "senha temp correta") {
                                            tempPassDialog.targetUsername = usernameInput.text;
                                            tempPassDialog.targetLevel = user_model.getUserLevel(usernameInput.text);
                                            tempPassDialog.open();
                                        } else if (user_model.checkLogin(usernameInput.text, passwdInput.text) == "senha correta") {
                                            loginContent.login(usernameInput.text, user_model.getUserLevel(usernameInput.text));
                                        } else if (user_model.checkLogin(usernameInput.text, passwdInput.text) == "senha incorreta") {
                                            passwdLabel.color = '#e03b3b';
                                            passwdInput.color = "#dc2332";
                                        } else {
                                            userLabel.color = "#e03b3b";
                                            usernameInput.color = "#dc2332";
                                        }
                                    }
                                } else if (usernameInput.text != "" && passwdInput.text == "") {
                                    passwdLabel.color = '#e03b3b';
                                    passwdInput.placeholderTextColor = "#dc2332";
                                } else if (usernameInput.text == "" && passwdInput.text != "") {
                                    userLabel.color = "#e03b3b";
                                    usernameInput.placeholderTextColor = "#dc2332";
                                } else {
                                    passwdLabel.color = '#e03b3b';
                                    passwdInput.placeholderTextColor = "#dc2332";
                                    userLabel.color = "#e03b3b";
                                    usernameInput.placeholderTextColor = "#dc2332";
                                }
                            }
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.verticalStretchFactor: 8
            }
        }
    }
}
