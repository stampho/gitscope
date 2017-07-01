#ifndef COMMITMODEL_H
#define COMMITMODEL_H

#include <QAbstractListModel>
#include <QHash>

class Commit;
class CommitDao;

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
    void reset(CommitDao *CommitDao);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE Commit *getCommit(const QString &hash);

private:
    bool isIndexValid(const QModelIndex &index) const;

    QList<Commit *> m_commits;
};

#endif // COMMITMODEL_H
