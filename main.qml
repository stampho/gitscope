import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 600

    title: "GitScope"

    property int listItemHeight: 50

    Component {
        id: commitDelegate
        Item {
            width: parent.width - 1
            height: listItemHeight

            Column {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: summary
                    color: "black"
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: "<b>Author: </b>" + authorName + " &lt;" + authorEmail + "&gt;"
                    color: "#444444"
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: "<b>Date: </b>" + time
                    color: "#444444"
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
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        Rectangle {
            Layout.preferredWidth: 400
            Layout.fillHeight: true
            color: "#eeeeee"

            border.width: 0
            border.color: "gray"

            ListView {
                id: commitListView
                anchors.fill: parent

                model: commitModel
                delegate: commitDelegate
                focus: true
                spacing: 5

                highlightFollowsCurrentItem: false
                highlight: Rectangle {
                    width: commitListView.width
                    height: listItemHeight
                    y: commitListView.currentItem.y
                    color: "lightsteelblue";
                    radius: 5

                    Behavior on y {
                        SpringAnimation {
                            spring: 5
                            damping: 0.2
                        }
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "white"
        }
    }
}
