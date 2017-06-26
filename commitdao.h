#ifndef COMMITDAO_H
#define COMMITDAO_H

#include <QDateTime>
#include <QList>
#include <QMap>

struct git_repository;
class Commit;

class CommitDao
{
public:
    CommitDao(git_repository *repository);

    QList<Commit *> getCommits() const;

    QString getSummary(const QString &hash) const;
    QMap<int, QString> getAuthor(const QString &hash) const;
    QDateTime getTime(const QString &hash) const;

private:
    git_repository *m_repository;
};

#endif // COMMITDAO_H
