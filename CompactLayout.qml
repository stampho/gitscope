import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

MainView {
    id: root

    property alias currentCommitIndex: commitListView.currentIndex

    onFocusChanged: {
        if (focus)
            commitListView.forceActiveFocus();
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

                model: root.commitModel
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

                Component.onCompleted: {
                    root.commitCount = Qt.binding(function() { return count; });
                    root.currentCommitHash = Qt.binding(function() { return currentItem ? currentItem.commitHash : ""; });
                }
            }
        }

        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Vertical

            TextArea {
                id: commitHeaderView
                Layout.fillWidth: true
                Layout.minimumHeight: 50
                height: 200

                text: root.currentCommitHeader
                textFormat: TextEdit.RichText
                readOnly: true;

                onFocusChanged: {
                    if (focus)
                        commitListView.forceActiveFocus();
                }
            }

            TextArea {
                id: commitDiffView
                Layout.fillWidth: true
                Layout.fillHeight: true

                text: root.currentCommitDiff
                textFormat: TextEdit.RichText
                readOnly: true

                onFocusChanged: {
                    if (focus)
                        commitListView.forceActiveFocus();
                }
            }
        }
    }
}
