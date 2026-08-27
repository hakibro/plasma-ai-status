pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

import "../js/api.js" as Api

Item {
    id: tab

    required property var rootItem

    readonly property var requests: (rootItem.stats && rootItem.stats.recentRequests) || []

    ListView {
        anchors.fill: parent
        clip: true
        model: tab.requests
        spacing: Kirigami.Units.smallSpacing

        QQC2.ScrollBar.vertical: QQC2.ScrollBar {}

        delegate: RowLayout {
            id: row
            required property var modelData
            required property int index
            spacing: Kirigami.Units.smallSpacing
            width: ListView.view.width

            Rectangle {
                Layout.preferredWidth: 6
                Layout.preferredHeight: 6
                radius: 3
                color: modelData.status === "ok" ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
            }

            QQC2.Label {
                text: Api.clockTime(modelData.timestamp)
                color: Kirigami.Theme.disabledTextColor
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                Layout.preferredWidth: 58
            }

            ColumnLayout {
                spacing: 0
                Layout.fillWidth: true
                QQC2.Label {
                    text: Api.shortModel(modelData.model)
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                }
                QQC2.Label {
                    text: modelData.provider
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                }
            }

            QQC2.Label {
                text: Api.fmtNum((modelData.promptTokens || 0) + (modelData.completionTokens || 0)) + " tok"
                color: Kirigami.Theme.disabledTextColor
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            }
        }

        QQC2.Label {
            anchors.centerIn: parent
            visible: parent.count === 0
            text: i18n("No recent requests")
            color: Kirigami.Theme.disabledTextColor
        }
    }
}
