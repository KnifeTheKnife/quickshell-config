import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/"

Rectangle {
    id: root
    required property var notification
    signal removeRequested()

    Layout.fillWidth: true
    Layout.preferredHeight: contentLayout.implicitHeight + 20

    color: mouseArea.containsMouse ? Theme.get.buttonBackgroundColor : Theme.get.barBgColor
    border.color: Theme.get.buttonBorderColor
    border.width: 1
    radius: 5

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    RowLayout {
        id: contentLayout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10
        }
        spacing: 10

        // App icon placeholder or actual icon
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop

            color: Theme.get.iconColor
            radius: 20

            Text {
                anchors.centerIn: parent
                text: notification.appName ? notification.appName.charAt(0).toUpperCase() : "?"
                color: Theme.get.barBgColor
                font.pixelSize: 16
                font.bold: true
            }
        }

        // Notification content
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 5

            // Header with app name and timestamp
            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: notification.appName || "Unknown App"
                    color: Theme.get.iconColor
                    font.pixelSize: 12
                    font.bold: true
                    opacity: 0.8
                }

                Text {
                    text: formatTime(notification.time)
                    color: Theme.get.iconColor
                    font.pixelSize: 10
                    opacity: 0.6
                }
            }

            // Summary
            Text {
                Layout.fillWidth: true
                text: notification.summary || "No subject"
                color: Theme.get.iconColor
                font.pixelSize: 14
                font.bold: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            // Body
            Text {
                Layout.fillWidth: true
                text: notification.body || ""
                color: Theme.get.iconColor
                font.pixelSize: 12
                wrapMode: Text.WordWrap
                maximumLineCount: 4
                elide: Text.ElideRight
                opacity: 0.9
                visible: notification.body && notification.body.length > 0
            }

            // Actions (if any)
            RowLayout {
                Layout.fillWidth: true
                visible: notification.actions && notification.actions.length > 0
                spacing: 5

                Repeater {
                    model: notification.actions || []

                    Rectangle {
                        Layout.preferredHeight: 25
                        Layout.preferredWidth: actionText.implicitWidth + 20

                        color: actionMouseArea.containsMouse ? Theme.get.iconPressedColor : "transparent"
                        border.color: Theme.get.buttonBorderColor
                        border.width: 1
                        radius: 3

                        Text {
                            id: actionText
                            anchors.centerIn: parent
                            text: modelData.text || modelData.name || "Action"
                            color: Theme.get.iconColor
                            font.pixelSize: 10
                        }

                        MouseArea {
                            id: actionMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (modelData.invoke) {
                                    modelData.invoke()
                                }
                                root.removeRequested()
                            }
                        }
                    }
                }
            }
        }

        // Close button
        Rectangle {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignTop

            color: closeMouseArea.containsMouse ? Theme.get.iconPressedColor : "transparent"
            border.color: Theme.get.iconColor
            border.width: 1
            radius: 10

            Text {
                anchors.centerIn: parent
                text: "×"
                color: Theme.get.iconColor
                font.pixelSize: 12
                font.bold: true
            }

            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.removeRequested()
            }
        }
    }

    function formatTime(timestamp) {
        if (!timestamp) return ""

        var now = new Date()
        var notifTime = new Date(timestamp)
        var diff = now.getTime() - notifTime.getTime()

        if (diff < 60000) { // Less than 1 minute
            return "now"
        } else if (diff < 3600000) { // Less than 1 hour
            return Math.floor(diff / 60000) + "m ago"
        } else if (diff < 86400000) { // Less than 1 day
            return Math.floor(diff / 3600000) + "h ago"
        } else {
            return Math.floor(diff / 86400000) + "d ago"
        }
    }
}
