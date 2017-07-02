import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
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

    GitManager {
        id: gitManager

        onInitialized: {
            if (errorCode)
                console.log("errorCode: " + errorCode);
            repositoryInputField.notify(!errorCode);
        }

        Component.onCompleted: {
            // FIXME(pvarga): Set path here to catch the first initialized() signal
            repositoryPath = "/Users/stampho/work/Qt/qt5-59-src/qtwebengine"
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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 35

            Text {
                text: "Repository:"
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30

                color: "white"
                radius: 4

                TextField {
                    id: repositoryInputField
                    anchors.fill: parent

                    function notify(success) {
                        bgColorChangeAnim.color = success ? "#32cd32" : "#ff6666";
                        bgColorChangeAnim.start();
                    }

                    SequentialAnimation {
                        id: bgColorChangeAnim

                        property color defaultColor: "white"
                        property color color: "white"
                        property int duration: 1000
                        property int easingType: Easing.InOutSine

                        ColorAnimation {
                            target: repositoryInputField.parent
                            property: "color"

                            from: bgColorChangeAnim.defaultColor
                            to: bgColorChangeAnim.color
                            duration: bgColorChangeAnim.duration / 2

                            easing.type: bgColorChangeAnim.easingType
                        }
                        ColorAnimation {
                            target: repositoryInputField.parent
                            property: "color"

                            from: bgColorChangeAnim.color
                            to: bgColorChangeAnim.defaultColor
                            duration: bgColorChangeAnim.duration / 2

                            easing.type: bgColorChangeAnim.easingType
                        }
                    }

                    text: gitManager.repositoryPath

                    style: TextFieldStyle {
                        padding.left: 10

                        background: Rectangle {
                            color: "transparent"
                            border.color: Qt.darker(palette.window, 2.0)
                            border.width: 1
                            radius: repositoryInputField.parent.radius
                        }
                    }

                    onActiveFocusChanged: activeFocus ? selectAll() : deselect()

                    onAccepted: {
                        gitManager.repositoryPath = repositoryInputField.text;
                        repositoryLoadButton.text = "Reload";
                    }

                    onTextChanged: {
                        if (text != gitManager.repositoryPath)
                            repositoryLoadButton.text = "Load";
                        else
                            repositoryLoadButton.text = "Reload";
                    }
                }
            }

            Button {
                id: repositoryLoadButton
                Layout.preferredWidth: 75
                Layout.preferredHeight: 30

                text: "Load"

                onClicked: {
                    gitManager.repositoryPath = repositoryInputField.text;
                    repositoryLoadButton.text = "Reload";
                }
            }

            Button {
                Layout.preferredWidth: 75
                Layout.preferredHeight: 30

                text: "Browse"

                onClicked: fileDialog.visible = true;

                FileDialog {
                    id: fileDialog

                    title: "Choose a folder"

                    selectExisting: true
                    selectMultiple: false
                    selectFolder: true

                    folder: shortcuts.home

                    onAccepted: {
                        var repositoryPath = fileUrl.toString();
                        var fileScheme = "file://";
                        if (repositoryPath.toString().startsWith(fileScheme))
                            repositoryPath = repositoryPath.substring(fileScheme.length);
                        repositoryInputField.text = repositoryPath;
                    }
                }
            }
        }

        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
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
