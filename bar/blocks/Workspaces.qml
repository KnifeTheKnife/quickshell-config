import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "../utils" as Utils
import "root:/"

RowLayout {
    property HyprlandMonitor monitor: Hyprland.monitorFor(screen)

    Rectangle {
        id: workspaceBar
        Layout.preferredWidth: workspaceRow.implicitWidth + 20
        Layout.preferredHeight: 23
        radius: 7
        color: Theme.get.barBgColor

        Row {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 5

            Repeater {
                model: Hyprland.workspaces

                Item {
                    required property var modelData
                    property bool focused: Hyprland.focusedMonitor?.activeWorkspace?.id === modelData.id

                    width: workspaceText.implicitWidth + 10
                    height: workspaceText.implicitHeight

                    Text {
                        id: workspaceText
                        text: modelData.id.toString()
                        color: "white"
                        font.pixelSize: 15
                        font.bold: focused
                    }

                    Rectangle {
                        visible: focused
                        anchors {
                            left: workspaceText.left
                            right: workspaceText.right
                            top: workspaceText.bottom
                            topMargin: -3
                        }
                        height: 2
                        color: "white"
                    }

                    DropShadow {
                        visible: focused
                        anchors.fill: workspaceText
                        horizontalOffset: 2
                        verticalOffset: 2
                        radius: 8.0
                        samples: 20
                        color: "#000000"
                        source: workspaceText
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Utils.HyprlandUtils.switchWorkspace(modelData.id)
                    }
                }
            }
        }
    }
}
