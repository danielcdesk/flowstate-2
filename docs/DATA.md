# Dados locais e portabilidade

## Banco

O Drift mantém o schema v1 em `lib/data/database/app_database.dart`; o código gerado fica ao lado. `PRAGMA quick_check` roda antes de cada conexão ficar disponível. Uma falha é propagada como erro de integridade: o banco nunca é apagado nem recriado automaticamente. A fixture canônica do schema v1 está em `test/fixtures/schema_v1.sql`.

As tabelas persistem IDs estáveis, datas de calendário `YYYY-MM-DD`, momentos UTC e campos de auditoria (`id`, `created_at`, `updated_at`, `deleted_at`, `device_id`). O domínio não conhece Drift: os contratos ficam em `lib/domain/repositories/` e as implementações em `lib/data/repositories/`.

O arquivo do banco fica no diretório privado do aplicativo: no Windows, `%LOCALAPPDATA%\<empresa>\<produto>`; no Android, no diretório de suporte privado do pacote. Nenhuma sincronização ou chamada de rede é feita.

## Backup e restauração

O `.flowbackup` é um envelope versionado. Ele guarda um snapshot consistente SQLite (`VACUUM INTO`), criptografado com AES-256-GCM. Uma chave de 256 bits é derivada da senha via Argon2id; parâmetros, salt e nonce são validados antes do trabalho caro, o conteúdo autenticado carrega versão do app/schema, instante UTC e SHA-256 do snapshot. O arquivo é limitado a 256 MiB de banco (512 MiB de envelope) e precisa passar em `quick_check`, `user_version` e validação das tabelas requeridas antes de ser considerado restaurável.

Backups portáteis são protegidos por senha escolhida pelo usuário. Backups automáticos locais usam uma chave aleatória por instalação, guardada pelo armazenamento seguro do sistema operacional; somente os cinco mais recentes são mantidos. Por isso, backups automáticos são recuperação local e não substituem um `.flowbackup` portátil com senha.

A restauração valida e apresenta contagens/período antes de alterar dados, cria primeiro um backup criptografado do estado atual e substitui todas as tabelas numa transação. Uma exceção no meio da aplicação desfaz a transação inteira. Arquivos inválidos ou senhas erradas não alteram o banco.

## CSV

As exportações de hábitos e tarefas usam UTF-8 com BOM e CRLF. Campos seguem o escape CSV; valores cujo primeiro caractere significativo seja `=`, `+`, `-` ou `@` recebem apóstrofo para reduzir risco de execução como fórmula em planilhas.
