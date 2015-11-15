# timeexample.pro 测试的项目
include ( ../../deploy.pri )

TEMPLATE = lib
TARGET = TimeExamplePlugin
QT += qml quick
version = 1.0
uri = QtDream.TimeExample

RESOURCES += Assets.qrc
DISTFILES += qmldir

platformDir = $$absolute_path( $$PWD/../../../$$SPEC )

qtHaveModule( qml ) {

    HEADERS += TimeExamplePlugin.h
    SOURCES += TimeExamplePlugin.cpp

    deployQML( $$platformDir, $$uri, $$version )

} else {
    deploy( $$platformDir )
}
