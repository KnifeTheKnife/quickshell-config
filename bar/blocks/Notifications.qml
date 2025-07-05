import QtQuick
import Quickshell.Services.Notifications
import "../"

BarBlock {
    id: root
    property bool showNotification: false
    property int notificationCount: 0

    text: " " + notificationCount
    dim: notificationCount === 0

    onClicked: function() {
        showNotification = !showNotification
    }

    // Update notification count when tracked notifications change
    Connections {
        target: notifServer.trackedNotifications
        function onValuesChanged() {
            notificationCount = notifServer.trackedNotifications.values.length
        }
    }

    NotificationServer {
        id: notifServer
        onNotification: (notification) => {
            notification.tracked = true
            notificationCount = notifServer.trackedNotifications.values.length
        }
    }

    NotificationPanel {
        id: notificationPanel
        text_color: "#FFFFFF"
        visible: showNotification

        anchors {
            top: parent.bottom
            right: parent.right
        }

        margins {
            top: 5
            right: 0
        }

        // Close panel when clicking outside
        Component.onCompleted: {
            // Connect to the notification server in the panel
            notificationPanel.server.onNotification.connect(function(notification) {
                notificationCount = notifServer.trackedNotifications.values.length
            })
        }
    }

    // Close notification panel when clicking elsewhere
    Connections {
        target: Quickshell.screens[0] // Assuming single screen for now
        function onClicked() {
            if (showNotification) {
                showNotification = false
            }
        }
    }
}
