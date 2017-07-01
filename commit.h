#ifndef COMMIT_H
#define COMMIT_H

#include <QMap>
#include <QObject>
#include <QString>

class CommitDao;

class Commit : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString hash READ hash CONSTANT FINAL)
    Q_PROPERTY(QString summary READ summary CONSTANT FINAL)
    Q_PROPERTY(QString message READ message CONSTANT FINAL)
    Q_PROPERTY(QString authorName READ authorName CONSTANT FINAL)
    Q_PROPERTY(QString authorEmail READ authorEmail CONSTANT FINAL)
    Q_PROPERTY(QString time READ time CONSTANT FINAL)
    Q_PROPERTY(QString diff READ diff CONSTANT FINAL)

public:
    enum AuthorInfo {
        Name,
        Email,
    };

    explicit Commit(const CommitDao *dao, QString hash = "", QObject *parent = 0);

    QString hash() const;
    QString summary();
    QString message();
    QString authorName();
    QString authorEmail();
    QString time();
    QString diff();

private:
    const CommitDao *m_dao;

    QString m_hash;
    QString m_summary;
    QString m_message;
    QMap<int, QString> m_author;
    QString m_time;
    QString m_diff;
};

#endif // COMMIT_H
