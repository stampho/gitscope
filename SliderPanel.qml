import QtQuick 2.6

Item {
    id: root

    SystemPalette { id: palette }

    default property alias contents: content.data
    property int pos: 0
    property int handleSize: 15
    property int marginSize: 5
    property int orientation: Qt.Horizontal
    property int minSize: 0
    property color color: palette.window

    function isHorizontal() {
        return root.orientation == Qt.Horizontal;
    }

    property real p: isHorizontal() ? y : x
    property real size: isHorizontal() ? height : width

    Binding {
        target: root
        property: isHorizontal() ? "y" : "x"
        value: p
    }

    Binding {
        target: root
        property: isHorizontal() ? "height" : "width"
        value: size
    }

    state: "close"

    states: [
        State {
            name: "open"
            PropertyChanges { target: root; p: pos }
            PropertyChanges { target: handleArrow; rotation: 180 }
            PropertyChanges { target: content; size: root.size - root.marginSize - root.handleSize }
            PropertyChanges { target: margin; size: root.marginSize }
        },
        State {
            name: "close"
            PropertyChanges { target: root; p: pos - size + minSize + handleSize }
            PropertyChanges { target: handleArrow; rotation: 0 }
            PropertyChanges { target: content; size: root.minSize }
            PropertyChanges { target: margin; size: root.minSize ? root.size - root.minSize - root.handleSize + root.marginSize : 0 }
        }
    ]

    transitions: [
        Transition {
            ParallelAnimation {
                PropertyAnimation {
                    target: root
                    property: "p"
                    duration: 500
                    easing.type: Easing.InOutBack
                }
                PropertyAnimation {
                    target: handleArrow
                    property: "rotation"
                    duration: 500
                    easing.type: Easing.InOutBack
                }
                PropertyAnimation {
                    target: margin
                    property: "size"
                    duration: 500
                    easing.type: Easing.InOutBack
                }
                PropertyAnimation {
                    target: content
                    property: "size"
                    duration: 500
                    easing.type: Easing.InOutBack
                }
            }
        }
    ]

    Rectangle {
        id: margin
        property real size: root.marginSize

        anchors.top: root.top
        anchors.left: root.left

        width: root.isHorizontal() ? root.width : margin.size
        height: root.isHorizontal() ? margin.size : root.height

        color: root.color
    }

    Rectangle {
        id: content
        property real size: root.size - root.handleSize

        width: root.isHorizontal() ? root.width : content.size
        height: root.isHorizontal() ? content.size : root.height

        anchors.top: root.isHorizontal() ? margin.bottom : root.top
        anchors.left: root.isHorizontal() ? root.left : margin.right

        color: root.color
    }

    Rectangle {
        id: handle
        width: root.isHorizontal() ? root.width : root.handleSize
        height: root.isHorizontal() ? root.handleSize : root.height

        anchors.bottom: root.bottom
        anchors.right: root.right

        color: root.color
        clip: true

        MouseArea {
            anchors.fill: parent
            onClicked: root.state = (Math.round(root.p) < 0)  ? "open" : "close"
        }

        Canvas {
            id: handleArrow

            antialiasing:  true
            anchors.centerIn: parent

            width: root.isHorizontal() ? 14 : parent.width - 6
            height: root.isHorizontal() ? parent.height - 6 : 14

            onPaint: {
                var ctx = getContext("2d");

                ctx.strokeStyle = Qt.darker(root.color);
                ctx.fillStyle = Qt.darker(root.color);
                ctx.lineWidth = 1;
                ctx.lineJoin = "round";

                if (root.isHorizontal()) {
                    ctx.moveTo(width / 2, height);
                    ctx.lineTo(0, 0);
                    ctx.lineTo(width, 0);
                } else {
                    ctx.moveTo(width, height / 2);
                    ctx.lineTo(0, 0);
                    ctx.lineTo(0, height);
                }

                ctx.closePath();
                ctx.fill();
            }
        }
    }
}
