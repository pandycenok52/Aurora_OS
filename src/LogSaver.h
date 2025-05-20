#ifndef LOGSAVER_H
#define LOGSAVER_H

#include <QObject>
#include <QStringList>

class LogSaver : public QObject
{
    Q_OBJECT
public:
    explicit LogSaver(QObject *parent = nullptr);

    Q_INVOKABLE bool saveLogs(const QStringList &logs);
};

#endif // LOGSAVER_H
