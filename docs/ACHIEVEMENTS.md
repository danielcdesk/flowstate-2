# Proposta de conquistas — Fase 2

Status: proposta para aprovação do usuário; os nomes e limiares ainda não são definitivos.

As conquistas são avaliadas como funções puras sobre registros e eventos do ledger até uma data lógica. O resultado não é persistido como contador ou estado derivado; a avaliação pode ser repetida sem duplicar progresso. Eventos de XP desfeitos e registros excluídos não contam. As propostas não punem dias sem atividade.

| ID estável | Nome de exibição sugerido | Métrica | Bronze | Prata | Ouro |
| --- | --- | --- | ---: | ---: | ---: |
| `first_steps` | Primeiros passos | Hábitos concluídos (full ou minimum) | 1 | 10 | 50 |
| `steady_rhythm` | Ritmo constante | Melhor sequência diária de um hábito | 3 dias | 7 dias | 30 dias |
| `minimum_counts` | O mínimo conta | Registros na versão mínima | 1 | 10 | 50 |
| `task_momentum` | Tarefas em movimento | Tarefas concluídas | 1 | 20 | 100 |
| `routine_flow` | Fluxo da rotina | Blocos de rotina concluídos com XP ativo | 1 | 20 | 100 |
| `focus_time` | Tempo de foco | Sessões de foco concluídas com XP ativo | 1 | 10 | 50 |
| `body_in_motion` | Corpo em movimento | Treinos concluídos com XP ativo | 1 | 8 | 30 |
| `self_check` | De olho em si | Check-ins de energia com XP ativo | 1 | 7 | 30 |
| `xp_journey` | Jornada em evolução | XP ativo acumulado | 50 | 300 | 1.000 |
| `many_paths` | Vários caminhos | Categorias distintas de hábitos concluídos | 2 | 3 | 4 |

Cada uma das dez linhas gera três definições com IDs formados pelo identificador da família e pelo tier (`_bronze`, `_silver`, `_gold`), totalizando 30. Os IDs técnicos são estáveis em inglês; os nomes acima são rótulos provisórios em pt-BR e devem ser movidos para ARB quando a experiência de conquistas for conectada na Fase 4.

Notas para aprovação:

- “Melhor sequência diária” não inclui a sequência atual apenas por estar em andamento; o cálculo observa sequências já registradas até a data avaliada.
- Categorias personalizadas diferentes contam como categorias diferentes. A proposta aceita quatro categorias para Ouro, embora o app comece com três categorias padrão.
- Tarefas concluídas contam ocorrências registradas, não apenas tarefas únicas.
- Rotina, foco, treinos e check-ins usam o ledger ativo como fonte de verdade, respeitando idempotência e reversões.
