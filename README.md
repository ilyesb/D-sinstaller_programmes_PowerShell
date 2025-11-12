# D-sinstaller_programmes_PowerShell

pipeline.yaml

Explications

pool: name: 'vs2019'

Le job s’exécute sur un agent libre du pool vs2019.

Azure DevOps choisira automatiquement un agent disponible.

Pas de matrix

Tous les agents du pool ne sont pas utilisés automatiquement.

Si tu veux exécuter sur plusieurs machines, tu dois dupliquer le job plusieurs fois avec des Agent.Name spécifiques, ou utiliser une matrix.

Logs

Les logs du script PowerShell apparaissent dans la console du job, visibles dans Azure DevOps Server 2022.

🔹 Limitation

Avec cette version sans matrix, le script ne sera exécuté que sur un agent à la fois.

Pour désinstaller sur toutes les machines du pool en parallèle, il faut soit :

Matrix (recommandé pour automatisation complète)

Dupliquer les jobs manuellement, chacun ciblant un agent spécifique (Agent.Name)


