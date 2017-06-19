#include <git2.h>

#include "commit.h"
#include "commitdao.h"

CommitDao::CommitDao(git_repository *repository)
    : m_repository(repository)
{
}

QList<Commit *> CommitDao::getCommits() const
{
    QList<Commit *> commits;
    git_revwalk *walker = nullptr;
    git_revwalk_new(&walker, m_repository);
    git_revwalk_push_head(walker);

    git_oid oid;
    while (!git_revwalk_next(&oid, walker)) {
        git_commit *commit = nullptr;
        git_commit_lookup(&commit, m_repository, &oid);

        char buffer[GIT_OID_HEXSZ+1];
        git_oid_tostr(buffer, sizeof(buffer)/sizeof(char), &oid);
        commits.append(new Commit(this, buffer));

        git_commit_free(commit);
    }

    git_revwalk_free(walker);
    return commits;
}

QString CommitDao::getSummary(const QString &oidString) const
{
    git_oid oid;
    git_oid_fromstr(&oid, oidString.toStdString().c_str());

    git_commit *commit = nullptr;
    git_commit_lookup(&commit, m_repository, &oid);

    return QString(git_commit_summary(commit));
}

QMap<int, QString> CommitDao::getAuthor(const QString &oidString) const
{
    QMap<int, QString> author;

    git_oid oid;
    git_oid_fromstr(&oid, oidString.toStdString().c_str());

    git_commit *commit = nullptr;
    git_commit_lookup(&commit, m_repository, &oid);

    const git_signature *signature = git_commit_author(commit);
    author.insert(Commit::Name, signature->name);
    author.insert(Commit::Email, signature->email);

    return author;
}

QDateTime CommitDao::getTime(const QString &oidString) const
{
    git_oid oid;
    git_oid_fromstr(&oid, oidString.toStdString().c_str());

    git_commit *commit = nullptr;
    git_commit_lookup(&commit, m_repository, &oid);

    const git_time_t time = git_commit_time(commit);
    return QDateTime::fromSecsSinceEpoch(time);
}
