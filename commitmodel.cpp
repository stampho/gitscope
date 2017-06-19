#include "commit.h"
#include "commitdao.h"
#include "commitmodel.h"

CommitModel::CommitModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_git(GitManager::instance())
    , m_commits(m_git.commitDao()->getCommits())
{
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
    case Roles::IdRole:
        return commit->oid();
    case Roles::SummaryRole:
    case Qt::DisplayRole:
        return commit->summary();
    case Roles::AuthorNameRole:
        return commit->author(Commit::Name);
    case Roles::AuthorEmailRole:
        return commit->author(Commit::Email);
    case Roles::TimeRole:
        return commit->time();

    default:
        return QVariant();
    }
}

QHash<int, QByteArray> CommitModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Roles::IdRole] = "oid";
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
