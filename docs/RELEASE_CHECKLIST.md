# Checklist de release

## Já verificado

- `applicationId` provisório registrado como `com.danielcdesk.flowstate`.
- `targetSdk` Android definido explicitamente como 36.
- Manifesto sem permissão `android.permission.INTERNET`.
- Dados locais, sem conta, servidor ou sincronização em runtime.
- Backup `.flowbackup` cifrado e segredos fora do Git.
- Lembretes Android usam `AlarmManager` e `NotificationChannel`; a permissão é pedida em contexto.
- Windows mantém o mesmo núcleo local; o adaptador de notificação nativo fica separado da regra de domínio.

## Antes de publicar

- Escolher nome final e confirmar `APPLICATION_ID` permanente.
- Trocar a assinatura debug por keystore fora do Git ou usar Microsoft Store.
- Gerar AAB release com símbolos de ofuscação guardados fora do repositório.
- Validar restauração de backup em uma instalação limpa.
- Conferir política de privacidade e formulários da Play.
- Testar lembretes com fuso, reinício e edição de horário em aparelho Android real.
- Gerar instalador Windows e testar instância única.

## Validação automatizada

- `tooling/release_check.ps1` verifica o manifesto sem `INTERNET` e o `targetSdk`.
- `release-builds.yml` gera AAB Android e build Windows como artefatos de validação. Esses artefatos ainda não são publicação final: a assinatura de produção deve ser configurada fora do Git.
