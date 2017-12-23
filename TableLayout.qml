import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

MainView {
    id: root

    property alias currentCommitIndex: commitTableView.currentRow

    function resetView() {
        if (visible) {
            commitTableView.selection.clear();
            commitTableView.positionViewAtRow(currentCommitIndex, ListView.Contain);
            commitTableView.selection.select(currentCommitIndex);
        }
    }

    onFocusChanged: {
        if (focus)
            commitTableView.forceActiveFocus();
    }

    onVisibleChanged: resetView();
    onReseted: resetView();

    SplitView {
        anchors.fill: parent
        orientation: Qt.Vertical

        Rectangle {
            Layout.fillWidth: true
            Layout.minimumHeight: 50
            height: 200

            color: palette.window

            TableView {
                id: commitTableView
                anchors.fill: parent

                model: root.commitModel
                focus: true

                TableViewColumn {
                    title: "Hash"
                    role: "hash"
                }

                TableViewColumn {
                    title: "Summary"
                    role: "summary"
                }

                TableViewColumn {
                    title: "Name"
                    role: "authorName"
                }

                TableViewColumn {
                    title: "E-mail"
                    role: "authorEmail"
                }

                TableViewColumn {
                    title: "Time"
                    role: "time"
                }

                Component.onCompleted: {
                    root.commitCount = Qt.binding(function() { return rowCount; });
                    root.currentCommitHash = Qt.binding(function() {
                        var hash = commitModel.get(currentRow).hash;
                        return hash ? hash : "";
                    });
                }
            }
        }

        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal

            TextArea {
                id: commitHeaderView
                Layout.minimumWidth: 100
                width: 400
                Layout.fillHeight: true

                text: root.currentCommitHeader
                textFormat: TextEdit.RichText
                readOnly: true;

                onFocusChanged: {
                    if (focus)
                        commitTableView.forceActiveFocus();
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
                        commitTableView.forceActiveFocus();
                }
            }
        }
    }
}
