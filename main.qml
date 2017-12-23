import Qt.labs.settings 1.0
import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

import GitScope 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 768

    title: "GitScope"

    property int listItemHeight: 50
    property Item mainView: null

    StateGroup {
        id: viewMode

        state: appSettings.viewMode
        states: [
            State {
                name: "compact"
            },
            State {
                name: "table"
            }
        ]

        onStateChanged: {
            var currentCommitIndex = 0;
            if (mainView) {
                currentCommitIndex = mainView.currentCommitIndex;
                mainView.visible = false;
            }

            if (state == "compact")
                mainView = compactView
            else if (state == "table")
                mainView = tableView
            else
                console.error("Switched to an unknown view mode!");

            mainView.currentCommitIndex = currentCommitIndex;
            mainView.visible = true;
            mainView.focus = true;
        }

        Component.onCompleted: {
            if (!state)
                state = "compact";
        }
    }

    SystemPalette { id: palette }

    menuBar: MenuBar {
        Menu {
            title: "Window"
            ExclusiveGroup { id: viewGroup }

            Menu {
                title: "Views"

                MenuItem {
                    text: "Compact"
                    checkable: true
                    checked: viewMode.state == "compact"
                    exclusiveGroup: viewGroup
                    onTriggered: {
                        viewMode.state = "compact";
                    }
                }

                MenuItem {
                    text: "Table"
                    checkable: true
                    checked: viewMode.state == "table"
                    exclusiveGroup: viewGroup
                    onTriggered: {
                        viewMode.state = "table";
                    }
                }
            }
        }
    }

    statusBar: StatusBar {
        id: statusBar

        property string statusString: ""

        function update() {
            switch(gitManager.status) {
            case GitManager.Uninitialized:
                statusString = "<font color='#ff0000'><b>Uninitialized</b></font>";
                break;
            case GitManager.Dirty:
                statusString = "<font color='#ff0000'><b>Dirty</b></font>";
                break;
            case GitManager.Clean:
                statusString = "<font color='#008000'><b>Clean</b></font>";
                break;
            }

            statusInitialized.visible = !gitManager.errorCode;
            statusUninitialized.visible = gitManager.errorCode;
        }

        Rectangle {
            id: statusInitialized
            anchors.fill: parent
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            color: "transparent"

            Row {
                anchors.left: parent.left
                spacing: 20

                Label {
                    text: "<b>Commits: </b>" + mainView.commitCount + "/" + (mainView.commitCount - mainView.currentCommitIndex)
                }

                Label {
                    text: "<b>Branch: </b>" + gitManager.branch
                }

            }

            Label {
                anchors.right: parent.right
                text: "<b>Status: </b>" + statusBar.statusString
            }
        }

        Rectangle {
            id: statusUninitialized
            anchors.fill: parent
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            color: "transparent"

            Label {
                anchors.left: parent.left
                text: "<font color='red'><b>Error: </b></font>" + gitManager.errorMessage + " <font color='red'>(" + gitManager.errorCode + ")</font>"
            }

            Label {
                anchors.right: parent.right
                text: "<b>Status: </b>" + statusBar.statusString
            }
        }
    }

    Settings {
        id: appSettings

        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height

        property alias repositoryPath: gitManager.repositoryPath
        property alias topPanelState: topPanel.state
        property alias viewMode: viewMode.state
    }

    GitManager {
        id: gitManager

        property bool isReload: false
        property string previousRepositoryPath: ""

        onRepositoryPathChanged: {
            isReload = (previousRepositoryPath == repositoryPath);
            previousRepositoryPath = repositoryPath;
        }

        onInitialized: {
            if (!isReload && mainView) {
                mainView.reset();
                if (!errorCode)
                    mainView.update();
            }

            statusBar.update();
            repositoryInputBar.notify(!errorCode);
        }

        Component.onCompleted: {
            // WORKAROUND: Set path here to make possible to catch the first initialized() signal
            repositoryPath = appSettings.repositoryPath;
            repositoryInputBar.repositoryPath = repositoryPath;
        }
    }


    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        color: palette.window

        SliderPanel {
            id: topPanel
            orientation: Qt.Horizontal
            pos: parent.y
            width: parent.width
            height: 55
            anchors.horizontalCenter: parent.horizontalCenter

            RepositoryInputBar {
                id: repositoryInputBar
                anchors.fill: parent

                onLoad: {
                    gitManager.repositoryPath = repositoryPath;
                    mainView.focus = true;
                }
            }
        }

        Item {
            anchors.top: topPanel.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            CompactLayout {
                id: compactView
                anchors.fill: parent
                visible: false

                commitModel: gitManager.commitModel
            }

            TableLayout {
                id: tableView
                anchors.fill: parent
                visible: false

                commitModel: gitManager.commitModel
            }
        }
    }
}
