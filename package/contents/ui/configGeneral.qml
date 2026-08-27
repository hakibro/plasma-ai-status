import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    // cfg_<key> properties are auto-loaded/saved by Plasma (see config/main.xml)
    property alias cfg_host: hostField.text
    property alias cfg_port: portField.value
    property alias cfg_cliToken: tokenField.text
    property alias cfg_pollInterval: intervalField.value

    property string cfg_compactMode: "activity"
    property string cfg_period: "24h"

    readonly property var compactValues: ["activity", "tokens", "cost", "requests", "providers", "icon"]
    readonly property var compactLabels: [
        i18n("Activity (running model · provider)"),
        i18n("Total tokens"),
        i18n("Cost"),
        i18n("Request count"),
        i18n("Active providers"),
        i18n("Icon only"),
    ]
    readonly property var periodValues: ["today", "24h", "7d", "30d", "60d"]
    readonly property var periodLabels: [i18n("Today"), i18n("24h"), i18n("7d"), i18n("30d"), i18n("60d")]

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Kirigami.Units.largeSpacing

        // ============ Connection ============
        Kirigami.Heading {
            level: 3
            text: i18n("9router connection")
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: Kirigami.Theme.disabledTextColor
            text: i18n("Where your 9router instance runs. By default it listens on this machine and its dashboard is at http://localhost:20128/dashboard.")
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            TextField {
                id: hostField
                Kirigami.FormData.label: i18n("Host:")
                placeholderText: "localhost"
            }

            SpinBox {
                id: portField
                Kirigami.FormData.label: i18n("Port:")
                from: 1
                to: 65535
            }

            TextField {
                id: tokenField
                Kirigami.FormData.label: i18n("CLI token:")
                placeholderText: i18n("paste token here")
                Layout.fillWidth: true
            }
        }

        // detailed token help
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: tokenHelp.implicitHeight + 2 * Kirigami.Units.smallSpacing
            radius: Kirigami.Units.smallSpacing
            color: Kirigami.Theme.alternateBackgroundColor

            Label {
                id: tokenHelp
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Kirigami.Units.smallSpacing
                anchors.verticalCenter: parent.verticalCenter
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                text: i18n("<b>What is the CLI token?</b> It lets the widget read 9router usage without your dashboard password. It is derived from <code>~/.9router/machine-id</code> and <code>~/.9router/auth/cli-secret</code> — the same method the official 9router CLI uses.<br><br>"
                         + "<b>How to get it:</b> open a terminal and run <code>9r-token</code> (installed for you), then paste the output above. From the widget folder you can also run <code>./install.sh token</code>.<br><br>"
                         + "<b>When is it needed?</b> Only if your 9router dashboard is password-protected. If it opens without a login, leave this empty.")
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        // ============ Widget ============
        Kirigami.Heading {
            level: 3
            text: i18n("Widget behavior")
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            SpinBox {
                id: intervalField
                Kirigami.FormData.label: i18n("Refresh every:")
                from: 5
                to: 3600
                stepSize: 5
                textFromValue: function (v) { return v + " s"; }
            }

            ComboBox {
                id: compactCombo
                Kirigami.FormData.label: i18n("Panel shows:")
                model: root.compactLabels
                currentIndex: Math.max(0, root.compactValues.indexOf(root.cfg_compactMode))
                onActivated: function (idx) { root.cfg_compactMode = root.compactValues[idx]; }
            }

            ComboBox {
                id: periodCombo
                Kirigami.FormData.label: i18n("Default period:")
                model: root.periodLabels
                currentIndex: Math.max(0, root.periodValues.indexOf(root.cfg_period))
                onActivated: function (idx) { root.cfg_period = root.periodValues[idx]; }
            }
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: Kirigami.Theme.disabledTextColor
            text: i18n("• Refresh every — how often the widget polls 9router. Lower is more live but makes more requests (15–60 s recommended).\n• Panel shows — what the compact panel item displays. “Activity” shows the currently-running model · provider.\n• Default period — time range used to aggregate requests, tokens and cost.")
        }
    }
}
