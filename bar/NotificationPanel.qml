import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

PanelWindow {
    id: notificationPanel
    required property color text_color
    property list<QtObject> notification_objects: []

    width: 400
    height: 600

    color: "#171a18"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        id: mainContainer
        border.width: 2
        border.color: "#8ec07c"
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            id: content
            anchors {
                left: parent.left
                leftMargin: 10
                right: parent.right
                rightMargin: 10
                top: parent.top
                topMargin: 10
                bottom: parent.bottom
                bottomMargin: 10
            }
            spacing: 10

            // Header
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 30

                Text {
                    Layout.fillWidth: true
                    text: "Notifications (" + notification_objects.length + ")"
                    color: text_color
                    font.pixelSize: 16
                    font.bold: true
                }

                Rectangle {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 25
                    color: clearMouseArea.containsMouse ? "#8ec07c" : "transparent"
                    border.color: "#8ec07c"
                    border.width: 1
                    radius: 3

                    Text {
                        anchors.centerIn: parent
                        text: "Clear"
                        color: text_color
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: clearMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: clearAllNotifications()
                    }
                }
            }

            // Notifications list
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    id: notificationsList
                    width: parent.width
                    spacing: 5
                }
            }

            // Empty state
            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: notification_objects.length === 0
                text: "No notifications"
                color: text_color
                font.pixelSize: 14
                opacity: 0.6
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    NotificationServer {
        id: server
        onNotification: (notification) => {
            notification.tracked = true
            addNotification(notification)
        }
    }

    function addNotification(notification) {
        var notificationComponent = Qt.createComponent("Notification.qml")

        if (notificationComponent.status === Component.Ready) {
            var notificationObject = notificationComponent.createObject(notificationsList, {
                notification: notification,
                text_color: text_color,
                onRemoveRequested: function() {
                    removeNotification(notificationObject)
                }
            })

            if (notificationObject !== null) {
                notification_objects.push(notificationObject)
            } else {
                console.log("Error creating notification object")
            }
        } else {
            console.log("Error loading notification component:", notificationComponent.errorString())
        }
    }

    function removeNotification(notificationObject) {
        var index = notification_objects.indexOf(notificationObject)
        if (index !== -1) {
            notification_objects.splice(index, 1)
            notificationObject.destroy()
        }
    }

    function clearAllNotifications() {
        // Clear tracked notifications from server
        var trackedNotifications = server.trackedNotifications.values
        for (var i = 0; i < trackedNotifications.length; i++) {
            trackedNotifications[i].tracked = false
        }

        // Destroy all notification objects
        for (var j = 0; j < notification_objects.length; j++) {
            notification_objects[j].destroy()
        }
        notification_objects = []
    }
}
