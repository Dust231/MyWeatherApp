import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 主题切换页面 - 网格展示所有主题色卡
Page {
    id: themePage

    property var themeManager: null

    background: Rectangle {
        color: themeManager ? themeManager.bgColor : "#E8F4FD"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // 标题栏
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            Button {
                text: "← 返回"
                Layout.preferredHeight: 36
                onClicked: StackView.view.pop()
            }

            Label {
                text: "选择主题"
                font.pixelSize: 22
                font.bold: true
                color: themeManager ? themeManager.textColor : "#1A2A3A"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.preferredWidth: 80 } // 占位保持标题居中
        }

        // 当前主题提示
        Label {
            text: "当前主题: " + (themeManager ? themeManager.themeNames[themeManager.currentIndex] : "")
            font.pixelSize: 14
            color: themeManager ? themeManager.subTextColor : "#5A7A8A"
            Layout.alignment: Qt.AlignHCenter
        }

        // 主题色卡网格
        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 160
            cellHeight: 180
            flow: GridView.FlowLeftToRight

            model: themeManager ? themeManager.themes : []

            delegate: Item {
                width: 140
                height: 160

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: modelData.cardColor
                    border.color: themeManager && themeManager.currentIndex === index
                                  ? modelData.accentColor : modelData.borderColor
                    border.width: themeManager && themeManager.currentIndex === index ? 3 : 1

                    // 颜色预览条
                    Row {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 10
                        height: 20
                        spacing: 3

                        Repeater {
                            model: [modelData.bgColor, modelData.accentColor,
                                    modelData.iconColor, modelData.accentLight]
                            Rectangle {
                                width: (parent.width - 9) / 4
                                height: 20
                                radius: 4
                                color: modelData
                            }
                        }
                    }

                    // 主题名称
                    Label {
                        anchors.centerIn: parent
                        text: modelData.name
                        font.pixelSize: 16
                        font.bold: true
                        color: modelData.textColor
                    }

                    // 当前选中标记
                    Label {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 10
                        text: themeManager && themeManager.currentIndex === index ? "✓ 当前" : ""
                        font.pixelSize: 12
                        color: modelData.accentColor
                    }

                    // 点击切换
                    // 选中动画
                    SequentialAnimation {
                        id: selectAnim
                        running: false
                        PropertyAnimation {
                            target: parent
                            property: "scale"
                            to: 0.92
                            duration: 100
                        }
                        PropertyAnimation {
                            target: parent
                            property: "scale"
                            to: 1.0
                            duration: 150
                            easing.type: Easing.OutBack
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: selectAnim.start()
                        onClicked: {
                            if (themeManager) {
                                themeManager.switchTheme(index);
                            }
                        }
                    }
                }
            }
        }
    }
}
