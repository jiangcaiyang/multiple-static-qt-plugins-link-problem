// Main.qml
import QtDream.TimeExample 1.0

Clock
{
    anchors.centerIn: parent

    Time
    {
        id: time
    }

    hours: time.hour
    minutes: time.minute
}
