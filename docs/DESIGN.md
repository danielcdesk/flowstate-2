# Flow State — Design

## Princípios
1. Uma resposta principal por tela: um "herói" (número ou anel) grande, SEM caixa.
2. Seções separadas por divisores finos de largura total. Cartão só para algo interativo ou uma dica dispensável.
3. No máximo 2 níveis de superfície (fundo e superfície elevada tonal).
4. Cor com regra: a cor de destaque (marca) serve só para ação primária, item ativo, foco e progresso. Receita/sucesso, alerta e erro têm cores semânticas PRÓPRIAS, distintas do destaque em qualquer tema.
5. Nada só por cor: status = ícone + texto; variação = sinal + seta + cor.
6. Tipografia com voz: duas famílias empacotadas como assets (nunca baixar da internet; confirmar licença OFL e incluir os arquivos de licença). Uma para títulos e números grandes (ex.: Bricolage Grotesque ou Fraunces), outra para a interface (ex.: Figtree ou Inter). Números com figuras tabulares.
7. Textos curtos, específicos e sem culpa.
8. Feedback: vibração leve ao concluir e "Desfazer" por 5 segundos. Diálogo de confirmação só para ação irreversível (apagar tudo, restaurar backup).
9. Identidade própria: elemento-assinatura = o "anel de fluxo" (anel de progresso aberto com ponta arredondada), presente no herói do Hoje, na boas-vindas, nos estados vazios e no ícone do app. Na Fase 1 você propõe 2 opções em SVG para eu escolher.

## Tokens
Espaçamento: 4, 8, 12, 16, 24, 32, 48. Raios: 8 (chips/campos), 16 (cartões/sheets), pílula (botões/seletores). Texto: caption 12, body 15, subtitle 18, title 24, display 44+ (herói). Sombra: 2 níveis. Movimento: 150-250 ms, respeitando "reduzir movimento".
Temas: claro, escuro e sistema, com destaque Lima (padrão), Azul ou Coral = 6 combinações, TODAS cobertas por teste automático de contraste (texto 4,5:1; ícones e bordas de componente 3:1). No claro, texto/ícone sobre Lima usa a variante escura. Fundos com neutros de leve temperatura, não preto puro.

## Componentes (lib/design/components)
HeroStat, ProgressRing (anel de fluxo), DeltaText, SegmentedRange, QuickActionGrid (4 colunas, botões circulares >= 56 dp com rótulo), StatusPill, HairlineSection, ListRow (2 linhas: título+subtítulo à esquerda, valor/sequência à direita), EmptyState, LoadingSkeleton, ErrorState, AppButton (primário, secundário, fantasma), AppTextField, AppChip, AppBottomSheet, UndoSnackbar, AppBottomNav (<= 5 destinos, ícone + rótulo, pílula no item ativo), SidebarNav (desktop), ChartCanvas (sem grade, toque mostra o valor, tabela alternativa para leitor de tela).

## Layout adaptativo
Compacto (< 600): navegação inferior. Médio (600-839): rail. Expandido (>= 840): barra lateral, duas colunas (~2/3 e 1/3), largura máxima de conteúdo ~1100. Atalhos no desktop: Ctrl+K (paleta de comandos), Ctrl+N (novo), foco visível e navegação por teclado.

## Padrões PROIBIDOS
Quadradinho colorido com ícone em cartão de métrica; grade de cartões todos iguais e simétricos; título repetido em dois níveis; pílula puramente decorativa; gradiente ou brilho decorativo; emoji como ícone; plural com "(s)"; gráfico ou valor zerado como estado vazio; barra inferior sem rótulos; banner promocional/upsell; mascotes ou ilustrações de terceiros; cor ou tamanho fixo fora de lib/design.

## Voz
pt-BR, direta, calma, específica. Botões com verbo. Erros dizem o que houve, o que fazer e (quando verdade) que os dados continuam no aparelho. Tom de apoio nos dias ruins ("Hoje o mínimo já conta").

## Referências
Imagens em docs/refs/. Usar PRINCÍPIOS, nunca copiar identidade (logos, mascotes, ilustrações, textos, combinações exatas de cor, funções cripto ou de preço em tempo real, upsell). A síntese fica em docs/DESIGN_REFERENCES.md (gerada na Fase 1).
