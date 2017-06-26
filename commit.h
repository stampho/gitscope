#ifndef COMMIT_H
#define COMMIT_H

#include <QMap>
#include <QString>

class CommitDao;

class Commit
{
public:
    enum AuthorInfo {
        Name,
        Email,
    };

    explicit Commit(const CommitDao *dao, QString hash = "");

    QString hash() const;
    QString summary();
    QString author(AuthorInfo);
    QString time();

private:
    const CommitDao *m_dao;

    QString m_hash;
    QString m_summary;
    QMap<int, QString> m_author;
    QString m_time;
};

#endif // COMMIT_H
