# Flow State — regras para agentes
Antes de qualquer tarefa, leia: AGENTS.md, docs/BRIEF.md, docs/DESIGN.md, docs/ROADMAP.md, docs/STATE.md.

## Projeto
App único em Flutter/Dart para Android e Windows (iOS fica para depois, sem bloquear). Identificadores de código em inglês. Textos ao usuário em pt-BR via ARB (gen-l10n), com estrutura pronta para en e es.

## Estrutura
lib/app (bootstrap, rotas, shell adaptativo)
lib/core (clock, ids, LocalDate, resultado/erros, constantes)
lib/domain (Dart PURO: modelos, regras, interfaces de repositório)
lib/data (Drift, repositórios, migrações, backup)
lib/features/<feature> (telas + controllers)
lib/design (tokens, tema, componentes)
lib/l10n (ARB)
test/ (espelha lib/), test/fixtures, test/architecture, tooling/

## Regras de dependência (testadas automaticamente)
- domain NÃO importa flutter, drift, data nem features.
- features acessam dados só por interfaces do domain.
- design não importa features.

## Comando único de verificação
tooling/check.ps1 = dart format --set-exit-if-changed, flutter analyze (estrito), flutter test --coverage, testes de arquitetura. Nunca declare uma tarefa concluída sem rodar e mostrar a saída.

## Código
- Análise estrita (strict-casts, strict-inference, strict-raw-types). Sem dynamic. Sem "!" sem justificativa em comentário.
- Regras de domínio são funções puras.
- Tempo SEMPRE via Clock injetado (pacote clock). Proibido DateTime.now() em domain e features.
- Data de calendário = LocalDate próprio (ano, mês, dia), sem fuso. Momentos = UTC em createdAt/updatedAt.
- IDs = UUID. Enums e categorias persistidos por id estável em inglês (ex.: mind, body, focus), NUNCA por rótulo de exibição.
- Proibido guardar estado derivado (sequência, nível, totais, progresso). Sempre calcular por seletores/funções puras.
- XP só entra pelo ledger idempotente. Nunca incrementar contador.

## Dados
- Toda mudança de schema = migração NOVA + banco de exemplo (fixture) da versão anterior + teste. Nunca editar migração existente.
- Escrita em várias linhas = transação.
- Todo registro: id, createdAt, updatedAt, deletedAt (exclusão lógica), deviceId.

## Design
- Só tokens e componentes de lib/design. Proibido Color(0x...), fontSize numérico e EdgeInsets numérico fora de lib/design (teste automático).
- Máximo 2 níveis de superfície. Seguir docs/DESIGN.md e a lista de padrões proibidos.

## Textos
- Sempre ARB. Plural e número via intl. Proibido "(s)". Botões começam com verbo.

## Segurança e privacidade
- Sem rede em runtime. O release NÃO pode ter a permissão INTERNET (verificar o manifesto final).
- Nenhum log com conteúdo do usuário.
- Arquivo importado é entrada hostil: validar tamanho, formato e schema.
- Backup criptografado. Segredos e keystore fora do Git.

## Testes
- domain com cobertura >= 90% e testes de borda em toda regra.
- UI: widget test + golden (compacto/expandido, claro/escuro, fonte 200%) + guidelines de acessibilidade (textContrastGuideline, androidTapTargetGuideline, labeledTapTargetGuideline).

## Git
Branch por fase, commits pequenos, tag fase-N ao final. Ao terminar qualquer tarefa, atualizar docs/STATE.md.
