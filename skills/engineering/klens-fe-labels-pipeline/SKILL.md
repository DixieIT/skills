---
name: klens-fe-labels-pipeline
description: Gestisce la pipeline FE + labels repo: raccoglie nuove chiavi i18n, controlla branch su klens-frontend e labels, aggiunge traduzioni en-US/it-IT, esegue check/sync e prepara il commit.
---

# KLens FE Labels Pipeline

Usa questa skill quando devi propagare nuove label dal frontend al repository `projects/labels` in modo sicuro e ripetibile.

## Obiettivo

Automatizzare il flusso completo:

1. Segnare le label mancanti da FE.
2. Verificare branch corrente in `klens-frontend`.
3. Aprire `projects/labels` e verificare branch corrente.
4. Aggiungere le key in `labels/web/en-US/labels.json` e `labels/web/it-IT/labels.json`.
5. Eseguire validazione/sync (`check_labels.sh` + `sync_labels_safe.py`).
6. Verificare diff e stato git finale.

## Input richiesto

- Lista label da aggiungere, formato:

```text
chat.sidebar.enable-studio
EN: Generate your first chat response to enable Klens Studio.
IT: Genera la prima risposta di chat per abilitare Klens Studio.
```

Se manca una traduzione, metti placeholder `[TODO TRANSLATE]` e segnala esplicitamente il follow-up.

## Procedura operativa

### 1) Verifica contesto FE

Esegui in `/home/gmasiero/projects/klens-frontend`:

```bash
git rev-parse --abbrev-ref HEAD
git status --short
git pull --ff-only
```

Annota branch FE nel report finale.

### 2) Verifica contesto Labels

Esegui in `/home/gmasiero/projects/labels`:

```bash
git rev-parse --abbrev-ref HEAD
git status --short
git pull --ff-only
```

Annota branch labels nel report finale.

Regola branch:

- Evita modifiche dirette su branch `dev` o `test`.
- Se branch corrente e `dev/test`, fermati e chiedi branch target, a meno che l'utente richieda esplicitamente di lavorare su `dev/test`.

### 3) Inserimento label

Aggiorna SEMPRE entrambi i file:

- `labels/web/en-US/labels.json`
- `labels/web/it-IT/labels.json`

Regole:

- Mantieni ordine e stile JSON esistente.
- Inserisci la key vicino al gruppo semantico (es. `chat.sidebar.*`).
- Non toccare chiavi non correlate.

### 4) Installa/aggiorna pre-commit hook (una volta per clone)

In `projects/labels`:

```bash
chmod a+x pre-commit-hook.sh
cp pre-commit-hook.sh ./.git/hooks/pre-commit
```

Se già presente, sovrascrivere e continuare.

### 5) Validazione obbligatoria

In `projects/labels`:

```bash
./check_labels.sh
python ./sync_labels_safe.py
```

Se fallisce:

- correggi mismatch key;
- riesegui i comandi finche passa.

### 6) Verifica finale

In `projects/labels`:

```bash
git status --short
git diff -- labels/web/en-US/labels.json labels/web/it-IT/labels.json
```

## Output finale richiesto all'utente

Rispondi con:

1. Branch FE rilevato.
2. Branch labels rilevato.
3. Elenco key aggiunte.
4. Esito check/sync.
5. File modificati pronti al commit.

Formato sintetico consigliato:

```text
FE branch: <branch-name>
Labels branch: <branch-name>
Added keys:
- chat.sidebar.enable-studio
Checks:
- ./check_labels.sh: OK
- python ./sync_labels_safe.py: OK
Changed files:
- labels/web/en-US/labels.json
- labels/web/it-IT/labels.json
```

## Guardrail

- Non fare commit se l'utente non lo richiede esplicitamente.
- Non modificare `labels/micro/*` salvo richiesta esplicita.
- Non alterare traduzioni esistenti non coinvolte.
- Evita refactor massivi del JSON.
- Prima di ogni modifica labels, esegui sempre `git pull --ff-only` nella repo corrente.
- Non lavorare su `dev/test` per default; farlo solo con richiesta esplicita utente.
