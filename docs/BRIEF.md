# Flow State — Brief do produto

## Proposta
"Seu dia em um só lugar: hábitos, tarefas, rotina e treino. Privado, offline, sem conta — e gentil nos dias difíceis."
Público: adultos que tentam organizar rotina e saúde e abandonam apps por excesso de coisas e por culpa. Brasil primeiro (pt-BR), depois en e es.

## Diferenciais (contra TickTick, Todoist, Streaks, Habitify, Hevy)
1. Modo baixa energia: plano mínimo do dia.
2. Hábito com gatilho ("depois de X, faço Y") e versão mínima; sequência tolerante.
3. Time-blocking que integra tarefas, hábitos e rotina, com horários livres sugeridos.
4. Revisão semanal com insights calculados localmente.
5. Privacidade real: 100% local, sem conta, backup criptografado.
6. Gamificação leve, sem punição.

## Não-objetivos da v1
Sem conta/login, servidor, anúncios, rede social, IA generativa, sync em tempo real ou integrações externas. Hidratação e peso ficam fora da v1 (futuro módulo "Corpo").

## Módulos e navegação
Cinco destinos: Hoje, Plano (tarefas + rotina semanal), Hábitos, Treinos, Evolução. Foco NÃO é aba: abre pelo Hoje, por uma tarefa ou por atalho. Configurações no ícone do topo. Hoje e Evolução são sempre ativos; Plano, Hábitos, Treinos e Foco podem ser desligados nas Preferências (some da navegação, do Hoje e das notificações; NUNCA apaga dados; religar restaura). Onboarding pergunta o que a pessoa quer usar.

## Regras de domínio
Dia lógico: existe a preferência "início do dia" (padrão 04:00). Horário local antes disso pertence ao dia anterior. Função pura logicalDate(agoraLocal, inicioDoDia).

Recorrência (usada por hábitos, tarefas e blocos): diária; dias da semana (conjunto); a cada N dias (com âncora); meta semanal (X vezes por semana, só hábitos); mensal no dia D (dia 29-31 vira o último dia do mês curto). Testes para fevereiro, virada de ano e semana ISO.

Hábito: id, nome, ícone, categoria (mind, body, focus ou personalizada), agenda de recorrência, cue (gatilho, opcional), minimumVersion (opcional), essencial (bool), lembrete (opcional). HabitLog por dia lógico com level: full, minimum ou skipped.
Sequência (derivada, nunca armazenada): conta dias agendados com full ou minimum. skipped não soma e não quebra, até 2 por semana ISO (o terceiro quebra). Dia agendado passado sem log quebra. Hábito de meta semanal: sequência em semanas cumpridas (semana corrente não quebra até acabar).

Tarefa: título, notas, data e hora opcionais, duração estimada, prioridade (low, normal, high), projeto opcional, recorrência, conclusão por ocorrência.

Bloco de rotina: título, início, duração, categoria, recorrência por dias da semana. Pode cruzar a meia-noite.

Funções puras obrigatórias:
- detectConflicts(blocos, tarefas, data)
- findFreeSlots(blocos, tarefas, data, duracaoMin, janelaInicio, janelaFim)
- planForEnergy(estado, energia 1-5, data): energia <= 2 = baixa; devolve no máximo 3 itens (hábitos essenciais pendentes por maior sequência, 1 tarefa por prioridade/vencimento, treino leve se agendado). Completar o plano mínimo mantém a sequência.
- nextAction(estado, agora): 1) bloco/tarefa com horário em andamento ou mais próximo; 2) tarefa que vence hoje; 3) hábito essencial pendente; 4) nada.

Foco: sessão com duração escolhida (presets 25/50 e personalizada), vinculável a tarefa, com endAt ABSOLUTO persistido (sobrevive a segundo plano e reinício). Nunca contar ticks.

XP (constantes em UM arquivo): hábito full 10, minimum 5; tarefa 5 (só as 10 primeiras do dia rendem XP); bloco de rotina 8; sessão de foco >= 15 min completa 25 (máx. 6 por dia); treino concluído 35; check-in de energia 3 (1 por dia).
Nível: XP acumulado para o nível n = 50*n*(n-1). Nível = floor((1 + sqrt(1 + 0.08*xp)) / 2), com aritmética segura e testes nas fronteiras (100 XP = nível 2, 300 = 3, 600 = 4).
Ledger: XpEvent(id, action, sourceId, logicalDate, units, xp, createdAt, reversedAt?) com UNIQUE(action, sourceId, logicalDate). Desfazer = marcar reversedAt. XP e nível são sempre recalculados do ledger.
Conquistas: definidas como dados (id, condição pura sobre logs e ledger, tier bronze/prata/ouro), avaliação pura e idempotente. Na Fase 2 você propõe 30 em docs/ACHIEVEMENTS.md para minha aprovação.
Radar: um eixo por módulo ativo (score 0-100 contra metas pessoais).
Revisão semanal: insights locais e determinísticos, só com >= 14 dias de dados; candidatos: dia da semana mais forte, hábito que mais falha e horário em que costuma ser feito, melhor horário de foco, equilíbrio treino/recuperação. Tom sem culpa. Abaixo do mínimo: estado vazio explicando quando aparecerá.
Treinos (Fase 5): modelos de treino, sessões, séries (repetições, carga, descanso), "última vez" por exercício, recordes (maior carga; repetições na mesma carga; 1RM estimado por Epley, documentado), sugestão de próxima carga apenas como sugestão editável, timer de descanso com endAt absoluto. Biblioteca de exercícios escrita por nós (nome, músculo, equipamento), SEM mídia de terceiros; qualquer base externa exige verificação de licença.

Preferências: tema (sistema/claro/escuro), cor de destaque (Lima, Azul, Coral), início do dia, módulos, lembretes, idioma.

## Dados
Drift/SQLite. Migrações versionadas (user_version) com fixtures desde a v1. Exclusão lógica. Integridade: PRAGMA quick_check ao abrir; se falhar, tela de recuperação; nunca apagar automaticamente.
Backup: arquivo .flowbackup = snapshot consistente (VACUUM INTO) + metadados (versão do app e do schema, data, hash) criptografado com AES-256-GCM e chave derivada de senha (Argon2id se houver pacote mantido; senão PBKDF2 com custo alto; justifique em DECISIONS.md). Restauração: validar -> pré-visualizar (contagens e período) -> snapshot automático do estado atual -> aplicar em transação -> reverter se falhar. Backup automático local rotativo (últimos 5). Exportação CSV de hábitos e tarefas com proteção contra injeção de fórmula (valores iniciados por = + - @ recebem prefixo).

## Plataformas
Android (targetSdk >= 36 verificado no manifesto final; publicação em AAB), Windows 10/11 (instalador, instância única, banco em %LOCALAPPDATA%).
APPLICATION_ID provisório: com.danielcdesk.flowstate — CONFIRMAR antes da Fase 6 (é permanente após publicar). O nome do app fica em UMA constante, porque "Flow State" pode colidir com outros apps.
