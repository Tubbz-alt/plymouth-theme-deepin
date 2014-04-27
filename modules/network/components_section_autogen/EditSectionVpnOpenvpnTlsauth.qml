// This file is automatically generated, please don't edit manully.
import QtQuick 2.1
import Deepin.Widgets 1.0
import "../components"

BaseEditSection {
    id: sectionVpnOpenvpnTlsauth
    section: "vpn-openvpn-tlsauth"
    
    header.sourceComponent: EditDownArrowHeader{
        text: dsTr("VPN TLS Authentication")
    }

    content.sourceComponent: Column { 
        EditLineTextInput {
            key: "tls-remote"
            text: dsTr("Subject Match")
        }
        EditLineComboBox {
            key: "remote-cert-tls"
            text: dsTr("Remote Cert")
        }
        EditLineFileChooser {
            key: "ta"
            text: dsTr("Key File")
        }
        EditLineComboBox {
            key: "ta-dir"
            text: dsTr("Key Direction")
        }
    }
}
