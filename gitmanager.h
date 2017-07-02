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
    Q_PROPERTY(int errorCode READ errorCode NOTIFY initialized FINAL)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY initialized FINAL)

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
    int errorCode() const;
    QString errorMessage() const;

signals:
    void repositoryPathChanged();
    void statusChanged();
    void branchChanged();
    void initialized();

private slots:
    void reset();

private:
    void setBranch();
    void setStatus();

    git_repository *m_repository;
    QString m_repositoryPath;
    Status m_status;
    QString m_branch;
    int m_errorCode;
    QString m_errorMessage;

    QScopedPointer<CommitDao> m_commitDao;
    QScopedPointer<CommitModel> m_commitModel;
};

#endif // GITMANAGER_H
