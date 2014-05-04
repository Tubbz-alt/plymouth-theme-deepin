import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import Deepin.Widgets 1.0
import "../shared/"

Item {
    id: wirelessItem
    width: parent.width
    height: childrenRect.height

    property string devicePath: "/"
    property string deviceHwAddr
    property string connectionPath
    property string uuid
    property bool apConnected: isActiveConnection(devicePath, uuid) && deviceStatus == nmDeviceStateActivated

    Behavior on height {
        PropertyAnimation { duration: 100 }
    }

    Connections {
        target: dbusNetwork
        onConnectionsChanged: {
            updateWirelessConnectionInfo()
        }
    }
    Component.onCompleted: {
        updateWirelessConnectionInfo()
    }
    
    function updateWirelessConnectionInfo() {
        var wirelessConnections = nmConnections[nmConnectionTypeWireless]
        var connectionPath = ""
        var uuid = ""
        for (var i in wirelessConnections) {
            if (apName == wirelessConnections[i].Ssid) {
                if (wirelessConnections[i].HwAddr == "" || wirelessConnections[i].HwAddr == deviceHwAddr) {
                    connectionPath = wirelessConnections[i].Path
                    uuid = wirelessConnections[i].Uuid
                    print("update connection:", wirelessConnections[i].Ssid, uuid, connectionPath, deviceHwAddr) // TODO test
                    break
                }
            }
        }
        wirelessItem.connectionPath = connectionPath
        wirelessItem.uuid = uuid
    }
    
    function activateThisConnection(){
        if (apSecuredInEap && uuid == "") {
            // if security in eap, go to edit connection
            print("secured in eap") // TODO debug
            goToEditConnection()
        } else {
            dbusNetwork.ActivateConnectionForAccessPoint(apPath, wirelessItem.devicePath)
            wirelessDevicesExpand.inConnectingApPath = apPath
        }
    }

    function goToEditConnection(){
        if (uuid != "") {
            doGoToEditConnection()
        } else {
            doGoToCreateConnection()
        }
    }

    function doGoToEditConnection(){
        stackView.push({
            "item": stackViewPages["connectionPropertiesPage"],
            "properties": { "uuid": wirelessItem.uuid, "devicePath": wirelessItem.devicePath },
            "destroyOnPop": true
        })
        stackView.currentItemId = "connectionPropertiesPage"
    }

    function doGoToCreateConnection(){
        stackView.push({
            "item": stackViewPages["connectionPropertiesPage"],
            "properties": { "create": true, "type":  nmConnectionTypeWireless},
            "destroyOnPop": true
        })
        stackView.currentItemId = "connectionPropertiesPage"
    }
    
    DBaseLine {
        id: wirelessLine

        property bool hovered: false
        property bool selected: false

        MouseArea{
            z:-1
            anchors.fill:parent
            hoverEnabled: true
            visible: !networkModule.inPasswordInputting

            onEntered: {
                parent.hovered = true
            }

            onExited: {
                parent.hovered = false
            }

            onClicked: {
                if(!apConnected){
                    print("activate connection") // TODO debug
                    activateThisConnection()
                }
                else{
                    print("edit connection") // TODO debug
                    goToEditConnection()
                }
            }
        }
        color: dconstants.contentBgColor

        leftLoader.sourceComponent: Item {
            height: parent.height
            width: childrenRect.width

            DImageButton {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                normal_image: "img/check_1.png"
                hover_image: "img/check_2.png"
                visible: {
                    if(wirelessDevicesExpand.inConnectingApPath != "/"){
                        return false
                    }
                    else{
                        return apConnected
                    }
                }
                onClicked: {
                    // disconnect connection
                    dbusNetwork.DisconnectDevice(wirelessItem.devicePath)
                }
            }

            WaitingImage {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                on: wirelessDevicesExpand.inConnectingApPath == apPath
            }

            DLabel {
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                text: apName
                font.pixelSize: 12
                color: {
                    if(wirelessLine.selected){
                        return dconstants.activeColor
                    }
                    else if(wirelessLine.hovered){
                        return dconstants.hoverColor
                    }
                    else{
                        return dconstants.fgColor
                    }
                }
            }
        }

        rightLoader.sourceComponent: Row {
            height: childrenRect.height
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Image {
                source: {
                    var power = apSignal
                    var secure = apSecured ? "-secure": ""
                    if (power <= 5)
                        return "img/ap-signal-0" + secure + ".svg"
                    else if (power <= 25)
                        return "img/ap-signal-25" + secure + ".svg"
                    else if (power <= 50)
                        return "img/ap-signal-50" + secure + ".svg"
                    else if (power <= 75)
                        return "img/ap-signal-75" + secure + ".svg"
                    else if (power <= 100)
                        return "img/ap-signal-100" + secure + ".svg"
                }
            }

            DArrowButton {
                onClicked: {
                    goToEditConnection()
                }
            }
        }
    }

    Item{
        id: passwordArea
        anchors.top: wirelessLine.bottom
        anchors.topMargin: 0 - arrowRectBackground.arrowHeight
        width: parent.width
        height: 0
        property int realHeight: childrenRect.height
        clip: true

        property string path: ""
        property string encryptionName: ""

        function showArea(encryptionName){
            passwordArea.encryptionName = encryptionName
            height = realHeight
            networkModule.inPasswordInputting = true
            passwordInput.forceActiveFocus()
        }

        function hideArea(){
            height = 0
            networkModule.inPasswordInputting = false
        }

        function cancelAction(){
            hideArea()
            dbusNetwork.CancelSecret(passwordArea.path, passwordArea.encryptionName)
        }

        function connectAction(){
            hideArea()
            dbusNetwork.FeedSecret(passwordArea.path, passwordArea.encryptionName, passwordInput.text)
        }

        Connections {
            target: networkModule
            onNeedSecretsEmit: {
                if (wirelessItem.uuid != ""){
                    passwordArea.path = wirelessItem.connectionPath
                    print("onNeedSecretsEmit:", passwordArea.path, path) // TODO test
                    if(passwordArea.path == path){
                        passwordArea.showArea(encryptionName)
                    }
                }
            }
        }

        ArrowRect{
            id: arrowRectBackground
            anchors.fill: parent
            fillStyle: dconstants.bgColor
            stroke: false
            radius: 0
            lineWidth: 0
            arrowPosition: 0.15
        }

        Row{
            id: passwordInputArea
            anchors.top: parent.top
            anchors.topMargin: arrowRectBackground.arrowHeight + 18
            anchors.left: parent.left
            anchors.leftMargin: 30
            height: childrenRect.height
            spacing: 10

            DssH2 {
                text: dsTr("Password: ")
            }

            Column{
                DTextInput{
                    id: passwordInput
                    textInput.color: dconstants.fgColor
                    echoMode: showPasswordButton.checked ? TextInput.Normal : TextInput.Password
                    onAccepted: {
                        passwordArea.connectAction()
                    }
                }
                Row{
                    spacing: 6

                    DSwitchButton{
                        id: showPasswordButton
                    }

                    DssH3{
                        text: dsTr("Show password")
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        Row{
            anchors.top: passwordInputArea.bottom
            anchors.right: parent.right
            anchors.rightMargin: 15
            height: childrenRect.height
            spacing: 10

            DTextButton{
                text: dsTr("Cancel")
                onClicked: {
                    passwordArea.cancelAction()
                }
            }

            DTextButton{
                text: dsTr("Connect")
                onClicked: {
                    passwordArea.connectAction()
                }
            }
        }
    }

    DSeparatorHorizontal{
        anchors.top: wirelessLine.bottom
        anchors.topMargin: passwordArea.height == 0 ? 0 : passwordArea.height - arrowRectBackground.arrowHeight
        visible: index != parent.ListView.view.count - 1
    }
}
