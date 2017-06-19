QT += qml quick

CONFIG += c++11

TARGET = gitscope
CONFIG -= app_bundle

TEMPLATE = app

SOURCES += main.cpp \
    gitmanager.cpp \
    commitdao.cpp \
    commit.cpp \
    commitmodel.cpp

QML_FILES += main.qml

macos: {
    INCLUDEPATH += /usr/local/include
    LIBS += /usr/local/lib/libgit2.dylib
}


# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

HEADERS += \
    gitmanager.h \
    commitdao.h \
    commit.h \
    commitmodel.h

RESOURCES += \
    gitscope.qrc
