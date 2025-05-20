#include "LogSaver.h"
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QDateTime>
#include <QTextStream>
#include <QDebug>

LogSaver::LogSaver(QObject *parent) : QObject(parent)
{
}

bool LogSaver::saveLogs(const QStringList &logs)
{
    QString dirPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    if (dirPath.isEmpty()) {
        qWarning() << "Не удалось получить путь к папке Загрузки";
        return false;
    }

    QDir dir(dirPath);
    if (!dir.exists()) {
        qWarning() << "Папка Загрузки не существует";
        return false;
    }

    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss");
    QString fileName = QString("sensor_logs_%1.txt").arg(timestamp);
    QString filePath = dir.filePath(fileName);

    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Не удалось открыть файл для записи:" << filePath;
        return false;
    }

    QTextStream out(&file);
    for (const QString &line : logs) {
        out << line << "\n";
    }
    file.close();

    qDebug() << "Логи сохранены в файл:" << filePath;
    return true;
}
