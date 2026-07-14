import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtWebView 1.15

// 城市地图页面 - 通过 WebView + Leaflet.js 显示城市位置（使用高德瓦片，国内可访问）
Page {
    id: mapPage

    property string cityName: ""
    property real cityLon: 0
    property real cityLat: 0
    property var themeManager: null

    background: Rectangle {
        color: themeManager ? themeManager.bgColor : "#212730"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 顶部标题栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            color: themeManager ? themeManager.bgColor : "#212730"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                Button {
                    text: "← 返回"
                    Layout.preferredHeight: 36
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 8
                        color: parent.hovered ? (themeManager ? themeManager.borderColor : "#3a4555") : (themeManager ? themeManager.cardColor : "#2a3240")
                        border.color: themeManager ? themeManager.borderColor : "#3a4555"
                        border.width: 1
                    }
                    contentItem: Label {
                        text: parent.text
                        color: themeManager ? themeManager.textColor : "#FFFFFF"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: stackView.pop()
                }

                Label {
                    text: "📍 " + mapPage.cityName
                    font.pixelSize: 18
                    font.bold: true
                    color: themeManager ? themeManager.textColor : "#FFFFFF"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Item { Layout.preferredWidth: 80 }
            }
        }

        // 地图区域（WebView 加载本地 HTML + Leaflet.js）
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#1a1f28"

            WebView {
                id: mapView
                anchors.fill: parent
                url: mapPage.cityLat !== 0 || mapPage.cityLon !== 0
                     ? "qrc:/qml/map.html?lat=" + mapPage.cityLat
                       + "&lon=" + mapPage.cityLon
                       + "&name=" + encodeURIComponent(mapPage.cityName)
                     : ""
            }

            // 坐标信息浮层
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 12
                height: 36
                radius: 8
                color: themeManager ? themeManager.cardColor : "#2a3240"
                opacity: 0.9

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14

                    Label {
                        text: "经度: " + mapPage.cityLon.toFixed(4) + "°"
                        font.pixelSize: 12
                        color: themeManager ? themeManager.subTextColor : "#8899AA"
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        text: "纬度: " + mapPage.cityLat.toFixed(4) + "°"
                        font.pixelSize: 12
                        color: themeManager ? themeManager.subTextColor : "#8899AA"
                    }
                }
            }
        }
    }
}
