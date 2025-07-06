import QtQuick
import Quickshell
import Quickshell.Io
import "../"

BarBlock {
    id: root
    property int notificationCount: 0

    text: " " + notificationCount
    dim: notificationCount === 0
    content: BarText {
        symbolText: "󰂚"  // Bell icon from Nerd Font
        hasNotifications: notificationCount > 0
        notificationCount: root.notificationCount
        dim: notificationCount === 0
        color: "#FFFFFF"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Toggle swaync notification center
            swayncToggle.running = true
        }
    }

    // Toggle swaync
    Process {
        id: swayncToggle
        command: ["swaync-client", "-t", "-sw"]

        Component.onCompleted: {
            finished.connect(function() {
                swayncToggle.running = false
                // Update count after potential dismissals
                countUpdateTimer.start()
            })
        }
    }

    // Get notification count
    Process {
        id: swayncCount
        command: ["swaync-client", "-c"]

        Component.onCompleted: {
            finished.connect(function(exitCode, stdout, stderr) {
                swayncCount.running = false
                if (exitCode === 0) {
                    var count = parseInt(stdout.trim())
                    if (!isNaN(count)) {
                        notificationCount = count
                    }
                }
            })
        }
    }

    // Periodic count updates
    Timer {
        id: countTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!swayncCount.running) {
                swayncCount.running = true
            }
        }
    }

    // Delayed count update
    Timer {
        id: countUpdateTimer
        interval: 500
        onTriggered: {
            if (!swayncCount.running) {
                swayncCount.running = true
            }
        }
    }

    // Subscribe to swaync events for real-time updates
    Process {
        id: swayncSubscribe
        command: ["swaync-client", "-s"]

        Component.onCompleted: {
            stdout.connect(function(stdout) {
                // New notification or dismissal - update count
                countUpdateTimer.start()
            })

            finished.connect(function(exitCode) {
                swayncSubscribe.running = false
                // Restart subscription if it ended
                if (exitCode !== 0) {
                    subscribeRestartTimer.start()
                }
            })
        }
    }

    // Restart subscription timer
    Timer {
        id: subscribeRestartTimer
        interval: 3000
        onTriggered: {
            if (!swayncSubscribe.running) {
                swayncSubscribe.running = true
            }
        }
    }

    Component.onCompleted: {
        // Initial setup
        swayncCount.running = true
        swayncSubscribe.running = true
    }

    Component.onDestruction: {
        if (swayncSubscribe.running) {
            swayncSubscribe.running = false
        }
    }
}
