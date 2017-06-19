#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "commitmodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    CommitModel commitModel;

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();

    context->setContextProperty("commitModel", &commitModel);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
