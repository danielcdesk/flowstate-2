# Roadmap (uma fase por vez; parar e esperar aprovação ao final de cada uma)

FASE 0 — Fundação. Projeto Flutter (android, windows), pastas, análise estrita, tooling/check.ps1, testes de arquitetura, CI, documentos. Nenhuma tela. Aceite: check verde e app abre uma tela vazia.

FASE 1 — Visual primeiro (dados falsos em memória, sem banco). Ler docs/refs, gerar docs/DESIGN_REFERENCES.md; propor 2 opções do anel-assinatura; tokens, tema (6 combinações), fontes, componentes, página de catálogo (só debug); shell adaptativo com 5 destinos; tela Hoje (celular e desktop) e Boas-vindas. Aceite: goldens compacto/expandido, claro/escuro, fonte 200%; testes de contraste e acessibilidade; EU aprovo o visual.
 Hoje (celular, ordem fixa): saudação curta + nível/XP em uma linha; HeroStat "3 de 7 feitos hoje" com anel; UM card "Próxima ação" com botão de concluir; QuickActionGrid (Novo hábito, Nova tarefa, Iniciar foco, Iniciar treino); "Hábitos de hoje" em ListRow (nome + gatilho à esquerda, sequência à direita; marcar em um toque; Desfazer); "Linha do tempo". Desktop: duas colunas. Estados vazios úteis, sem "0" repetido.
 Boas-vindas: anel central, título "Seu dia em um só lugar.", UM botão primário, link "Já tenho um backup" (só ativo quando a restauração existir), linha "Seus dados ficam neste aparelho.", sem pedir foto nem dados obrigatórios.

FASE 2 — Domínio (Dart puro, sem UI, sem banco). Tudo do BRIEF em lib/domain e lib/core com testes de borda: LocalDate, logicalDate, recorrência, hábitos e sequência, tarefas, blocos, detectConflicts, findFreeSlots, planForEnergy, nextAction, XP/ledger/nível, conquistas (docs/ACHIEVEMENTS.md com 30 propostas), insights semanais. Aceite: cobertura >= 90% no domain; testes de invariantes (XP idempotente; desfazer devolve o XP; sequência independe de fuso).

FASE 3 — Dados. Drift schema v1, repositórios (interfaces no domain), infraestrutura de migração com fixture v1, quick_check ao abrir, backup e restauração criptografados, backup automático rotativo, CSV. Aceite: teste de migração; restauração de um backup de cada versão; falha no meio da restauração = nada muda; teste de banco corrompido. Implementação concluída; check local com 93,6% de cobertura domain; CI Windows/Ubuntu aprovado no run 37133805297; tag `fase-3` publicada.

FASE 4 — Features conectadas, uma por vez com aprovação: 4a Hoje real (concluída; CI Windows/Ubuntu aprovado no run 37136232364); 4b Hábitos (aguarda aprovação); 4c Plano e Rotina (com time-blocking); 4d Foco; 4e Evolução e revisão semanal. Aceite por feature: testes de widget, goldens, acessibilidade, estados vazio/carregando/erro.
 Na Fase 1, o catálogo visual inclui o componente de radar de habilidades com dados falsos, sem regra de negócio. Na Fase 4e, a Evolução conecta o radar a pontuações derivadas e inclui a Retrospectiva anual: uma tela interativa com linha do tempo e marcos calculados localmente. Ela não gera nem exporta vídeo; vídeos na biblioteca de referências são somente material de direção visual e interação.

FASE 5 — Notificações locais (permissão em contexto, canais no Android, gatilhos por horário local, reagendar ao editar e reiniciar, sem alarme exato) e Treinos.

FASE 6 — Onboarding com modelos ("Manhã produtiva", "Calistenia iniciante 3x/semana"), módulos ativáveis, acessibilidade e desempenho (benchmark com dados volumosos), Android (AAB, assinatura fora do Git, targetSdk >= 36, sem permissão INTERNET, ofuscação com símbolos guardados), Windows (instalador, assinatura ou Microsoft Store, instância única), política de privacidade e formulários da Play, verificação do nome do app e do APPLICATION_ID. Decidir e registrar: criptografia do banco em repouso.

FASE 7 — Pós-lançamento (NÃO fazer agora): widgets Android, sync por arquivo criptografado, versão paga, iOS.
