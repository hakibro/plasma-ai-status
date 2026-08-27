pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

import "tabs"

Item {
    id: full

    required property var rootItem

    implicitWidth: 500
    implicitHeight: 600

    readonly property var periods: ["today", "24h", "7d", "30d", "60d"]
    readonly property var periodLabels: [i18n("Today"), i18n("24h"), i18n("7d"), i18n("30d"), i18n("60d")]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        // ---- header ----
        RowLayout {
            spacing: Kirigami.Units.smallSpacing

            Rectangle {
                Layout.preferredWidth: 10
                Layout.preferredHeight: 10
                radius: 5
                color: !root.connected ? Kirigami.Theme.negativeTextColor
                     : (root.isActive ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.neutralTextColor)
            }

            QQC2.Label {
                text: !root.connected ? (root.lastError || i18n("Offline"))
                     : (root.isActive ? i18np("%1 active", "%1 active", root.activeCount) : i18n("Idle"))
                elide: Text.ElideRight
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            QQC2.ComboBox {
                id: periodCombo
                model: full.periodLabels
                currentIndex: Math.max(0, full.periods.indexOf(root.period))
                onActivated: function (idx) {
                    root.period = full.periods[idx];
                    root.refresh();
                }
            }

            QQC2.ToolButton {
                icon.name: "view-refresh"
                enabled: !root.loading
                onClicked: root.refresh()
                QQC2.ToolTip.text: i18n("Refresh")
                QQC2.ToolTip.delay: 500
            }
        }

        // ---- tabs ----
        QQC2.TabBar {
            id: tabBar
            Layout.fillWidth: true
            QQC2.TabButton { text: i18n("Overview") }
            QQC2.TabButton { text: i18n("Providers") }
            QQC2.TabButton { text: i18n("Recent") }
            QQC2.TabButton { text: i18n("Breakdown") }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            OverviewTab { rootItem: full.rootItem }
            ProvidersTab { rootItem: full.rootItem }
            RecentTab { rootItem: full.rootItem }
            BreakdownTab { rootItem: full.rootItem }
        }
    }

    // error / empty overlay
    QQC2.Label {
        anchors.centerIn: parent
        visible: !root.connected
        text: root.lastError
            ? i18n("Cannot reach 9router\n%1", root.lastError)
            : i18n("Connecting…")
        horizontalAlignment: Text.AlignHCenter
        color: Kirigami.Theme.disabledTextColor
    }
}
