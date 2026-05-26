# DiscoverUzb — Repository convenience commands.
#
# Foydalanish:
#   make help          — barcha buyruqlar
#   make backend       — backend ishga tushirish
#   make admin         — admin panel dev server
#   make mobile        — Flutter app iOS simulator
#   make seed          — DB ga sample data
#   make test          — backend testlari
#   make analyze       — flutter analyze + pnpm typecheck
#   make stop          — barcha background process'larni to'xtatish
#
# Talab qilinadi:
#   - PostgreSQL 15+ (`brew services start postgresql@15`)
#   - Python 3.12+ + uv (`brew install uv`)
#   - Node 22+ + pnpm (`brew install pnpm`)
#   - Flutter 3.27+

SHELL := /bin/bash
.DEFAULT_GOAL := help

VENV := backend/.venv
PYTHON := $(VENV)/bin/python
UVICORN := $(VENV)/bin/uvicorn
ALEMBIC := $(VENV)/bin/alembic
PYTEST := $(VENV)/bin/pytest

# ──────────────────────────────────────────────────────────────────────
# Help
# ──────────────────────────────────────────────────────────────────────

.PHONY: help
help: ## Bu yordamni ko'rsatish
	@echo "DiscoverUzb — buyruqlar:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# ──────────────────────────────────────────────────────────────────────
# Backend
# ──────────────────────────────────────────────────────────────────────

.PHONY: backend
backend: ## Backend uvicorn (port 8000)
	cd backend && source .venv/bin/activate && uvicorn app.main:app --reload --port 8000

.PHONY: backend-install
backend-install: ## Backend paketlarni o'rnatish (uv venv yaratadi)
	cd backend && uv venv .venv --python 3.12 && \
		source .venv/bin/activate && \
		uv pip install -e . && \
		uv pip install pytest pytest-asyncio pytest-cov httpx "bcrypt<4.1" psycopg2-binary requests

.PHONY: migrate
migrate: ## Alembic upgrade head
	cd backend && source .venv/bin/activate && alembic upgrade head

.PHONY: migration
migration: ## Yangi alembic migration (talab: NAME=qisqa_nom)
	cd backend && source .venv/bin/activate && \
		alembic revision --autogenerate -m "$(NAME)"

.PHONY: seed
seed: ## DB ga sample data (admin + 3 user + 5 post + 8 category)
	cd backend && source .venv/bin/activate && python -m scripts.seed

.PHONY: test
test: ## Backend pytest (77 ta integratsiya testi)
	cd backend && source .venv/bin/activate && pytest tests/

.PHONY: test-cov
test-cov: ## Pytest + coverage hisobot
	cd backend && source .venv/bin/activate && \
		pytest tests/ --cov=app --cov-report=term-missing

.PHONY: db-create
db-create: ## Lokal Postgres'da `discoveruzb` DB yaratish
	psql -h localhost -d postgres -c "CREATE USER discoveruzb WITH PASSWORD 'discoveruzb' SUPERUSER;" 2>/dev/null || true
	psql -h localhost -d postgres -c "CREATE DATABASE discoveruzb OWNER discoveruzb;" 2>/dev/null || true
	psql -h localhost -d postgres -c "CREATE DATABASE discoveruzb_test OWNER discoveruzb;" 2>/dev/null || true
	@echo "✓ DB'lar tayyor: discoveruzb, discoveruzb_test"

.PHONY: db-reset
db-reset: ## DROP + recreate `discoveruzb` (DIQQAT — barcha data o'chadi)
	@read -p "discoveruzb DB o'chiriladi. Davom etamizmi? [y/N] " ans && [ "$$ans" = "y" ]
	psql -h localhost -d postgres -c "DROP DATABASE IF EXISTS discoveruzb;"
	psql -h localhost -d postgres -c "CREATE DATABASE discoveruzb OWNER discoveruzb;"
	$(MAKE) migrate seed

# ──────────────────────────────────────────────────────────────────────
# Admin panel
# ──────────────────────────────────────────────────────────────────────

.PHONY: admin
admin: ## Admin panel dev server (port 3000)
	cd admin && pnpm dev

.PHONY: admin-install
admin-install: ## Admin paketlarni o'rnatish
	cd admin && pnpm install

.PHONY: admin-build
admin-build: ## Admin production build
	cd admin && pnpm build

.PHONY: admin-typecheck
admin-typecheck: ## Admin TypeScript tekshiruv
	cd admin && pnpm typecheck

