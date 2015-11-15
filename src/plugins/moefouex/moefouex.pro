# timeexample.pro 测试的项目
include ( ../../deploy.pri )

TEMPLATE = lib
TARGET = MoefouExPlugin
QT += qml quick
version = 1.0
uri = QtDream.MoefouEx

RESOURCES += Assets.qrc
DISTFILES += qmldir

platformDir = $$absolute_path( $$PWD/../../../$$SPEC )

qtHaveModule( qml ) {

    HEADERS += MoefouExPlugin.h
    SOURCES += MoefouExPlugin.cpp

    deployQML( $$platformDir, $$uri, $$version )

} else {
    deploy( $$platformDir )
}
