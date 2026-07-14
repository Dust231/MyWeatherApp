import QtQuick 2.15
import QtQuick.Controls 2.15

// 应用入口页面 - StackView 导航容器
ApplicationWindow {
    id: appWindow
    visible: true
    width: 960
    height: 620
    title: "天气查询系统"

    // 主题管理器（全局单例）
    ThemeManager {
        id: themeManager
    }

    // 导航栈
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: MainPage {
            themeManager: themeManager
            stackView: stackView
        }
    }

    // 背景色随主题变化
    background: Rectangle {
        color: themeManager.bgColor
    }
}
