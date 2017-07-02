#include <git2.h>

#include "commit.h"
#include "commitdao.h"

CommitDao::CommitDao()
{
}

void CommitDao::setRepository(git_repository *repository)
{
    m_repository = repository;
}

QStringList CommitDao::getCommitHashList() const
{
    if (!m_repository)
        return QStringList();

    QStringList commitHashList;
    git_revwalk *walker = nullptr;
    git_revwalk_new(&walker, m_repository);
    git_revwalk_push_head(walker);

    git_oid oid;
    while (!git_revwalk_next(&oid, walker)) {
        git_commit *commit = nullptr;
        git_commit_lookup(&commit, m_repository, &oid);

        char buffer[GIT_OID_HEXSZ+1];
        git_oid_tostr(buffer, sizeof(buffer)/sizeof(char), &oid);
        commitHashList.append(buffer);

        git_commit_free(commit);
    }

    git_revwalk_free(walker);
    return commitHashList;
}

QString CommitDao::getSummary(const QString &hash) const
{
    Q_ASSERT(m_repository);

    git_oid oid;
    git_oid_fromstr(&oid, hash.toStdString().c_str());

    git_commit *commit = nullptr;
    git_commit_lookup(&commit, m_repository, &oid);

    return QString(git_commit_summary(commit));
}

QString CommitDao::getMessage(const QString &hash) const
{
    Q_ASSERT(m_repository);

    git_oid oid;
    git_oid_fromstr(&oid, hash.toStdString().c_str());

    git_commit *commit = nullptr;
    git_commit_lookup(&commit, m_repository, &oid);

    return QString(git_commit_message(commit));
}

QMap<int, QString> CommitDao::getAuthor(const QString &hash) const
{
    Q_ASSERT(m_repository);

    QMap<int, QString> author;

    git_oid oid;
    git_oid_fromstr(&oid, hash.toStdString().c_str());

    git_commit *commit = nullptr;
    git_commit_lookup(&commit, m_repository, &oid);

    const git_signature *signature = git_commit_author(commit);
    author.insert(Commit::Name, signature->name);
    author.insert(Commit::Email, signature->email);

    return author;
}

QDateTime CommitDao::getTime(const QString &hash) const
{
    Q_ASSERT(m_repository);

    git_oid oid;
    git_oid_fromstr(&oid, hash.toStdString().c_str());

    git_commit *commit = nullptr;
    git_commit_lookup(&commit, m_repository, &oid);

    const git_time_t time = git_commit_time(commit);
    return QDateTime::fromSecsSinceEpoch(time);
}

QString CommitDao::getDiff(const QString &hash) const
{
    Q_ASSERT(m_repository);

    git_oid oid;
    git_oid_fromstr(&oid, hash.toStdString().c_str());

    git_commit *commit = nullptr;
    git_commit_lookup(&commit, m_repository, &oid);

    git_commit *parent = nullptr;
    git_commit_parent(&parent, commit, 0);

    git_tree *commit_tree = nullptr;
    git_commit_tree(&commit_tree, commit);

    git_tree *parent_tree = nullptr;
    // The first commit does not have parent. In this case, create diff to an empty tree
    if (parent)
        git_commit_tree(&parent_tree, parent);

    git_diff *diff = nullptr;
    git_diff_tree_to_tree(&diff, m_repository, parent_tree, commit_tree, nullptr);

    git_buf buf = GIT_BUF_INIT_CONST(nullptr, 0);
    git_diff_to_buf(&buf, diff, GIT_DIFF_FORMAT_PATCH);

    QString diffString = QString(buf.ptr);

    git_diff_free(diff);
    git_buf_free(&buf);

    return diffString;
}
