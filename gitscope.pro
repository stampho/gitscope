QT += qml quick

CONFIG += c++11

TARGET = gitscope
CONFIG -= app_bundle

TEMPLATE = app

macos: {
    INCLUDEPATH += /usr/local/include
    LIBS += /usr/local/lib/libgit2.dylib
}

linux: LIBS += -lgit2

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
    commit.cpp \
    commitdao.cpp \
    commitmodel.cpp \
    gitmanager.cpp \
    main.cpp

HEADERS += \
    commit.h \
    commitdao.h \
    commitmodel.h \
    gitmanager.h

OTHER_FILES += \
    main.qml

RESOURCES += \
    gitscope.qrc
