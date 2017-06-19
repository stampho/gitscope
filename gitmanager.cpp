#include <git2.h>

#include "commitdao.h"
#include "gitmanager.h"

GitManager &GitManager::instance()
{
    static GitManager singleton;
    return singleton;
}

GitManager::GitManager(const QString &path)
    : m_repository(nullptr)
    , m_commitDao(nullptr)
{
    git_libgit2_init();

    int error = git_repository_open(&m_repository, path.toStdString().c_str());
    // TODO(pvarga): Add proper error handling
    if (error) {
        fprintf(stderr, "error: %d\n", error);
        exit(1);
    }

    Q_ASSERT(m_repository);
    m_commitDao.reset(new CommitDao(m_repository));
}

GitManager::~GitManager()
{
    git_repository_free(m_repository);
    git_libgit2_shutdown();
}

CommitDao *GitManager::commitDao() const
{
    Q_ASSERT(!m_commitDao.isNull());
    return m_commitDao.data();
}
