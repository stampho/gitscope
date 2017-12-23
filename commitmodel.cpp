#include "commit.h"
#include "commitdao.h"
#include "commitmodel.h"

CommitModel::CommitModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

void CommitModel::reset(CommitDao *commitDao)
{
    beginResetModel();

    m_commits.clear();
    for (const QString &hash : commitDao->getCommitHashList())
        m_commits.append(new Commit(commitDao, hash, this));

    endResetModel();
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

Commit *CommitModel::getCommit(const QString &hash) const
{
    for (Commit *commit : m_commits) {
        if (commit->hash() == hash)
            return commit;
    }

    return nullptr;
}

QVariantMap CommitModel::get(const int row) const
{
    if (row < 0 || row >= rowCount())
        return QVariantMap();

    QVariantMap result;
    QModelIndex modelIndex = index(row, 0);

    QHash<int, QByteArray> names = roleNames();
    for (int key : names.keys()) {
        QVariant d = data(modelIndex, key);
        result[names[key]] = d;
    }

    return result;
}
