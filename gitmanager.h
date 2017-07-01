#ifndef GITMANAGER_H
#define GITMANAGER_H

#include <QObject>
#include <QScopedPointer>
#include <QString>

struct git_repository;
class CommitDao;
class CommitModel;

class GitManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(CommitModel *commitModel READ commitModel CONSTANT FINAL)
    Q_PROPERTY(QString repositoryPath READ repositoryPath WRITE setRepositoryPath NOTIFY repositoryPathChanged FINAL)

public:
    GitManager(QObject *parent = 0);
    ~GitManager();

    CommitModel *commitModel();
    QString repositoryPath() const;
    void setRepositoryPath(const QString &repositoryPath);

signals:
    void repositoryPathChanged();
    void initialized(int errorCode);

private slots:
    void reset();

private:
    QString m_repositoryPath;
    git_repository *m_repository;
    QScopedPointer<CommitDao> m_commitDao;
    QScopedPointer<CommitModel> m_commitModel;
};

#endif // GITMANAGER_H
