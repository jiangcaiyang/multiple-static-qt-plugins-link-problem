#include <QApplication>
#include <QtQml>
#include <QDebug>

#ifdef QTDREAM_STATIC
Q_IMPORT_PLUGIN( TimeExamplePlugin )
Q_IMPORT_PLUGIN( MoefouExPlugin )
#endif

int main(int argc, char **argv)
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

#ifdef QTDREAM_STATIC
    engine.addImportPath( "qrc:///qml" );
#else
    engine.addImportPath( "../qml" );
#endif

    engine.load( QUrl( "qrc:///main.qml" ) );

    return app.exec( );
}
