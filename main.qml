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

    SystemPalette { id: palette }

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
                    text: "<b>Commits: </b>" + commitListView.count + "/" + (commitListView.count - commitListView.currentIndex)
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
            if (!errorCode && !isReload)
                commitListView.currentIndex = 0;
            statusBar.update();
            repositoryInputBar.notify(!errorCode);
        }

        Component.onCompleted: {
            // WORKAROUND: Set path here to make possible to catch the first initialized() signal
            repositoryPath = appSettings.repositoryPath;
            repositoryInputBar.repositoryPath = repositoryPath;
        }
    }

    function commitHeader(commit) {
        var text = "";

        text += "<pre>";
        text += "<font color='#c7c524'>commit " + commit.hash + "</font><br>";
        text += "Author: " + commit.authorName + " &lt;" + commit.authorEmail + "&gt;<br>";
        text += "Date:   " + commit.time;
        text += "</pre>";

        text += "<pre style=\"text-indent:30px\">";
        text += commit.message;
        text += "</pre>";

        return text;
    }

    function commitContent(commit) {
        var text = "";

        text += "<pre style='color:#999999'>";
        var lines = commit.diff.split('\n');
        for (var i = 0; i < lines.length; ++i) {
            var line = lines[i];
            line = line.replace(/</g, "&lt;");
            line = line.replace(/>/g, "&gt;");

            if (line.startsWith("diff --git") ||
                    line.startsWith("index ") ||
                    line.startsWith("--- ") ||
                    line.startsWith("+++ ") ||
                    line.startsWith("new file mode") ||
                    line.startsWith("deleted file mode")) {
                line = "<font color='#000000'>" + line + "</font>";
            } else if (line.startsWith("-")) {
                line = "<font color='#ff0000'>" + line + "</font>";
            } else if (line.startsWith("+")) {
                line = "<font color='#008000'>" + line + "</font>";
            } else if (line.startsWith("@@ ")) {
                var parts = line.match("(@@.*?@@)(.*)");
                line = "<font color='#00a0a0'>" + parts[1] + "</font>"+ parts[2];
            }

            text += line + "\n";
        }
        text += "</pre>";

        return text;
    }

    Connections {
        target: commitListView
        onSelected: {
            var commit = gitManager.commitModel.getCommit(hash);

            commitView.text = commitHeader(commit);
            diffView.text = commitContent(commit);
        }
    }

    Connections {
        target: gitManager.commitModel
        onModelReset: {
            diffView.text = "";
            commitView.text = "";
        }
    }

    Component {
        id: commitDelegate
        Item {
            property string commitHash: hash

            width: parent.width
            height: listItemHeight

            Column {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: summary
                    color: palette.text
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: "<b>Author: </b>" + authorName + " &lt;" + authorEmail + "&gt;"
                    color: palette.shadow
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: "<b>Date: </b>" + time
                    color: palette.shadow
                    elide: Text.ElideRight
                    width: parent.width
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (index == commitListView.currentIndex)
                        return;
                    commitListView.currentIndex = index;
                    commitListView.forceActiveFocus();
                }
            }
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
                    gitManager.repositoryPath = repositoryPath
                }
            }
        }

        SplitView {
            anchors.top: topPanel.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            orientation: Qt.Horizontal

            Rectangle {
                Layout.minimumWidth: 100
                width: 400
                Layout.fillHeight: true

                color: palette.window

                ListView {
                    id: commitListView
                    anchors.fill: parent

                    signal selected(var hash)

                    model: gitManager.commitModel
                    delegate: commitDelegate
                    focus: true
                    spacing: 5

                    highlightFollowsCurrentItem: false
                    highlight: Rectangle {
                        width: commitListView.width
                        height: listItemHeight
                        y: commitListView.currentItem.y
                        color: palette.highlight
                        radius: 5

                        Behavior on y {
                            SpringAnimation {
                                spring: 5
                                damping: 0.5
                            }
                        }
                    }

                    onCurrentItemChanged: selected(currentItem.commitHash);
                }
            }

            SplitView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: Qt.Vertical

                TextArea {
                    id: commitView
                    Layout.fillWidth: true
                    Layout.minimumHeight: 50
                    height: 200
                    textFormat: TextEdit.RichText
                    readOnly: true;

                    onFocusChanged: {
                        if (focus)
                            commitListView.forceActiveFocus();
                    }

                    Component.onCompleted: {
                        if (commitListView.currentIndex == -1)
                            return;

                        // WORKAROUND: commitListView.selected signal is emmitted earlier
                        // than the corresponding Connections is created
                        var hash = commitListView.currentItem.commitHash;
                        var commit = gitManager.commitModel.getCommit(hash);

                        commitView.text = commitHeader(commit);
                    }
                }

                TextArea {
                    id: diffView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    textFormat: TextEdit.RichText
                    readOnly: true

                    onFocusChanged: {
                        if (focus)
                            commitListView.forceActiveFocus();
                    }

                    Component.onCompleted: {
                        if (commitListView.currentIndex == -1)
                            return;

                        // WORKAROUND: commitListView.selected signal is emmitted earlier
                        // than the corresponding Connections is created
                        var hash = commitListView.currentItem.commitHash;
                        var commit = gitManager.commitModel.getCommit(hash);
                        diffView.text = commitContent(commit);
                    }
                }
            }
        }
    }
}
