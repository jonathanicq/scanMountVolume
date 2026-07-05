# CLAUDE.md — scanMountVolume

Ferramenta Python que faz scan e cataloga conteúdos de shares de rede montadas (NFS, SMB/CIFS) e guarda metadados (hash, MIME, duplicados, categorização) numa MySQL remota.

## Estado

**Planning/infra** — só existem docs + Docker scaffolding (Dockerfile, compose, entrypoint, deploy.sh). O código Python ainda não está no repo. Scope completo em `PROJECT_SCOPE.md`; plano em `MASTER_PLAN.md`.

## Estrutura prevista

- App corre em Docker; diretório de runtime `/opt/docker/scanMountVolume/scanMountVolume`.
- Config via `.env` (não versionado; ver `.env.example`).
- Branches: `dev` (trabalho) / `master`.

## Regras

- Sobreposição funcional com `nas-deduplicator` (scan + hash + duplicados em NAS) — antes de implementar, verificar o que se reutiliza de lá (ver review).
- Nunca apagar ficheiros nas shares — só catalogar.
- Aplicar não-negociáveis globais ao arrancar (exec logging, health se houver serviço).
