pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

import "../js/api.js" as Api

Item {
    id: tab

    required property var rootItem

    readonly property var byProvider: (rootItem.stats && rootItem.stats.byProvider) || ({})

    function sortedProviders() {
        var list = (rootItem.providers || []).slice();
        list.sort(function (a, b) {
            if (!!a.isActive !== !!b.isActive) return a.isActive ? -1 : 1;
            return (b.lastUsedAt || "").localeCompare(a.lastUsedAt || "");
        });
        return list;
    }

    ListView {
        anchors.fill: parent
        clip: true
        model: tab.sortedProviders()
        spacing: Kirigami.Units.smallSpacing

        QQC2.ScrollBar.vertical: QQC2.ScrollBar {}

        delegate: Kirigami.AbstractCard {
            id: card
            required property var modelData
            width: ListView.view.width
            showClickFeedback: false

            readonly property var usage: tab.byProvider[modelData.provider] || null

            contentItem: RowLayout {
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    Layout.preferredWidth: 8
                    Layout.preferredHeight: 8
                    radius: 4
                    color: modelData.isActive ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor
                }

                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true

                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        QQC2.Label {
                            text: modelData.name || modelData.provider
                            font.bold: true
                            elide: Text.ElideMiddle
                            Layout.maximumWidth: 200
                        }
                        QQC2.Label {
                            text: modelData.provider
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        QQC2.Label {
                            text: i18n("used %1", Api.timeAgo(modelData.lastUsedAt))
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                        QQC2.Label {
                            visible: card.usage
                            text: card.usage ? (Api.fmtNum((card.usage.promptTokens || 0) + (card.usage.completionTokens || 0))
                                  + " tok · " + Api.fmtCost(card.usage.cost)) : ""
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    QQC2.Label {
                        visible: !!modelData.lastError
                        text: modelData.lastError ? String(modelData.lastError).substring(0, 90) : ""
                        color: Kirigami.Theme.negativeTextColor
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                ColumnLayout {
                    spacing: 0
                    QQC2.Label {
                        text: modelData.isActive ? i18n("active") : i18n("off")
                        color: modelData.isActive ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    }
                    QQC2.Label {
                        visible: !!modelData.errorCode
                        text: modelData.errorCode ? ("err " + modelData.errorCode) : ""
                        color: Kirigami.Theme.negativeTextColor
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    }
                }
            }
        }

        QQC2.Label {
            anchors.centerIn: parent
            visible: parent.count === 0
            text: i18n("No providers configured")
            color: Kirigami.Theme.disabledTextColor
        }
    }
}
