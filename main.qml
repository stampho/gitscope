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
            var commit = commitModel.getCommit(hash);

            commitView.text = commitHeader(commit);
            diffView.text = commitContent(commit);
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

    SplitView {
        anchors.fill: parent
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

                model: commitModel
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
                    // WORKAROUND: commitListView.selected signal is emmitted earlier
                    // than the corresponding Connections is created
                    var hash = commitListView.currentItem.commitHash;
                    var commit = commitModel.getCommit(hash);

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
                    // WORKAROUND: commitListView.selected signal is emmitted earlier
                    // than the corresponding Connections is created
                    var hash = commitListView.currentItem.commitHash;
                    var commit = commitModel.getCommit(hash);
                    diffView.text = commitContent(commit);
                }
            }
        }
    }
}
