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
    Q_PROPERTY(Status status READ status NOTIFY statusChanged FINAL)
    Q_PROPERTY(QString branch READ branch NOTIFY branchChanged FINAL)

public:
    enum Status {
        Uninitialized,
        Dirty,
        Clean
    };
    Q_ENUMS(Status)

    GitManager(QObject *parent = 0);
    ~GitManager();

    CommitModel *commitModel();
    QString repositoryPath() const;
    void setRepositoryPath(const QString &repositoryPath);
    QString branch() const;
    Status status() const;

signals:
    void repositoryPathChanged();
    void initialized(int errorCode);
    void statusChanged();
    void branchChanged();

private slots:
    void reset();

private:
    void setBranch();
    void setStatus();

    git_repository *m_repository;
    QString m_repositoryPath;
    Status m_status;
    QString m_branch;

    QScopedPointer<CommitDao> m_commitDao;
    QScopedPointer<CommitModel> m_commitModel;
};

#endif // GITMANAGER_H
