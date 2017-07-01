#include <git2.h>

#include "commitdao.h"
#include "commitmodel.h"
#include "gitmanager.h"

GitManager::GitManager(QObject *parent)
    : QObject(parent)
    , m_repository(nullptr)
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

    int errorCode = git_repository_open(&m_repository, m_repositoryPath.toStdString().c_str());
    m_commitDao->setRepository(m_repository);
    m_commitModel->reset(m_commitDao.data());
    emit initialized(errorCode);
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
