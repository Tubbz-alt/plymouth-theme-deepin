// This file is automatically generated, please don't edit manully.
import QtQuick 2.1
import Deepin.Widgets 1.0
import "../components"

BaseEditSection {
    id: sectionVpnVpncAdvanced
    section: "vpn-vpnc-advanced"
    
    header.sourceComponent: EditDownArrowHeader{
        text: dsTr("VPN Advanced")
    }

    content.sourceComponent: Column { 
        EditLineTextInput {
            key: "Domain"
            text: dsTr("Domain")
        }
        EditLineTextInput {
            key: "Vendor"
            text: dsTr("Vendor")
        }
        EditLineTextInput {
            key: "Application Version"
            text: dsTr("Version")
        }
        EditLineComboBox {
            key: "vk-encryption-method"
            text: dsTr("Encryption Method")
        }
        EditLineComboBox {
            key: "NAT Traversal Mode"
            text: dsTr("NAT Traversal")
        }
        EditLineComboBox {
            key: "IKE DH Group"
            text: dsTr("IKE DH Group")
        }
        EditLineComboBox {
            key: "Perfect Forward Secrecy"
            text: dsTr("Perfect Forward Secrecy")
        }
        EditLineSpinner {
            key: "Local Port"
            text: dsTr("Local Port")
        }
        EditLineSwitchButton {
            key: "vk-disable-dpd"
            text: dsTr("Disable Dead Peer Detection")
        }
    }
}
