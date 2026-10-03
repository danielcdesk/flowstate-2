# Estado do projeto
Fase atual: 2 (concluída; aguardando aprovação para a Fase 3)
Fase 2: domínio puro para datas, recorrência, hábitos, tarefas, time-blocking, foco por prazo UTC, planos por energia, ação seguinte, XP/nível, conquistas, radar e insights semanais; 66 testes de core/domínio passaram localmente com 92,9% de cobertura do domínio. CI do GitHub passou em Windows e Ubuntu. O script local para na resolução de dependências porque o Dart instalado é 3.13.3 e o projeto requer 3.13.4.
Feito: projeto Flutter Android/Windows; documentos-base; análise estrita; l10n ARB pt-BR/en/es; shell adaptativo inicial; telas Hoje e Boas-vindas; componentes de fluxo, hero, ações, lista e radar; testes de widgets; tooling/check.ps1; CI; biblioteca de referências em docs/refs; página própria do projeto em docs/index.html preparada para GitHub Pages; workflow de publicação; Retrospectiva anual interativa registrada para a Fase 4e.
Pendente: revisar opção do anel e fontes OFL; o SDK local (Dart 3.13.3) não atende ao mínimo ^3.13.4, então a verificação Flutter foi concluída pela CI do GitHub.
Árvore de pastas: AGENTS.md; docs/; lib/app; lib/core; lib/data; lib/design; lib/domain; lib/features; lib/l10n; test/architecture; tooling; android; windows; .github/workflows
Comandos: tooling/check.ps1
Decisões abertas: APPLICATION_ID, nome do app, fontes, opção do anel-assinatura
CI/publicação: quality.yml e pages.yml configurados no repositório GitHub; os cinco goldens responsivos foram gerados no CI e a página está publicada no GitHub Pages.
Última atualização: 2026-09-30
