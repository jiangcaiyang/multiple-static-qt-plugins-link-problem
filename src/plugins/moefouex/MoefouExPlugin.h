#ifndef TIMEEXAMPLEPLUGIN_H

#include <QTime>
#include <QBasicTimer>
#include <QQmlExtensionPlugin>

// Implements a "TimeModel" class with hour and minute properties
// that change on-the-minute yet efficiently sleep the rest
// of the time.
class MinuteTimerEx : public QObject
{
    Q_OBJECT
public:
    MinuteTimerEx(QObject *parent) : QObject(parent)
    {
    }

    void start()
    {
        if (!timer.isActive()) {
            time = QTime::currentTime();
            timer.start(60000-time.second()*1000, this);
        }
    }

    void stop()
    {
        timer.stop();
    }

    int hour() const { return time.hour(); }
    int minute() const { return time.minute(); }

signals:
    void timeChanged();

protected:
    void timerEvent(QTimerEvent *);

private:
    QTime time;
    QBasicTimer timer;
};

//![0]
class TimeModelEx : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int hour READ hour NOTIFY timeChanged)
    Q_PROPERTY(int minute READ minute NOTIFY timeChanged)
//![0]

public:
    TimeModelEx(QObject *parent=0);

    ~TimeModelEx()
    {
        if (--instances == 0) {
            timer->stop();
        }
    }

    int minute() const { return timer->minute(); }
    int hour() const { return timer->hour(); }

signals:
    void timeChanged();

private:
    QTime t;
    static MinuteTimerEx *timer;
    static int instances;
};


class MoefouExPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")
public:
    void registerTypes( const char* uri );
};

#endif
