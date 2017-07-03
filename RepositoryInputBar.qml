import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

RowLayout {
    id: root

    property string repositoryPath: ""

    // Use this signal instead of onRepositoryPathChanged to catch "Reload" changes too
    signal load()

    function notify(success) {
        bgColorChangeAnim.color = success ? "#32cd32" : "#ff6666";
        bgColorChangeAnim.start();
    }

    Label {
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

            text: root.repositoryPath

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
                root.repositoryPath = repositoryInputField.text;
                root.load();
                repositoryLoadButton.text = "Reload";
            }

            onTextChanged: {
                if (text != root.repositoryPath)
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
            root.repositoryPath = repositoryInputField.text;
            root.load();
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
                if (repositoryPath.match(fileScheme))
                    repositoryPath = repositoryPath.substring(fileScheme.length);
                repositoryInputField.text = repositoryPath;
                root.repositoryPath = repositoryInputField.text;
                root.load();
                repositoryLoadButton.text = "Reload";
            }
        }
    }
}
