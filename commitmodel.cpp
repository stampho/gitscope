#include "commit.h"
#include "commitdao.h"
#include "commitmodel.h"

CommitModel::CommitModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_git(GitManager::instance())
{
    for (const QString &hash : m_git.commitDao()->getCommitHashList())
        m_commits.append(new Commit(m_git.commitDao(), hash, this));
}

int CommitModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_commits.size();
}

QVariant CommitModel::data(const QModelIndex &index, int role) const
{
    if (!isIndexValid(index))
        return QVariant();

    Commit *commit = m_commits[index.row()];
    switch (role) {
    case Roles::HashRole:
        return commit->hash();
    case Roles::SummaryRole:
    case Qt::DisplayRole:
        return commit->summary();
    case Roles::AuthorNameRole:
        return commit->authorName();
    case Roles::AuthorEmailRole:
        return commit->authorEmail();
    case Roles::TimeRole:
        return commit->time();

    default:
        return QVariant();
    }
}

QHash<int, QByteArray> CommitModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Roles::HashRole] = "hash";
    roles[Roles::SummaryRole] = "summary";
    roles[Roles::AuthorNameRole] = "authorName";
    roles[Roles::AuthorEmailRole] = "authorEmail";
    roles[Roles::TimeRole] = "time";
    return roles;
}

bool CommitModel::isIndexValid(const QModelIndex &index) const
{
    return index.row() >= 0 && index.row() < rowCount();
}

Commit *CommitModel::getCommit(const QString &hash)
{
    for (Commit *commit : m_commits) {
        if (commit->hash() == hash)
            return commit;
    }

    return nullptr;
}
