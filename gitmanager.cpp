#include <git2.h>

#include "commitdao.h"
#include "commitmodel.h"
#include "gitmanager.h"

GitManager::GitManager(QObject *parent)
    : QObject(parent)
    , m_repository(nullptr)
    , m_status(Status::Uninitialized)
    , m_commitDao(new CommitDao)
    , m_commitModel(new CommitModel)
{
    git_libgit2_init();

    connect(this, &GitManager::repositoryPathChanged, this, &GitManager::reset);
}

GitManager::~GitManager()
{
    git_repository_free(m_repository);
    git_libgit2_shutdown();
}

void GitManager::reset()
{
    if (m_repository)
        git_repository_free(m_repository);

    m_errorCode = git_repository_open(&m_repository, m_repositoryPath.toStdString().c_str());
    m_commitDao->setRepository(m_repository);
    m_commitModel->reset(m_commitDao.data());

    setStatus();
    emit statusChanged();
    setBranch();
    emit branchChanged();

    if (m_errorCode)
        m_errorMessage = QString(giterr_last()->message);
    else
        m_errorMessage.clear();

    emit initialized();
}

CommitModel *GitManager::commitModel()
{
    Q_ASSERT(!m_commitModel.isNull());
    return m_commitModel.data();
}

QString GitManager::repositoryPath() const
{
    return m_repositoryPath;
}

void GitManager::setRepositoryPath(const QString &repositoryPath)
{
    m_repositoryPath = repositoryPath;
    emit repositoryPathChanged();
}

QString GitManager::branch() const
{
    return m_branch;
}

void GitManager::setBranch()
{
    if (!m_repository) {
        m_branch.clear();
        return;
    }

    git_reference *head;
    git_repository_head(&head, m_repository);

    const char *name;
    git_branch_name(&name, head);
    m_branch = QString(name);

    git_reference_free(head);
}

GitManager::Status GitManager::status() const
{
   return m_status;
}

void GitManager::setStatus()
{
    if (!m_repository) {
        m_status = Status::Uninitialized;
        return;
    }

    git_status_options opts = GIT_STATUS_OPTIONS_INIT;
    git_status_list *statusList = nullptr;

    int errorCode = git_status_list_new(&statusList, m_repository, &opts);
    if (errorCode) {
        m_status = Status::Uninitialized;
        return;
    }

    size_t count = git_status_list_entrycount(statusList);
    m_status = (count == 0) ? Status::Clean : Status::Dirty;
    git_status_list_free(statusList);
}

int GitManager::errorCode() const
{
    return m_errorCode;
}

QString GitManager::errorMessage() const
{
    return m_errorMessage;
}
