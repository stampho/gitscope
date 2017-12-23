import QtQuick 2.0

Rectangle {
    id: root

    property int commitCount: 0
    property string currentCommitHash: ""
    property string currentCommitHeader: ""
    property string currentCommitDiff: ""

    property var commitModel

    signal reseted();

    SystemPalette { id: palette }

    onCurrentCommitHashChanged: {
        update();
    }

    Component.onCompleted: {
        reset();
        update();
    }

    function reset() {
        currentCommitHeader = "";
        currentCommitDiff = "";
        currentCommitIndex = 0;
        reseted();
    }

    function update() {
        var commit = commitModel.getCommit(currentCommitHash);
        if (!commit)
            return;

        currentCommitHeader = commitHeader(commit);
        currentCommitDiff = commitDiff(commit);
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

    function commitDiff(commit) {
        var text = "";

        text += "<pre style='color:#999999'>";
        var lines = commit.diff.split('\n');
        for (var i = 0; i < lines.length; ++i) {
            var line = lines[i];
            line = line.replace(/</g, "&lt;");
            line = line.replace(/>/g, "&gt;");

            if (line.match("^diff --git.*$") ||
                    line.match("^index .*$") ||
                    line.match("^--- .*$") ||
                    line.match("^[+]{3} .*$") ||
                    line.match("^new file mode.*$") ||
                    line.match("^deleted file mode.*$")) {
                line = "<font color='#000000'>" + line + "</font>";
            } else if (line.match("^-.*$")) {
                line = "<font color='#ff0000'>" + line + "</font>";
            } else if (line.match("^[+].*$")) {
                line = "<font color='#008000'>" + line + "</font>";
            } else if (line.match("^@@ .*$")) {
                var parts = line.match("^(@@.*?@@)(.*)$");
                line = "<font color='#00a0a0'>" + parts[1] + "</font>"+ parts[2];
            }

            text += line + "\n";
        }
        text += "</pre>";

        return text;
    }
}
