#ifndef GITMANAGER_H
#define GITMANAGER_H

#include <QScopedPointer>
#include <QString>

struct git_repository;
class CommitDao;

const QString REPOSITORY_PATH = "/Users/stampho/work/Qt/qt5-59-src/qtwebengine";

class GitManager
{
public:
    static GitManager &instance();

    CommitDao *commitDao() const;

private:
    GitManager(const QString &path = REPOSITORY_PATH);
    ~GitManager();

    git_repository *m_repository;
    QScopedPointer<CommitDao> m_commitDao;
};

#endif // GITMANAGER_H
