#ifndef COMMITMODEL_H
#define COMMITMODEL_H

#include <QAbstractListModel>
#include <QHash>

#include "commit.h"
#include "gitmanager.h"

class CommitModel : public QAbstractListModel
{
    Q_OBJECT
public:

    enum Roles {
        HashRole = Qt::UserRole + 1, // Id
        SummaryRole,
        AuthorNameRole,
        AuthorEmailRole,
        TimeRole,
    };

    CommitModel(QObject *parent = 0);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    bool isIndexValid(const QModelIndex &index) const;

    GitManager &m_git;
    QList<Commit *> m_commits;
};

#endif // COMMITMODEL_H
