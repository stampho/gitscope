#include "commit.h"
#include "commitdao.h"

Commit::Commit(const CommitDao *dao, QString hash, QObject *parent)
    : QObject(parent)
    , m_dao(dao)
    , m_hash(hash)
{
}

QString Commit::hash() const
{
    return m_hash;
}

QString Commit::summary()
{
    if (m_summary.isEmpty())
        m_summary = QString(m_dao->getSummary(hash()));
    return m_summary;
}

QString Commit::authorName()
{
    if (m_author.isEmpty())
        m_author.unite(m_dao->getAuthor(hash()));
    return m_author[AuthorInfo::Name];
}

QString Commit::authorEmail()
{
    if (m_author.isEmpty())
        m_author.unite(m_dao->getAuthor(hash()));
    return m_author[AuthorInfo::Email];
}

QString Commit::time()
{
    if (m_time.isEmpty())
        m_time = m_dao->getTime(hash()).toString();
    return m_time;
}
