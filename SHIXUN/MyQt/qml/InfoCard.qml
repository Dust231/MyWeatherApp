import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 信息卡片组件 - 新设计风格
Item {
    id: infoCardRoot

    property string label: ""
    property string value: "--"
    property var themeManager: null

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: themeManager ? themeManager.cardColor : "#2a3240"
        border.color: themeManager ? themeManager.borderColor : "#3a4555"
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4

            Label {
                text: infoCardRoot.label
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 0.5
                color: themeManager ? themeManager.subTextColor : "#8899AA"
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                text: infoCardRoot.value
                font.pixelSize: 16
                font.bold: true
                color: themeManager ? themeManager.accentColor : "#4A90D9"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}

