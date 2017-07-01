#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "commit.h"
#include "commitmodel.h"
#include "gitmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<GitManager>("GitScope", 1, 0, "GitManager");
    qmlRegisterUncreatableType<Commit>("GitScope", 1, 0, "Commit", QGuiApplication::tr("Cannot instantiate \"Commit\" in QML!"));
    qmlRegisterUncreatableType<CommitModel>("GitScope", 1, 0, "CommitModel", QGuiApplication::tr("Cannot instantiate \"CommitModel\" in QML!"));

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
