#include "commit.h"
#include "commitdao.h"

Commit::Commit(const CommitDao *dao, QString oid)
    : m_dao(dao)
    , m_oid(oid)
{
}

QString Commit::oid() const
{
    return m_oid;
}

QString Commit::summary()
{
    if (m_summary.isEmpty())
        m_summary = QString(m_dao->getSummary(oid()));
    return m_summary;
}

QString Commit::author(AuthorInfo authorInfo)
{
    if (m_author.isEmpty())
        m_author.unite(m_dao->getAuthor(oid()));
    return m_author[authorInfo];
}

QString Commit::time()
{
    if (m_time.isEmpty())
        m_time = m_dao->getTime(oid()).toString();
    return m_time;
}
