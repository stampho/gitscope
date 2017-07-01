import QtQuick.Controls.Styles 1.4
    SystemPalette { id: palette }

    GitManager {
        id: gitManager

        onInitialized: {
            if (errorCode)
                console.log("errorCode: " + errorCode);
        }

        Component.onCompleted: {
            // FIXME(pvarga): Set path here to catch the first initialized() signal
            repositoryPath = "/Users/stampho/work/Qt/qt5-59-src/qtwebengine"
        }
    }

            var commit = gitManager.commitModel.getCommit(hash);
                    color: palette.text
                    color: palette.shadow
                    color: palette.shadow
    ColumnLayout {
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

                    text: gitManager.repositoryPath

                    style: TextFieldStyle {
                        padding.left: 10
                        background: Rectangle {
                            color: "transparent"
                            border.color: Qt.darker(palette.window, 2.0)
                            border.width: 1
                            radius: repositoryInputField.parent.radius
                        }

                    onAccepted: gitManager.repositoryPath = repositoryInputField.text
                    onActiveFocusChanged: activeFocus ? selectAll() : deselect()
            Button {
                Layout.preferredWidth: 75
                Layout.preferredHeight: 30

                text: "Load"

                onClicked: gitManager.repositoryPath = repositoryInputField.text;
            }
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
            SplitView {
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