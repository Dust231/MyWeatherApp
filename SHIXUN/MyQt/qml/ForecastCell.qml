import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 预报单元格组件 - 新设计风格
Label {
    id: forecastCellRoot

    property string cellText: ""

    Layout.fillWidth: true
    Layout.alignment: Qt.AlignVCenter
    text: forecastCellRoot.cellText
    font.pixelSize: 12
    color: themeManager ? themeManager.textColor : "#1A2A3A"
    horizontalAlignment: Text.AlignHCenter
    elide: Text.ElideRight

    property var themeManager: null
}
