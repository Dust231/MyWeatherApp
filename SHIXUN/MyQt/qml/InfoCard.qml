import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 信息卡片组件
Item {
    id: infoCardRoot

    property string label: ""
    property string value: "--"
    property var themeManager: null

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: themeManager ? themeManager.cardColor : "#FFFFFF"
        border.color: themeManager ? themeManager.borderColor : "#B3D9F2"
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 2

            Label {
                text: infoCardRoot.label
                font.pixelSize: 12
                color: themeManager ? themeManager.subTextColor : "#5A7A8A"
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                text: infoCardRoot.value
                font.pixelSize: 18
                font.bold: true
                color: themeManager ? themeManager.textColor : "#1A2A3A"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
