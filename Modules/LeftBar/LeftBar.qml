import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Common
import qs.Modules
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    property var modelData
    property string screenName: modelData.name
    property real backgroundTransparency: SettingsData.topBarTransparency
    property bool autoHide: SettingsData.topBarAutoHide
    property bool reveal: SettingsData.topBarVisible && (!autoHide || leftBarMouseArea.containsMouse)
    readonly property real effectiveBarWidth: Math.max(root.widgetWidth + SettingsData.topBarInnerPadding + 4, Theme.barHeight - 4 - (8 - SettingsData.topBarInnerPadding))
    readonly property real widgetWidth: Math.max(20, 26 + SettingsData.topBarInnerPadding * 0.6)

    screen: modelData
    implicitWidth: effectiveBarWidth + SettingsData.topBarSpacing
    color: "transparent"

    anchors {
        top: true
        left: true
        bottom: true
    }

    exclusiveZone: !SettingsData.topBarVisible ? -1 : root.effectiveBarWidth + SettingsData.topBarSpacing - 2

    mask: Region {
        item: leftBarMouseArea
    }

    MouseArea {
        id: leftBarMouseArea
        width: root.reveal ? effectiveBarWidth + SettingsData.topBarSpacing : 4
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        hoverEnabled: true
        
        onEntered: {
            if (root.autoHide) {
                root.reveal = true
            }
        }
        
        onExited: {
            if (root.autoHide) {
                root.reveal = false
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Item {
            id: leftBarContainer
            anchors.fill: parent

            transform: Translate {
                id: leftBarSlide
                x: root.reveal ? 0 : -(effectiveBarWidth - 4)

                Behavior on x {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Item {
                anchors.fill: parent
                anchors.topMargin: SettingsData.topBarSpacing
                anchors.bottomMargin: SettingsData.topBarSpacing
                anchors.leftMargin: SettingsData.topBarSpacing
                anchors.rightMargin: 0

                Rectangle {
                    anchors.fill: parent
                    radius: SettingsData.topBarSquareCorners ? 0 : Theme.cornerRadius
                    color: Qt.rgba(Theme.surfaceContainer.r,
                                   Theme.surfaceContainer.g,
                                   Theme.surfaceContainer.b,
                                   root.backgroundTransparency)
                    layer.enabled: true

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: Theme.outlineMedium
                        border.width: 1
                        radius: parent.radius
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(Theme.surfaceTint.r,
                                       Theme.surfaceTint.g,
                                       Theme.surfaceTint.b, 0.04)
                        radius: parent.radius

                        SequentialAnimation on opacity {
                            running: false
                            loops: Animation.Infinite

                            NumberAnimation {
                                to: 0.08
                                duration: Theme.extraLongDuration
                                easing.type: Theme.standardEasing
                            }

                            NumberAnimation {
                                to: 0.02
                                duration: Theme.extraLongDuration
                                easing.type: Theme.standardEasing
                            }
                        }
                    }

                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowHorizontalOffset: 4
                        shadowVerticalOffset: 0
                        shadowBlur: 0.5
                        shadowColor: Qt.rgba(0, 0, 0, 0.15)
                        shadowOpacity: 0.15
                    }
                }

                Item {
                    id: leftBarContent
                    anchors.fill: parent

                    // Basic container for future widgets
                    Item {
                        id: leftBarWidgets
                        anchors.fill: parent
                        anchors.margins: SettingsData.topBarInnerPadding

                        // Placeholder for future content
                        Text {
                            anchors.centerIn: parent
                            text: "Left Bar"
                            color: Theme.surfaceText
                            font.pixelSize: 12
                            opacity: 0.5
                        }
                    }
                }
            }
        }
    }

    Connections {
        function onTopBarTransparencyChanged() {
            root.backgroundTransparency = SettingsData.topBarTransparency
        }
        function onTopBarAutoHideChanged() {
            root.autoHide = SettingsData.topBarAutoHide
        }
        function onTopBarVisibleChanged() {
            root.reveal = SettingsData.topBarVisible && (!root.autoHide || leftBarMouseArea.containsMouse)
        }
        target: SettingsData
    }
}
