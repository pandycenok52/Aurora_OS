#include <auroraapp.h>
#include <QtQuick>
#include "LogSaver.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.template"));
    application->setApplicationName(QStringLiteral("untitled2"));

    QScopedPointer<QQuickView> view(Aurora::Application::createView());

    // Создаем объект LogSaver
    LogSaver logSaver;

    // Получаем контекст QML и регистрируем объект
    QQmlContext *context = view->rootContext();
    context->setContextProperty("logSaver", &logSaver);

    // Загружаем QML
    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/untitled2.qml")));
    view->show();

    return application->exec();
}
