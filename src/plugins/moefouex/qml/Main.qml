// Main.qml
import QtDream.MoefouEx 1.0

Clock
{
    color: "green"
    anchors.centerIn: parent

    Time
    {
        id: time
    }

    hours: time.hour
    minutes: time.minute
}
