#!/usr/bin/env bash
set -euo pipefail

echo "== Verification du projet =="

# 1. Fichiers indispensables
for f in Dockerfile requirements-dev.txt .github/workflows/ci.yml; do
  if [ ! -f "$f" ]; then
    echo "ERREUR: fichier manquant: $f" >&2
    exit 1
  fi
  echo "OK  $f"
done

# 2. Aucun fichier .env suivi par Git
if git ls-files | grep -E '(^|/)\.env' >/dev/null; then
  echo "ERREUR: un fichier .env est suivi par Git" >&2
  exit 1
fi
echo "OK  aucun .env suivi par Git"

# 3. Arbre de travail propre
if [ -n "$(git status --porcelain)" ]; then
  echo "ERREUR: modifications non validees" >&2
  git status --short >&2
  exit 1
fi
echo "OK  arbre de travail propre"

# 4. Tests
if [ -x .venv/bin/pytest ]; then
  .venv/bin/pytest -q
else
  pytest -q
fi

echo "== Projet pret pour une release =="