# ──────────────────────────────────────────────────────────────────────
# Mobile
# ──────────────────────────────────────────────────────────────────────

.PHONY: mobile
mobile: ## Flutter ishga tushirish (default device)
	flutter run --dart-define-from-file=.env

.PHONY: mobile-ios
mobile-ios: ## iOS simulator
	flutter run --dart-define-from-file=.env -d iPhone

.PHONY: mobile-android
mobile-android: ## Android emulator
	flutter run --dart-define-from-file=.env -d android

.PHONY: mobile-build-ios
mobile-build-ios: ## iOS simulator build
	flutter build ios --debug --no-codesign --simulator --dart-define-from-file=.env

.PHONY: mobile-build-android
mobile-build-android: ## Android APK debug
	flutter build apk --debug --dart-define-from-file=.env

.PHONY: mobile-codegen
mobile-codegen: ## Freezed / json_serializable regen
	dart run build_runner build --delete-conflicting-outputs

.PHONY: mobile-l10n
mobile-l10n: ## Localization classlarni regen
	flutter gen-l10n

# ──────────────────────────────────────────────────────────────────────
# Quality
# ──────────────────────────────────────────────────────────────────────

.PHONY: analyze
analyze: ## flutter analyze + pnpm typecheck (lint + type)
	@echo "▶ Mobile:"
	flutter analyze
	@echo ""
	@echo "▶ Admin:"
	cd admin && pnpm typecheck

.PHONY: lint
lint: ## Backend ruff lint
	cd backend && source .venv/bin/activate && ruff check app/ tests/

.PHONY: fmt
fmt: ## Backend ruff format + dart format
	cd backend && source .venv/bin/activate && ruff format app/ tests/ scripts/
	dart format lib/

# ──────────────────────────────────────────────────────────────────────
# Status
# ──────────────────────────────────────────────────────────────────────

# ──────────────────────────────────────────────────────────────────────
# MinIO (lokal object storage — rasm yuklash uchun)
# ──────────────────────────────────────────────────────────────────────

MINIO_DATA := .local/minio-data

.PHONY: minio
minio: ## MinIO object storage (port 9000 API + 9001 console)
	@mkdir -p $(MINIO_DATA)
	@echo "→ MinIO ishga tushmoqda (API: http://localhost:9000, Console: http://localhost:9001)"
	@echo "  Credentials: minioadmin / minioadmin"
	@MINIO_ROOT_USER=minioadmin MINIO_ROOT_PASSWORD=minioadmin \
		minio server $(MINIO_DATA) --address ":9000" --console-address ":9001"

.PHONY: status
status: ## Backend + DB + MinIO holatini tekshirish
	@echo "─── PostgreSQL ───"
	@pg_isready -h localhost 2>&1 | head -1 || echo "❌ Postgres yo'q"
	@echo ""
	@echo "─── Backend ───"
	@curl -sf http://localhost:8000/health 2>/dev/null && echo "" || echo "❌ Backend ishlamayapti"
	@echo ""
	@echo "─── MinIO ───"
	@curl -sf http://localhost:9000/minio/health/live >/dev/null && echo "✓ MinIO ishlamoqda" || echo "❌ MinIO yo'q (make minio)"
	@echo ""
	@echo "─── DB jadvallar ───"
	@psql -h localhost -U discoveruzb -d discoveruzb -c "\dt" 2>&1 | head -20 || echo "❌ DB ulanmadi"

.PHONY: stop
stop: ## Backend, admin va MinIO dev server'larni to'xtatish
	-pkill -f "uvicorn app.main:app" 2>/dev/null
	-pkill -f "next dev" 2>/dev/null
	-pkill -f "next-server" 2>/dev/null
	-pkill -f "minio server" 2>/dev/null
	@echo "✓ Process'lar to'xtatildi"

# ──────────────────────────────────────────────────────────────────────
# Setup (yangi machine)
# ──────────────────────────────────────────────────────────────────────

.PHONY: setup
setup: db-create backend-install migrate seed admin-install ## To'liq lokal setup (DB + backend + admin)
	@echo ""
	@echo "✅ Setup tugadi!"
	@echo ""
	@echo "Keyingi qadamlar:"
	@echo "  1. make backend          # terminal 1"
	@echo "  2. make admin            # terminal 2"
	@echo "  3. make mobile-ios       # terminal 3"
	@echo ""
