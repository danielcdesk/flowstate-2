# Decisões
- App único em Flutter para Android e Windows (uma base de UI, sem duplicação).
- Drift/SQLite para dados; repositórios por interface no domain.
- Riverpod para estado (sem geração de código na v1 se possível); go_router (ou equivalente) só se preservar aba e rolagem. Verificar versões e APIs na documentação. Registrar aqui qualquer troca com o motivo.
- Clock injetado; LocalDate próprio; dia lógico configurável.
- XP por ledger idempotente; sequência e nível sempre derivados.
- Backup criptografado; sem rede em runtime.
- A Retrospectiva anual será uma experiência interativa dentro de Evolução, com linha do tempo e dados calculados localmente; não será um vídeo exportado.
- `flutter_localizations` e `intl` são dependências da Fase 0 porque o `gen-l10n` do Flutter 3.47.5 as exige mesmo com os catálogos ARB inicialmente vazios.
- Pacotes candidatos (verificar manutenção, licença e suporte a Windows e Android antes de aprovar): clock, uuid, intl, drift, sqlite3, flutter_riverpod, flutter_local_notifications + timezone, wakelock_plus, cryptography, file_picker, share_plus, window_manager, uma solução mantida de instância única no Windows.
